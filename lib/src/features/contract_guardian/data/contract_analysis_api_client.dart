import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:veto_ai/src/core/config/backend_config.dart';
import 'package:veto_ai/src/features/contract_guardian/domain/contract_models.dart';

class ContractAnalysisApiClient {
  ContractAnalysisApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        resolvedBaseUrl = baseUrl ?? BackendConfig.baseUrl;

  final http.Client _httpClient;
  final String resolvedBaseUrl;

  Future<ContractAnalysis> analyze({
    required String contractText,
    required String documentLabel,
    required AnalysisInputQuality inputQuality,
  }) async {
    final uri = Uri.parse('$resolvedBaseUrl/api/v1/analyze');
    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contract_text': contractText,
        'document_label': documentLabel,
        'input_quality': _encodeInputQuality(inputQuality),
        'locale': 'en-IN',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ContractAnalysisApiException(
        'Backend analysis failed with status ${response.statusCode}.',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _decodeAnalysis(json);
  }

  static String _encodeInputQuality(AnalysisInputQuality quality) {
    switch (quality) {
      case AnalysisInputQuality.typed:
        return 'typed';
      case AnalysisInputQuality.digitalPdf:
        return 'digital_pdf';
      case AnalysisInputQuality.ocrPdf:
        return 'ocr_pdf';
    }
  }

  static ContractAnalysis _decodeAnalysis(Map<String, dynamic> json) {
    final findingsJson = json['findings'] as List<dynamic>? ?? const [];
    final findings = findingsJson
        .cast<Map<String, dynamic>>()
        .map(_decodeFinding)
        .toList();

    return ContractAnalysis(
      findings: findings,
      guardianScore: (json['guardian_score'] as num?)?.toInt() ?? 50,
      topIssue: json['top_issue'] as String? ?? 'No major issue detected',
      inputQuality: _decodeInputQuality(json['input_quality'] as String?),
      verdict: _decodeVerdict(json['verdict'] as String?),
    );
  }

  static ClauseFinding _decodeFinding(Map<String, dynamic> json) {
    return ClauseFinding(
      title: json['title'] as String? ?? 'Untitled finding',
      category: _decodeCategory(json['category'] as String?),
      risk: _decodeRisk(json['risk'] as String?),
      confidence: _decodeConfidence(json['confidence'] as String?),
      matchedSnippet: json['matched_snippet'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      negotiationScript: json['negotiation_script'] as String? ?? '',
    );
  }

  static FindingCategory _decodeCategory(String? raw) {
    switch (raw) {
      case 'money_risk':
        return FindingCategory.moneyRisk;
      case 'ip_legal_risk':
        return FindingCategory.ipLegalRisk;
      case 'scope_risk':
        return FindingCategory.scopeRisk;
      case 'client_control_risk':
        return FindingCategory.clientControlRisk;
      default:
        return FindingCategory.scopeRisk;
    }
  }

  static RiskLevel _decodeRisk(String? raw) {
    switch (raw) {
      case 'danger':
        return RiskLevel.danger;
      case 'negotiable':
        return RiskLevel.negotiable;
      default:
        return RiskLevel.safe;
    }
  }

  static FindingConfidence _decodeConfidence(String? raw) {
    switch (raw) {
      case 'high':
        return FindingConfidence.high;
      case 'medium':
        return FindingConfidence.medium;
      default:
        return FindingConfidence.review;
    }
  }

  static AnalysisInputQuality _decodeInputQuality(String? raw) {
    switch (raw) {
      case 'digital_pdf':
        return AnalysisInputQuality.digitalPdf;
      case 'ocr_pdf':
        return AnalysisInputQuality.ocrPdf;
      default:
        return AnalysisInputQuality.typed;
    }
  }

  static ContractVerdict _decodeVerdict(String? raw) {
    switch (raw) {
      case 'signable':
        return ContractVerdict.signable;
      case 'high_risk':
        return ContractVerdict.highRisk;
      default:
        return ContractVerdict.signableAfterEdits;
    }
  }
}

class ContractAnalysisApiException implements Exception {
  ContractAnalysisApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
