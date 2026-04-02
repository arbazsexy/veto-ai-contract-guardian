import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class AnalysisExportBuilder {
  static String build({
    required String documentLabel,
    required String documentSourceLabel,
    required ContractAnalysis analysis,
  }) {
    final flaggedFindings = analysis.findings.where((finding) {
      return finding.risk != RiskLevel.safe;
    }).toList();

    final buffer = StringBuffer()
      ..writeln('Contract Guardian Review')
      ..writeln()
      ..writeln('Document: $documentLabel')
      ..writeln('Source: $documentSourceLabel')
      ..writeln('Verdict: ${analysis.verdict.label}')
      ..writeln('Guardian Score: ${analysis.guardianScore}')
      ..writeln('Top Issue: ${analysis.topIssue}')
      ..writeln('Input Quality: ${analysis.inputQuality.title}')
      ..writeln()
      ..writeln('Risk Summary')
      ..writeln('- Red flags: ${analysis.redCount}')
      ..writeln('- Negotiable: ${analysis.orangeCount}')
      ..writeln('- Safe clauses: ${analysis.greenCount}');

    if (flaggedFindings.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Priority Findings');

      for (final finding in flaggedFindings) {
        buffer
          ..writeln('- ${finding.category.title}: ${finding.title}')
          ..writeln('  Risk: ${finding.risk.label}')
          ..writeln('  Confidence: ${finding.confidence.label}')
          ..writeln('  Why it matters: ${finding.explanation}')
          ..writeln('  Suggested message: ${finding.negotiationScript}');
      }
    }

    buffer
      ..writeln()
      ..writeln(
        'Note: This is a negotiation support summary, not legal advice.',
      );

    return buffer.toString().trim();
  }
}
