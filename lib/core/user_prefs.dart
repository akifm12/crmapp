import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything personal that lives on the device (works without an account).
class UserPrefs {
  final bool loaded;
  final bool onboarded;
  final String? sector;
  final ThemeMode themeMode;
  final Set<String> doneKeys; // "<deadlineId>:<yyyy-MM-dd>" = cycle completed
  final int? healthScore;
  final DateTime? healthDate;
  final Set<String> checklist; // "<sector>:<item>" ticked document items
  final Set<int> bookmarks; // news ids
  final bool remindersOn;

  const UserPrefs({
    this.loaded = false,
    this.onboarded = false,
    this.sector,
    this.themeMode = ThemeMode.system,
    this.doneKeys = const {},
    this.healthScore,
    this.healthDate,
    this.checklist = const {},
    this.bookmarks = const {},
    this.remindersOn = false,
  });

  UserPrefs copyWith({
    bool? onboarded,
    String? sector,
    bool clearSector = false,
    ThemeMode? themeMode,
    Set<String>? doneKeys,
    int? healthScore,
    DateTime? healthDate,
    Set<String>? checklist,
    Set<int>? bookmarks,
    bool? remindersOn,
  }) =>
      UserPrefs(
        loaded: loaded,
        onboarded: onboarded ?? this.onboarded,
        sector: clearSector ? null : (sector ?? this.sector),
        themeMode: themeMode ?? this.themeMode,
        doneKeys: doneKeys ?? this.doneKeys,
        healthScore: healthScore ?? this.healthScore,
        healthDate: healthDate ?? this.healthDate,
        checklist: checklist ?? this.checklist,
        bookmarks: bookmarks ?? this.bookmarks,
        remindersOn: remindersOn ?? this.remindersOn,
      );
}

class UserPrefsNotifier extends StateNotifier<UserPrefs> {
  UserPrefsNotifier() : super(const UserPrefs()) {
    _load();
  }

  SharedPreferences? _sp;

  Future<SharedPreferences> get _prefs async => _sp ??= await SharedPreferences.getInstance();

  Future<void> _load() async {
    final sp = await _prefs;
    state = UserPrefs(
      loaded: true,
      onboarded: sp.getBool('onboarded') ?? false,
      sector: sp.getString('sector'),
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == sp.getString('theme'),
        orElse: () => ThemeMode.system,
      ),
      doneKeys: (sp.getStringList('done') ?? const []).toSet(),
      healthScore: sp.getInt('health_score'),
      healthDate: DateTime.tryParse(sp.getString('health_date') ?? ''),
      checklist: (sp.getStringList('checklist') ?? const []).toSet(),
      bookmarks: (jsonDecode(sp.getString('bookmarks') ?? '[]') as List).cast<int>().toSet(),
      remindersOn: sp.getBool('reminders') ?? false,
    );
  }

  /// Pass null to mean "all sectors / skip".
  Future<void> setSector(String? sector) async {
    state = state.copyWith(sector: sector, clearSector: sector == null, onboarded: true);
    final sp = await _prefs;
    await sp.setBool('onboarded', true);
    if (sector == null) {
      await sp.remove('sector');
    } else {
      await sp.setString('sector', sector);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await (await _prefs).setString('theme', mode.name);
  }

  Future<void> toggleDone(String key) async {
    final next = {...state.doneKeys};
    if (!next.add(key)) next.remove(key);
    state = state.copyWith(doneKeys: next);
    await (await _prefs).setStringList('done', next.toList());
  }

  Future<void> saveHealth(int score) async {
    final now = DateTime.now();
    state = state.copyWith(healthScore: score, healthDate: now);
    final sp = await _prefs;
    await sp.setInt('health_score', score);
    await sp.setString('health_date', now.toIso8601String());
  }

  Future<void> toggleChecklist(String key) async {
    final next = {...state.checklist};
    if (!next.add(key)) next.remove(key);
    state = state.copyWith(checklist: next);
    await (await _prefs).setStringList('checklist', next.toList());
  }

  Future<void> setReminders(bool on) async {
    state = state.copyWith(remindersOn: on);
    await (await _prefs).setBool('reminders', on);
  }

  Future<void> toggleBookmark(int newsId) async {
    final next = {...state.bookmarks};
    if (!next.add(newsId)) next.remove(newsId);
    state = state.copyWith(bookmarks: next);
    await (await _prefs).setString('bookmarks', jsonEncode(next.toList()));
  }
}

final userPrefsProvider = StateNotifierProvider<UserPrefsNotifier, UserPrefs>((ref) => UserPrefsNotifier());

/// Sector keys mirror SectorConfig::sectors() on the API.
const kSectors = <String, ({String label, String short, IconData icon})>{
  'gold': (label: 'Precious Metals & Stones (Gold)', short: 'Gold & Jewellery', icon: Icons.diamond_outlined),
  'real_estate': (label: 'Real Estate Brokers & Agents', short: 'Real Estate', icon: Icons.apartment_outlined),
  'company_services': (label: 'Company Service Providers (CSPs)', short: 'Company Services', icon: Icons.business_center_outlined),
  'accounting': (label: 'Accountants & Auditors', short: 'Accounting & Audit', icon: Icons.calculate_outlined),
  'other': (label: 'Other DNFBP', short: 'Other DNFBP', icon: Icons.domain_outlined),
};
