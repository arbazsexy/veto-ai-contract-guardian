import 'package:flutter/material.dart';

class ExportActionsPanel extends StatelessWidget {
  const ExportActionsPanel({
    super.key,
    required this.onCopySummary,
    required this.onShareSummary,
  });

  final Future<void> Function() onCopySummary;
  final Future<void> Function() onShareSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            'Export review',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Copy or share a clean review summary with your notes, lawyer, or client discussion thread.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF57534E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onCopySummary,
                icon: const Icon(Icons.copy_all_rounded),
                label: const Text('Copy Summary'),
              ),
              OutlinedButton.icon(
                onPressed: onShareSummary,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Share Summary'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
