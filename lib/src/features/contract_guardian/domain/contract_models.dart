import 'package:flutter/material.dart';

enum FindingCategory {
  moneyRisk(
    title: 'Money Risk',
    description: 'Payment timing, deposits, and cancellation protection.',
    icon: Icons.payments_outlined,
  ),
  ipLegalRisk(
    title: 'IP and Legal Risk',
    description: 'Ownership, liability, confidentiality, and legal exposure.',
    icon: Icons.gavel_outlined,
  ),
  scopeRisk(
    title: 'Scope Risk',
    description: 'Deliverables, revisions, and work-definition clarity.',
    icon: Icons.design_services_outlined,
  ),
  clientControlRisk(
    title: 'Client Control Risk',
    description: 'Termination, exclusivity, and client leverage over your work.',
    icon: Icons.admin_panel_settings_outlined,
  );

  const FindingCategory({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

enum AnalysisInputQuality {
  typed(
    title: 'High clarity input',
    summary: 'Analyzed from typed or pasted text.',
    confidencePenalty: 0,
  ),
  digitalPdf(
    title: 'Good source quality',
    summary: 'Analyzed from direct PDF text extraction.',
    confidencePenalty: 1,
  ),
  ocrPdf(
    title: 'OCR review suggested',
    summary: 'Analyzed from scanned PDF OCR and may contain recognition errors.',
    confidencePenalty: 2,
  );

  const AnalysisInputQuality({
    required this.title,
    required this.summary,
    required this.confidencePenalty,
  });

  final String title;
  final String summary;
  final int confidencePenalty;
}

enum FindingConfidence {
  high('High confidence'),
  medium('Medium confidence'),
  review('Needs review');

  const FindingConfidence(this.label);

  final String label;

  Color get color {
    switch (this) {
      case FindingConfidence.high:
        return const Color(0xFF027A48);
      case FindingConfidence.medium:
        return const Color(0xFFB54708);
      case FindingConfidence.review:
        return const Color(0xFFB42318);
    }
  }
}

enum RiskLevel {
  danger('Dangerous'),
  negotiable('Negotiable'),
  safe('Safe');

  const RiskLevel(this.label);

  final String label;

  RiskPalette get palette {
    switch (this) {
      case RiskLevel.danger:
        return const RiskPalette(
          background: Color(0xFFFEF3F2),
          border: Color(0xFFFDA29B),
          badge: Color(0xFFB42318),
        );
      case RiskLevel.negotiable:
        return const RiskPalette(
          background: Color(0xFFFFF6ED),
          border: Color(0xFFFEC84B),
          badge: Color(0xFFB54708),
        );
      case RiskLevel.safe:
        return const RiskPalette(
          background: Color(0xFFECFDF3),
          border: Color(0xFF6CE9A6),
          badge: Color(0xFF027A48),
        );
    }
  }
}

class RiskPalette {
  const RiskPalette({
    required this.background,
    required this.border,
    required this.badge,
  });

  final Color background;
  final Color border;
  final Color badge;
}

class ClauseFinding {
  const ClauseFinding({
    required this.title,
    required this.category,
    required this.risk,
    required this.confidence,
    required this.matchedSnippet,
    required this.explanation,
    required this.negotiationScript,
  });

  final String title;
  final FindingCategory category;
  final RiskLevel risk;
  final FindingConfidence confidence;
  final String matchedSnippet;
  final String explanation;
  final String negotiationScript;
}

enum ContractVerdict {
  signable(
    label: 'Signable',
    summary: 'The contract looks workable with no major blockers detected.',
    accent: Color(0xFF027A48),
  ),
  signableAfterEdits(
    label: 'Signable After Edits',
    summary: 'There are issues to negotiate before accepting the agreement.',
    accent: Color(0xFFB54708),
  ),
  highRisk(
    label: 'High Risk',
    summary: 'Do not accept yet. The contract needs major edits or legal review.',
    accent: Color(0xFFB42318),
  );

  const ContractVerdict({
    required this.label,
    required this.summary,
    required this.accent,
  });

  final String label;
  final String summary;
  final Color accent;
}

class ContractAnalysis {
  const ContractAnalysis({
    required this.findings,
    required this.guardianScore,
    required this.topIssue,
    required this.inputQuality,
    required this.verdict,
  });

  final List<ClauseFinding> findings;
  final int guardianScore;
  final String topIssue;
  final AnalysisInputQuality inputQuality;
  final ContractVerdict verdict;

  int get redCount =>
      findings.where((finding) => finding.risk == RiskLevel.danger).length;

  int get orangeCount =>
      findings.where((finding) => finding.risk == RiskLevel.negotiable).length;

  int get greenCount =>
      findings.where((finding) => finding.risk == RiskLevel.safe).length;
}
