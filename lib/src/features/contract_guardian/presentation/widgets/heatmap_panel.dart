import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/finding_tile.dart';

class HeatmapPanel extends StatelessWidget {
  const HeatmapPanel({super.key, required this.findings});

  final List<ClauseFinding> findings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedFindings = {
      for (final category in FindingCategory.values)
        category: findings.where((finding) => finding.category == category).toList(),
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD8CCBC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Red flag heatmap',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each clause gets a risk band so the freelancer knows what to push back on first.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF57534E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          for (final category in FindingCategory.values) ...[
            if (groupedFindings[category]!.isNotEmpty) ...[
              _CategoryBlock(
                category: category,
                children: groupedFindings[category]!
                    .map((finding) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FindingTile(finding: finding),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    required this.category,
    required this.children,
  });

  final FindingCategory category;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: const Color(0xFF6B4F2A)),
              const SizedBox(width: 8),
              Text(
                category.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            category.description,
            style: const TextStyle(
              color: Color(0xFF57534E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
