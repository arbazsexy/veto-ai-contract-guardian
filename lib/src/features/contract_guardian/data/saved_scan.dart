import 'dart:convert';

class SavedScan {
  const SavedScan({
    required this.id,
    required this.documentLabel,
    required this.documentSourceLabel,
    required this.contractText,
    required this.savedAtIso,
  });

  final String id;
  final String documentLabel;
  final String documentSourceLabel;
  final String contractText;
  final String savedAtIso;

  DateTime get savedAt => DateTime.parse(savedAtIso);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentLabel': documentLabel,
      'documentSourceLabel': documentSourceLabel,
      'contractText': contractText,
      'savedAtIso': savedAtIso,
    };
  }

  factory SavedScan.fromJson(Map<String, dynamic> json) {
    return SavedScan(
      id: json['id'] as String,
      documentLabel: json['documentLabel'] as String,
      documentSourceLabel: json['documentSourceLabel'] as String,
      contractText: json['contractText'] as String,
      savedAtIso: json['savedAtIso'] as String,
    );
  }

  static String encodeList(List<SavedScan> scans) {
    return jsonEncode(scans.map((scan) => scan.toJson()).toList());
  }

  static List<SavedScan> decodeList(String raw) {
    final parsed = jsonDecode(raw) as List<dynamic>;
    return parsed
        .map((item) => SavedScan.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
