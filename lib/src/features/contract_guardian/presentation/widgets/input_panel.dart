import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/mini_pill.dart';

class InputPanel extends StatelessWidget {
  const InputPanel({
    super.key,
    required this.controller,
    required this.onAnalyze,
    required this.onUploadPdf,
    required this.onLoadSample,
    required this.onClear,
    required this.documentLabel,
    required this.documentSourceLabel,
    required this.analysisModeLabel,
    required this.isAnalyzing,
    required this.isLoadingPdf,
  });

  final TextEditingController controller;
  final Future<void> Function() onAnalyze;
  final Future<void> Function() onUploadPdf;
  final Future<void> Function() onLoadSample;
  final VoidCallback onClear;
  final String documentLabel;
  final String documentSourceLabel;
  final String analysisModeLabel;
  final bool isAnalyzing;
  final bool isLoadingPdf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        return Container(
          padding: EdgeInsets.all(isCompact ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFD8CCBC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analyze a contract',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1 uses pasted text and a local clause checker so we can validate the core workflow quickly.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF57534E),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: onLoadSample,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Load Sample'),
                  ),
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: isCompact ? 14 : 16,
                decoration: InputDecoration(
                  hintText: 'Paste client contract text here...',
                  filled: true,
                  fillColor: const Color(0xFFF9F6F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFD8CCBC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFD8CCBC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFFC0843D),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EFE6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            documentLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            documentSourceLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78716C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            analysisModeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B4F2A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: isAnalyzing ? null : onAnalyze,
                    icon: isAnalyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.gavel_rounded),
                    label: Text(
                      isAnalyzing
                          ? 'Analyzing...'
                          : (isCompact ? 'Analyze' : 'Analyze Contract'),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: isLoadingPdf ? null : onUploadPdf,
                    icon: isLoadingPdf
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_outlined),
                    label: Text(isLoadingPdf
                        ? 'Reading PDF...'
                        : (isCompact ? 'Upload' : 'Upload PDF')),
                  ),
                  const MiniPill(
                    icon: Icons.shield_outlined,
                    label: 'IP checks',
                  ),
                  const MiniPill(
                    icon: Icons.payments_outlined,
                    label: 'Payment terms',
                  ),
                  const MiniPill(
                    icon: Icons.report_problem_outlined,
                    label: 'Termination risk',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
