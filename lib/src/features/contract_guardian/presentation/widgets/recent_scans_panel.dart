import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/data/saved_scan.dart';

class RecentScansPanel extends StatelessWidget {
  const RecentScansPanel({
    super.key,
    required this.scans,
    required this.onOpenScan,
    required this.onDeleteScan,
  });

  final List<SavedScan> scans;
  final ValueChanged<SavedScan> onOpenScan;
  final ValueChanged<SavedScan> onDeleteScan;

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
            'Recent scans',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reopen recent contract reviews without uploading the same document again.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF57534E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          if (scans.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'No saved scans yet. Analyze a contract and it will appear here automatically.',
                style: TextStyle(height: 1.5, color: Color(0xFF57534E)),
              ),
            ),
          for (final scan in scans) ...[
            _RecentScanTile(
              key: ValueKey(scan.id),
              scan: scan,
              onTap: () => onOpenScan(scan),
              onDelete: () => onDeleteScan(scan),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({
    super.key,
    required this.scan,
    required this.onTap,
    required this.onDelete,
  });

  final SavedScan scan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F6F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1917),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.documentLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${scan.documentSourceLabel} | ${_formatDate(scan.savedAt)}',
                    style: const TextStyle(
                      color: Color(0xFF57534E),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$month ${date.day}, ${date.year} | $hour:$minute $period';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
