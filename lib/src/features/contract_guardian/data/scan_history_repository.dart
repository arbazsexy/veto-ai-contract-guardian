import 'package:shared_preferences/shared_preferences.dart';
import 'package:veto_ai/src/features/contract_guardian/data/saved_scan.dart';

class ScanHistoryRepository {
  static const _storageKey = 'contract_guardian_recent_scans';
  static const _maxItems = 8;

  Future<List<SavedScan>> loadScans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      return SavedScan.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  Future<List<SavedScan>> saveScan(SavedScan scan) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadScans();
    final next = [
      scan,
      ...existing.where((item) => item.contractText != scan.contractText),
    ].take(_maxItems).toList();

    await prefs.setString(_storageKey, SavedScan.encodeList(next));
    return next;
  }

  Future<List<SavedScan>> removeScan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadScans();
    final next = existing.where((scan) => scan.id != id).toList();
    await prefs.setString(_storageKey, SavedScan.encodeList(next));
    return next;
  }
}
