import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/metric_card.dart';

class InsightStrip extends StatelessWidget {
  const InsightStrip({
    super.key,
    required this.analysis,
    this.compact = false,
  });

  final ContractAnalysis analysis;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        MetricCard(
          label: 'Red flags',
          value: '${analysis.redCount}',
          accent: const Color(0xFFB42318),
          compact: compact,
        ),
        MetricCard(
          label: 'Negotiable',
          value: '${analysis.orangeCount}',
          accent: const Color(0xFFB54708),
          compact: compact,
        ),
        MetricCard(
          label: 'Safe clauses',
          value: '${analysis.greenCount}',
          accent: const Color(0xFF027A48),
          compact: compact,
        ),
        MetricCard(
          label: 'Top issue',
          value: analysis.topIssue,
          accent: const Color(0xFF6941C6),
          isWide: true,
          compact: compact,
        ),
      ],
    );
  }
}
