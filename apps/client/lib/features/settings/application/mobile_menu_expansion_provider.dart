import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last expanded top-level Menu accordion section.
final mobileMenuExpandedSectionProvider =
    NotifierProvider<MobileMenuExpansionNotifier, String?>(
      MobileMenuExpansionNotifier.new,
    );

class MobileMenuExpansionNotifier extends Notifier<String?> {
  @override
  String? build() {
    unawaited(_load());
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(StorageKeys.mobileMenuExpandedSection);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> setExpanded(String? sectionId) async {
    state = sectionId;
    final prefs = await SharedPreferences.getInstance();
    if (sectionId == null || sectionId.isEmpty) {
      await prefs.remove(StorageKeys.mobileMenuExpandedSection);
      return;
    }
    await prefs.setString(StorageKeys.mobileMenuExpandedSection, sectionId);
  }
}
