from datetime import datetime, timezone
import re

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
        self._rules_by_title = {rule.title: rule for rule in rules}

    def analyze(self, request: AnalysisRequest) -> AnalysisResponse:
        text = request.contract_text.strip()
        normalized_text = self._normalize_text(text)
        lower = normalized_text.lower()

        findings = [
            self._match_or_fallback(
                text=normalized_text,
                lower=lower,
                rule=rule,
                input_quality=request.input_quality,
            )
            for rule in self._rules
        ]
        findings.sort(key=self._finding_sort_key)

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
        match = next((pattern for pattern in rule.patterns if self._phrase_matches(lower, pattern)), None)
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
                explanation=self._build_explanation(
                    base=rule.miss_explanation,
                    category=rule.category,
                    risk=fallback_risk,
                    triggered=fallback_risk != RiskLevel.safe,
                ),
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
            explanation=self._build_explanation(
                base=rule.hit_explanation,
                category=rule.category,
                risk=rule.risk,
                triggered=True,
            ),
            negotiation_script=rule.hit_script,
        )

    @staticmethod
    def _normalize_text(text: str) -> str:
        return re.sub(r"\s+", " ", text).strip()

    @staticmethod
    def _phrase_matches(lower_text: str, phrase: str) -> bool:
        simple_phrase = phrase.lower()
        if " " not in simple_phrase and "-" not in simple_phrase:
            return simple_phrase in lower_text
        escaped = re.escape(simple_phrase).replace(r"\ ", r"\s+").replace(r"\-", r"[-\s]?")
        pattern = rf"(?<!\w){escaped}(?!\w)"
        return re.search(pattern, lower_text) is not None

    @classmethod
    def _extract_snippet(cls, text: str, phrase: str) -> str:
        sentence = cls._find_sentence_containing_phrase(text, phrase)
        if sentence:
            return sentence
        lower = text.lower()
        start = lower.find(phrase.lower())
        if start == -1:
            return phrase
        snippet_start = max(0, start - 36)
        snippet_end = min(len(text), start + len(phrase) + 80)
        return text[snippet_start:snippet_end].strip()

    @staticmethod
    def _find_sentence_containing_phrase(text: str, phrase: str) -> str | None:
        sentences = re.split(r"(?<=[.!?;])\s+", text)
        phrase_lower = phrase.lower()
        for sentence in sentences:
            if phrase_lower in sentence.lower():
                return sentence.strip()
        return None

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
        if finding.title == "Acceptance criteria clarity":
            return finding.matched_snippet != "No acceptance criteria detected."
        if finding.title == "Late fee or overdue payment remedy":
            return finding.matched_snippet != "No overdue-payment remedy detected."
        return not finding.matched_snippet.startswith("No ")

    def _score_findings(self, findings: list[Finding]) -> int:
        score = 100
        for finding in findings:
            rule = self._rule_for_title(finding.title)
            if finding.risk == RiskLevel.danger and self._finding_triggered(finding):
                score -= rule.penalty
            elif finding.risk == RiskLevel.negotiable and self._finding_triggered(finding):
                score -= rule.penalty
            elif finding.risk == RiskLevel.safe and not self._finding_triggered(finding):
                score -= rule.penalty
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
        if red_count >= 1 or orange_count >= 2 or guardian_score < 80:
            return Verdict.signable_after_edits
        return Verdict.signable

    def _build_summary(
        self,
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
            if finding.risk != RiskLevel.safe and self._finding_triggered(finding):
                category_counts[finding.category] += 1

        strongest_category = max(category_counts, key=category_counts.get)
        strongest_label = {
            FindingCategory.money_risk: "money terms",
            FindingCategory.ip_legal_risk: "IP and legal clauses",
            FindingCategory.scope_risk: "scope definition",
            FindingCategory.client_control_risk: "client control terms",
        }[strongest_category]
        red_titles = [
            finding.title
            for finding in findings
            if finding.risk == RiskLevel.danger and self._finding_triggered(finding)
        ]
        orange_titles = [
            finding.title
            for finding in findings
            if finding.risk == RiskLevel.negotiable and self._finding_triggered(finding)
        ]
        protections_present = [
            finding.title
            for finding in findings
            if finding.risk == RiskLevel.safe and self._finding_triggered(finding)
        ]
        key_issue = (red_titles + orange_titles)[0] if (red_titles or orange_titles) else "no major blocker"
        protections_note = ""
        if protections_present:
            protections_note = f" Protective language is present around {protections_present[0].lower()}."

        if verdict == Verdict.high_risk:
            return (
                f"This contract is currently high risk. The biggest concentration of issues is in {strongest_label}, "
                f"with the clearest problem around {key_issue.lower()}. The current guardian score is {guardian_score}.{protections_note}"
            )
        if verdict == Verdict.signable_after_edits:
            return (
                f"This contract looks workable after negotiation. The main edits are around {strongest_label}, "
                f"especially {key_issue.lower()}, with a guardian score of {guardian_score}.{protections_note}"
            )
        return (
            f"This contract appears broadly workable. No major blockers were detected and the guardian score is {guardian_score}.{protections_note}"
        )

    def _rule_for_title(self, title: str) -> AnalysisRule:
        return self._rules_by_title[title]

    def _finding_sort_key(self, finding: Finding) -> tuple[int, int, int]:
        rule = self._rule_for_title(finding.title)
        risk_rank = {
            RiskLevel.danger: 0,
            RiskLevel.negotiable: 1,
            RiskLevel.safe: 2,
        }[finding.risk]
        triggered_rank = 0 if self._finding_triggered(finding) else 1
        return (risk_rank, triggered_rank, -rule.priority)

    @staticmethod
    def _build_explanation(
        *,
        base: str,
        category: FindingCategory,
        risk: RiskLevel,
        triggered: bool,
    ) -> str:
        category_hint = {
            FindingCategory.money_risk: "This mainly affects payment timing, cash flow, or cancellation protection.",
            FindingCategory.ip_legal_risk: "This mainly affects legal exposure, ownership, or confidentiality.",
            FindingCategory.scope_risk: "This mainly affects revisions, acceptance, or clarity of deliverables.",
            FindingCategory.client_control_risk: "This mainly affects how much leverage the client has over the engagement.",
        }[category]
        risk_hint = {
            RiskLevel.danger: "Treat this as a strong negotiation point before you sign.",
            RiskLevel.negotiable: "This is usually negotiable and worth tightening before kickoff.",
            RiskLevel.safe: "This is generally protective language, but it should still fit the project context.",
        }[risk]
        if not triggered and risk == RiskLevel.safe:
            risk_hint = "This protection is missing, so consider adding it before work starts."
        return f"{base} {category_hint} {risk_hint}"
