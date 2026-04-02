import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:veto_ai/src/features/contract_guardian/data/analysis_export_builder.dart';
import 'package:veto_ai/src/features/contract_guardian/data/contract_analysis_api_client.dart';
import 'package:veto_ai/src/features/contract_guardian/data/pdf_contract_loader.dart';
import 'package:veto_ai/src/features/contract_guardian/data/saved_scan.dart';
import 'package:veto_ai/src/features/contract_guardian/data/sample_contract.dart';
import 'package:veto_ai/src/features/contract_guardian/data/scan_history_repository.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_analyzer.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/heatmap_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/analysis_meta_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/hero_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/input_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/insight_strip.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/negotiation_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/disclaimer_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/export_actions_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/recent_scans_panel.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/widgets/step_card.dart';

class ContractGuardianHomePage extends StatefulWidget {
  const ContractGuardianHomePage({super.key});

  @override
  State<ContractGuardianHomePage> createState() =>
      _ContractGuardianHomePageState();
}

class _ContractGuardianHomePageState extends State<ContractGuardianHomePage> {
  final ScanHistoryRepository _historyRepository = ScanHistoryRepository();
  final ContractAnalysisApiClient _apiClient = ContractAnalysisApiClient();
  final TextEditingController _contractController = TextEditingController(
    text: sampleContract,
  );

  ContractAnalysis _analysis = ContractAnalyzer.analyze(sampleContract);
  String _documentLabel = 'Loaded sample contract';
  String _documentSourceLabel = 'Manual sample text';
  AnalysisInputQuality _inputQuality = AnalysisInputQuality.typed;
  String _analysisModeLabel = 'Local rule analysis';
  bool _isAnalyzing = false;
  bool _isLoadingPdf = false;
  List<SavedScan> _recentScans = const [];
  DateTime? _lastAnalyzedAt;
  int _analysisRequestId = 0;

  @override
  void initState() {
    super.initState();
    _lastAnalyzedAt = DateTime.now();
    _loadRecentScans();
  }

  @override
  void dispose() {
    _contractController.dispose();
    super.dispose();
  }

  Future<void> _analyzeContract() async {
    _inputQuality = AnalysisInputQuality.typed;
    _documentSourceLabel = 'Manual text entry';
    await _runAnalysis(
      contractText: _contractController.text,
      inputQuality: _inputQuality,
    );
  }

  Future<void> _loadPdfContract() async {
    setState(() {
      _isLoadingPdf = true;
    });

    try {
      final loadedDocument = await PdfContractLoader.pickAndExtractText();
      if (!mounted || loadedDocument == null) {
        return;
      }

      _contractController.text = loadedDocument.extractedText;
      setState(() {
        _documentLabel = loadedDocument.fileName;
        _documentSourceLabel = loadedDocument.extractionMethod.label;
        _inputQuality = switch (loadedDocument.extractionMethod) {
          PdfExtractionMethod.directText => AnalysisInputQuality.digitalPdf,
        };
      });
      await _runAnalysis(
        contractText: loadedDocument.extractedText,
        inputQuality: _inputQuality,
      );
    } on PdfContractLoadException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showSnackBar('Something went wrong while reading that PDF.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPdf = false;
        });
      }
    }
  }

  Future<void> _loadRecentScans() async {
    final scans = await _historyRepository.loadScans();
    if (!mounted) {
      return;
    }

    setState(() {
      _recentScans = scans;
    });
  }

  Future<void> _persistCurrentScan() async {
    final contractText = _contractController.text.trim();
    if (contractText.isEmpty) {
      return;
    }

    final savedScan = SavedScan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      documentLabel: _documentLabel,
      documentSourceLabel: _documentSourceLabel,
      contractText: contractText,
      savedAtIso: DateTime.now().toIso8601String(),
    );

    final scans = await _historyRepository.saveScan(savedScan);
    if (!mounted) {
      return;
    }

    setState(() {
      _recentScans = scans;
    });
  }

  Future<void> _openSavedScan(SavedScan scan) async {
    final inputQuality = scan.documentSourceLabel.contains('OCR')
        ? AnalysisInputQuality.ocrPdf
        : scan.documentSourceLabel.contains('PDF')
            ? AnalysisInputQuality.digitalPdf
            : AnalysisInputQuality.typed;

    setState(() {
      _documentLabel = scan.documentLabel;
      _documentSourceLabel = scan.documentSourceLabel;
      _inputQuality = inputQuality;
      _contractController.text = scan.contractText;
      _analysisModeLabel = 'Saved scan restored';
    });
    await _runAnalysis(
      contractText: scan.contractText,
      inputQuality: inputQuality,
      showFailureSnackBar: false,
    );
  }

  Future<void> _loadSampleContract() async {
    setState(() {
      _contractController.text = sampleContract;
      _documentLabel = 'Loaded sample contract';
      _documentSourceLabel = 'Manual sample text';
      _inputQuality = AnalysisInputQuality.typed;
      _analysisModeLabel = 'Sample contract ready';
    });
    await _runAnalysis(
      contractText: sampleContract,
      inputQuality: _inputQuality,
    );
  }

  void _clearContract() {
    setState(() {
      _contractController.clear();
      _documentLabel = 'No contract loaded';
      _documentSourceLabel = 'Manual text entry';
      _inputQuality = AnalysisInputQuality.typed;
      _analysis = ContractAnalyzer.analyze('');
      _analysisModeLabel = 'Local rule analysis';
      _lastAnalyzedAt = null;
    });
  }

  Future<void> _deleteSavedScan(SavedScan scan) async {
    final scans = await _historyRepository.removeScan(scan.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _recentScans = scans;
    });

    _showSnackBar('Removed ${scan.documentLabel} from recent scans.');
  }

  int get _wordCount {
    final text = _contractController.text.trim();
    if (text.isEmpty) {
      return 0;
    }

    return text.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).length;
  }

  String _buildExportSummary() {
    return AnalysisExportBuilder.build(
      documentLabel: _documentLabel,
      documentSourceLabel: _documentSourceLabel,
      analysis: _analysis,
    );
  }

  Future<void> _copySummary() async {
    await Clipboard.setData(
      ClipboardData(text: _buildExportSummary()),
    );
    if (!mounted) {
      return;
    }

    _showSnackBar('Review summary copied.');
  }

  Future<void> _shareSummary() async {
    await SharePlus.instance.share(
      ShareParams(
        text: _buildExportSummary(),
        subject: 'Contract Guardian Review',
      ),
    );
  }

  Future<void> _runAnalysis({
    required String contractText,
    required AnalysisInputQuality inputQuality,
    bool showFailureSnackBar = true,
  }) async {
    final requestId = ++_analysisRequestId;

    if (contractText.trim().isEmpty) {
      setState(() {
        _analysis = ContractAnalyzer.analyze(
          '',
          inputQuality: inputQuality,
        );
        _analysisModeLabel = 'Local rule analysis';
        _lastAnalyzedAt = null;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final backendAnalysis = await _apiClient.analyze(
        contractText: contractText,
        documentLabel: _documentLabel,
        inputQuality: inputQuality,
      );

      if (!mounted || requestId != _analysisRequestId) {
        return;
      }

      setState(() {
        _analysis = backendAnalysis;
        _analysisModeLabel = 'Backend AI service';
        _lastAnalyzedAt = DateTime.now();
      });
    } catch (_) {
      final localAnalysis = ContractAnalyzer.analyze(
        contractText,
        inputQuality: inputQuality,
      );

      if (!mounted || requestId != _analysisRequestId) {
        return;
      }

      setState(() {
        _analysis = localAnalysis;
        _analysisModeLabel = 'Local fallback analysis';
        _lastAnalyzedAt = DateTime.now();
      });

      if (showFailureSnackBar) {
        _showSnackBar(
          'Backend analysis is unavailable. Showing local fallback results.',
        );
      }
    } finally {
      if (mounted && requestId == _analysisRequestId) {
        setState(() {
          _isAnalyzing = false;
        });
      }
      if (requestId == _analysisRequestId) {
        await _persistCurrentScan();
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final contentWidth = viewport.maxWidth;
            final isMobile = contentWidth < 760;
            final horizontalPadding = isMobile ? 14.0 : 20.0;
            final sectionGap = isMobile ? 18.0 : 24.0;
            final panelGap = isMobile ? 14.0 : 20.0;
            final topPanelWidth = isMobile
                ? contentWidth - (horizontalPadding * 2)
                : 520.0;
            final inputPanelWidth = isMobile
                ? contentWidth - (horizontalPadding * 2)
                : 640.0;
            final resultPanelWidth = isMobile
                ? contentWidth - (horizontalPadding * 2)
                : 560.0;
            final stepCardWidth = isMobile
                ? contentWidth - (horizontalPadding * 2)
                : 360.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: panelGap,
                        runSpacing: panelGap,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          SizedBox(
                            width: topPanelWidth,
                            child: HeroPanel(
                              score: _analysis.guardianScore,
                              verdict: _analysis.verdict,
                            ),
                          ),
                          SizedBox(
                            width: inputPanelWidth,
                            child: InputPanel(
                              controller: _contractController,
                              onAnalyze: _analyzeContract,
                              onUploadPdf: _loadPdfContract,
                              onLoadSample: _loadSampleContract,
                              onClear: _clearContract,
                              documentLabel: _documentLabel,
                              documentSourceLabel: _documentSourceLabel,
                              analysisModeLabel: _analysisModeLabel,
                              isAnalyzing: _isAnalyzing,
                              isLoadingPdf: _isLoadingPdf,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sectionGap),
                      AnalysisMetaPanel(
                        wordCount: _wordCount,
                        characterCount: _contractController.text.length,
                        lastAnalyzedAt: _lastAnalyzedAt,
                      ),
                      SizedBox(height: sectionGap),
                      DisclaimerPanel(
                        extractionLabel: _documentSourceLabel,
                        inputQuality: _analysis.inputQuality,
                      ),
                      SizedBox(height: sectionGap),
                      RecentScansPanel(
                        scans: _recentScans,
                        onOpenScan: _openSavedScan,
                        onDeleteScan: _deleteSavedScan,
                      ),
                      SizedBox(height: sectionGap),
                      ExportActionsPanel(
                        onCopySummary: _copySummary,
                        onShareSummary: _shareSummary,
                      ),
                      SizedBox(height: sectionGap),
                      InsightStrip(
                        analysis: _analysis,
                        compact: isMobile,
                      ),
                      SizedBox(height: sectionGap),
                      Wrap(
                        spacing: panelGap,
                        runSpacing: panelGap,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          SizedBox(
                            width: resultPanelWidth,
                            child: HeatmapPanel(findings: _analysis.findings),
                          ),
                          SizedBox(
                            width: resultPanelWidth,
                            child:
                                NegotiationPanel(findings: _analysis.findings),
                          ),
                        ],
                      ),
                      SizedBox(height: sectionGap),
                      Text(
                        'How v1 works',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: isMobile ? 12 : 16,
                        runSpacing: isMobile ? 12 : 16,
                        children: [
                          SizedBox(
                            width: stepCardWidth,
                            child: const StepCard(
                              step: '1',
                              title: 'Paste the contract',
                              body:
                                  'Freelancers can drop in offer letters, SOW text, or client agreement clauses.',
                            ),
                          ),
                          SizedBox(
                            width: stepCardWidth,
                            child: const StepCard(
                              step: '2',
                              title: 'Flag risky language',
                              body:
                                  'The rule engine looks for payment delays, IP transfer, indemnity, and termination risk.',
                            ),
                          ),
                          SizedBox(
                            width: stepCardWidth,
                            child: const StepCard(
                              step: '3',
                              title: 'Reply with confidence',
                              body:
                                  'Each major red or orange issue gets a negotiation script the user can send right away.',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
