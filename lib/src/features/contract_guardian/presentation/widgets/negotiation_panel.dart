import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/script_card.dart';

class NegotiationPanel extends StatelessWidget {
  const NegotiationPanel({super.key, required this.findings});

  final List<ClauseFinding> findings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scripts = findings.where((finding) => finding.risk != RiskLevel.safe);
    final groupedScripts = {
      for (final category in FindingCategory.values)
        category: scripts.where((finding) => finding.category == category).toList(),
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD8CCBC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Negotiation scripts',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Copy-ready responses for the clauses that need revision before the freelancer accepts the deal.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF57534E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          if (scripts.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD8CCBC)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF027A48)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No negotiation scripts are needed right now. The current review did not surface any red or orange clauses that require a client message.',
                      style: TextStyle(
                        height: 1.5,
                        color: Color(0xFF57534E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          for (final category in FindingCategory.values) ...[
            if (groupedScripts[category]!.isNotEmpty) ...[
              _ScriptSection(
                category: category,
                findings: groupedScripts[category]!,
              ),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _ScriptSection extends StatelessWidget {
  const _ScriptSection({
    required this.category,
    required this.findings,
  });

  final FindingCategory category;
  final List<ClauseFinding> findings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7DDCF)),
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
          for (final finding in findings) ...[
            ScriptCard(finding: finding),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
