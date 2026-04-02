from datetime import datetime, timezone

from app.domain.analysis_rules import DEFAULT_ANALYSIS_RULES, AnalysisRule
from app.schemas.analysis import (
    AnalysisRequest,
    AnalysisResponse,
    Finding,
    FindingCategory,
    FindingConfidence,
    InputQuality,
    RiskLevel,
    Verdict,
)


class AnalysisService:
    def __init__(self, rules: tuple[AnalysisRule, ...] = DEFAULT_ANALYSIS_RULES) -> None:
        self._rules = rules

    def analyze(self, request: AnalysisRequest) -> AnalysisResponse:
        text = request.contract_text.strip()
        lower = text.lower()

        findings = [
            self._match_or_fallback(
                text=text,
                lower=lower,
                rule=rule,
                input_quality=request.input_quality,
            )
            for rule in self._rules
        ]

        guardian_score = self._score_findings(findings)
        triggered_findings = [finding for finding in findings if self._finding_triggered(finding)]
        top_issue = triggered_findings[0].title if triggered_findings else "No major issue detected"
        verdict = self._resolve_verdict(guardian_score=guardian_score, findings=findings)

        return AnalysisResponse(
            document_label=request.document_label,
            analyzed_at=datetime.now(timezone.utc),
            input_quality=request.input_quality,
            verdict=verdict,
            guardian_score=guardian_score,
            top_issue=top_issue,
            red_count=sum(1 for finding in findings if finding.risk == RiskLevel.danger),
            orange_count=sum(1 for finding in findings if finding.risk == RiskLevel.negotiable),
            green_count=sum(1 for finding in findings if finding.risk == RiskLevel.safe),
            summary=self._build_summary(verdict=verdict, guardian_score=guardian_score, findings=findings),
            findings=findings,
        )

    def _match_or_fallback(
        self,
        *,
        text: str,
        lower: str,
        rule: AnalysisRule,
        input_quality: InputQuality,
    ) -> Finding:
        match = next((pattern for pattern in rule.patterns if pattern.lower() in lower), None)
        if match is None:
            fallback_risk = RiskLevel.negotiable if rule.risk == RiskLevel.safe else RiskLevel.safe
            return Finding(
                title=rule.title,
                category=rule.category,
                risk=fallback_risk,
                confidence=self._resolve_confidence(
                    matched=False,
                    risk=fallback_risk,
                    input_quality=input_quality,
                ),
                matched_snippet=rule.fallback_snippet,
                explanation=rule.miss_explanation,
                negotiation_script=rule.miss_script,
            )

        return Finding(
            title=rule.title,
            category=rule.category,
            risk=rule.risk,
            confidence=self._resolve_confidence(
                matched=True,
                risk=rule.risk,
                input_quality=input_quality,
            ),
            matched_snippet=self._extract_snippet(text, match),
            explanation=rule.hit_explanation,
            negotiation_script=rule.hit_script,
        )

    @staticmethod
    def _extract_snippet(text: str, phrase: str) -> str:
        lower = text.lower()
        start = lower.find(phrase.lower())
        if start == -1:
            return phrase
        snippet_start = max(0, start - 36)
        snippet_end = min(len(text), start + len(phrase) + 80)
        return text[snippet_start:snippet_end].replace("\n", " ").strip()

    @staticmethod
    def _resolve_confidence(
        *,
        matched: bool,
        risk: RiskLevel,
        input_quality: InputQuality,
    ) -> FindingConfidence:
        score = 2 if matched else 1
        if risk == RiskLevel.safe and not matched:
            score = 1

        penalty = {
            InputQuality.typed: 0,
            InputQuality.digital_pdf: 1,
            InputQuality.ocr_pdf: 2,
        }[input_quality]
        score -= penalty

        if score >= 2:
            return FindingConfidence.high
        if score == 1:
            return FindingConfidence.medium
        return FindingConfidence.review

    @staticmethod
    def _finding_triggered(finding: Finding) -> bool:
        if finding.title == "Defined scope and deliverables":
            return finding.matched_snippet != "Scope details are thin or missing."
        if finding.title == "Confidentiality coverage":
            return finding.matched_snippet != "No confidentiality clause detected."
        if finding.title == "Revision limits":
            return finding.matched_snippet != "No revision limits detected."
        return not finding.matched_snippet.startswith("No ")

    def _score_findings(self, findings: list[Finding]) -> int:
        score = 100
        for finding in findings:
            if finding.risk == RiskLevel.danger and self._finding_triggered(finding):
                score -= 25
            elif finding.risk == RiskLevel.negotiable and self._finding_triggered(finding):
                score -= 12
            elif finding.risk == RiskLevel.safe and not self._finding_triggered(finding):
                score -= 8
        return max(12, min(98, score))

    def _resolve_verdict(self, *, guardian_score: int, findings: list[Finding]) -> Verdict:
        red_count = sum(
            1
            for finding in findings
            if finding.risk == RiskLevel.danger and self._finding_triggered(finding)
        )
        orange_count = sum(
            1
            for finding in findings
            if finding.risk == RiskLevel.negotiable and self._finding_triggered(finding)
        )

        if red_count >= 2 or guardian_score < 45:
            return Verdict.high_risk
        if red_count >= 1 or orange_count >= 2 or guardian_score < 78:
            return Verdict.signable_after_edits
        return Verdict.signable

    @staticmethod
    def _build_summary(
        *,
        verdict: Verdict,
        guardian_score: int,
        findings: list[Finding],
    ) -> str:
        category_counts = {
            FindingCategory.money_risk: 0,
            FindingCategory.ip_legal_risk: 0,
            FindingCategory.scope_risk: 0,
            FindingCategory.client_control_risk: 0,
        }
        for finding in findings:
            if finding.risk != RiskLevel.safe:
                category_counts[finding.category] += 1

        strongest_category = max(category_counts, key=category_counts.get)
        strongest_label = {
            FindingCategory.money_risk: "money terms",
            FindingCategory.ip_legal_risk: "IP and legal clauses",
            FindingCategory.scope_risk: "scope definition",
            FindingCategory.client_control_risk: "client control terms",
        }[strongest_category]

        if verdict == Verdict.high_risk:
            return (
                f"This contract is currently high risk. The biggest concentration of issues is in {strongest_label}, "
                f"and the current guardian score is {guardian_score}."
            )
        if verdict == Verdict.signable_after_edits:
            return (
                f"This contract looks workable after negotiation. The main edits are around {strongest_label}, "
                f"with a guardian score of {guardian_score}."
            )
        return (
            f"This contract appears broadly workable. There are no major blockers detected, and the guardian score is {guardian_score}."
        )
