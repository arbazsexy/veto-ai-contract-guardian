import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class ScriptCard extends StatelessWidget {
  const ScriptCard({super.key, required this.finding});

  final ClauseFinding finding;

  @override
  Widget build(BuildContext context) {
    final palette = finding.risk.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  finding.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: finding.negotiationScript),
                  );
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied script for ${finding.title}.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            finding.negotiationScript,
            style: const TextStyle(height: 1.55),
          ),
        ],
      ),
    );
  }
}
