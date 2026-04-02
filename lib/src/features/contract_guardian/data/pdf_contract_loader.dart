import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class LoadedContractDocument {
  const LoadedContractDocument({
    required this.fileName,
    required this.extractedText,
    required this.extractionMethod,
  });

  final String fileName;
  final String extractedText;
  final PdfExtractionMethod extractionMethod;
}

enum PdfExtractionMethod {
  directText('Direct PDF text');

  const PdfExtractionMethod(this.label);

  final String label;
}

class PdfContractLoader {
  static Future<LoadedContractDocument?> pickAndExtractText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const PdfContractLoadException(
        'The selected PDF could not be read.',
      );
    }

    var extractedText = _extractText(bytes);
    var extractionMethod = PdfExtractionMethod.directText;
    if (extractedText.trim().isEmpty) {
      throw const PdfContractLoadException(
        'This PDF appears to be scanned or image-based. Direct text extraction worked only for selectable PDF text in this build.',
      );
    }

    return LoadedContractDocument(
      fileName: file.name,
      extractedText: extractedText,
      extractionMethod: extractionMethod,
    );
  }

  static String _extractText(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(document);
      return extractor.extractText();
    } finally {
      document.dispose();
    }
  }
}

class PdfContractLoadException implements Exception {
  const PdfContractLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
