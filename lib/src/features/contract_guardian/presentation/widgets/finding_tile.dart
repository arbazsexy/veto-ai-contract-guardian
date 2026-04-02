import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class FindingTile extends StatelessWidget {
  const FindingTile({super.key, required this.finding});

  final ClauseFinding finding;

  @override
  Widget build(BuildContext context) {
    final palette = finding.risk.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.badge,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  finding.risk.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  finding.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 16,
                color: finding.confidence.color,
              ),
              const SizedBox(width: 6),
              Text(
                finding.confidence.label,
                style: TextStyle(
                  color: finding.confidence.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            finding.matchedSnippet,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: Color(0xFF44403C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            finding.explanation,
            style: const TextStyle(height: 1.45),
          ),
        ],
      ),
    );
  }
}
