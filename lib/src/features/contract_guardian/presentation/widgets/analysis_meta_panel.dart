import 'package:flutter/material.dart';

class AnalysisMetaPanel extends StatelessWidget {
  const AnalysisMetaPanel({
    super.key,
    required this.wordCount,
    required this.characterCount,
    required this.lastAnalyzedAt,
  });

  final int wordCount;
  final int characterCount;
  final DateTime? lastAnalyzedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8CCBC)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _MetaChip(
            icon: Icons.text_snippet_outlined,
            label: 'Words',
            value: '$wordCount',
          ),
          _MetaChip(
            icon: Icons.notes_outlined,
            label: 'Characters',
            value: '$characterCount',
          ),
          _MetaChip(
            icon: Icons.schedule_outlined,
            label: 'Last analyzed',
            value: lastAnalyzedAt == null ? 'Not yet' : _formatDate(lastAnalyzedAt!),
            isWide: true,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.month}/${value.day}/${value.year} $hour:$minute $period';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isWide = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? 220 : 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B4F2A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF78716C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
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
