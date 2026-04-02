import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class DisclaimerPanel extends StatelessWidget {
  const DisclaimerPanel({
    super.key,
    required this.extractionLabel,
    required this.inputQuality,
  });

  final String extractionLabel;
  final AnalysisInputQuality inputQuality;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFEC84B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFB54708),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review support, not legal advice',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  inputQuality.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB54708),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This score highlights negotiation risk for freelancers. For illegal, high-value, or confusing clauses, a human lawyer should make the final call. ${inputQuality.summary} Current document source: $extractionLabel.',
                  style: const TextStyle(
                    height: 1.5,
                    color: Color(0xFF57534E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
