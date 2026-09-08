import 'package:flutter/widgets.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/l10n/app_localizations.dart';

abstract final class Fmt {
  /// Localizaciones según el idioma elegido en la app. Se resuelve perezoso
  /// para que los formateadores sirvan también fuera del árbol de widgets
  /// (notificaciones, widgets de Android), igual que hacen esos servicios.
  static AppLocalizations get _l {
    String code = 'es';
    try {
      code = AppStorage.instance.localeCode ?? 'es';
    } catch (_) {}
    return lookupAppLocalizations(Locale(code));
  }

  static String currency(double v, [String simbolo = 'S/']) {
    final negativo = v < 0;
    final abs = v.abs();
    final entero = abs.truncate();
    final decimales = ((abs - entero) * 100).round();
    final enteroStr = entero.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final s = '$simbolo $enteroStr.${decimales.toString().padLeft(2, '0')}';
    return negativo ? '-$s' : s;
  }

  static const _dayKeys = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static const _monthKeys = [
    '',
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];
  static String dayLabel(int idDia) =>
      idDia >= 1 && idDia <= 7 ? _l.weekdayFull(_dayKeys[idDia]) : '';
  static String shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
      '${_l.monthShort(_monthKeys[d.month])} ${d.year}';
  static String time(String rawHm, {required bool h24}) {
    final parts = rawHm.split(':');
    if (parts.length < 2) return rawHm;
    final cleanHm = '${parts[0]}:${parts[1]}';
    if (h24) return cleanHm;
    final h = int.tryParse(parts[0]);
    final m = parts[1];
    if (h == null) return rawHm;
    final period = h >= 12 ? 'p.m.' : 'a.m.';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh:$m $period';
  }

  static String fullDate(DateTime d) =>
      '${_l.weekdayShort(_dayKeys[d.weekday])}, ${d.day} '
      '${_l.monthShort(_monthKeys[d.month])}';

  static String greeting(DateTime now) {
    final h = now.hour;
    final period = h < 12
        ? 'morning'
        : h < 19
        ? 'afternoon'
        : 'evening';
    return _l.timeGreeting(period);
  }

  static String firstName(String full) {
    final parts = full
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length >= 3) return parts[2];
    if (parts.length == 2) return parts[1];
    return full;
  }

  static String initials(String s) {
    final p = s
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
    return (p.first.substring(0, 1) + p.last.substring(0, 1)).toUpperCase();
  }

  static Map<String, String?> parseAula(String rawAula) {
    final clean = rawAula.trim();
    if (clean.contains(' ')) {
      final idx = clean.indexOf(' ');
      if (idx > 0 && idx < clean.length - 1) {
        final pab = clean.substring(0, idx).trim();
        final aul = clean.substring(idx + 1).trim();
        final isSingleLetter = RegExp(r'^[a-zA-Z]$').hasMatch(pab);
        final isRoman = RegExp(r'^[iIvVxX]+$').hasMatch(pab);
        if (isSingleLetter || isRoman) {
          if (pab.isNotEmpty && aul.isNotEmpty) {
            return {'pabellon': pab, 'aula': aul};
          }
        }
      }
    }
    return {'pabellon': null, 'aula': clean.isEmpty ? null : clean};
  }

  static String formatAula(String rawAula) {
    if (rawAula.contains('/')) {
      return rawAula.split('/').map((e) => formatAula(e.trim())).join(' / ');
    }
    final parsed = parseAula(rawAula);
    final pab = parsed['pabellon'];
    final aul = cleanRoom(rawAula);
    if (pab != null && aul.isNotEmpty) {
      return 'Pabellón $pab - Aula $aul';
    }
    if (aul.isEmpty) return '—';
    if (RegExp(r'^(LAB|LABORATORIO)', caseSensitive: false).hasMatch(rawAula.trim())) {
      return 'Laboratorio - $aul';
    }
    return aul;
  }

  static String cleanBuilding(String raw) {
    var s = raw.replaceAll(RegExp(r'^(PABELLON|PABELLÓN)\s*_?\s*', caseSensitive: false), '').trim();
    if (s.isEmpty) return raw;
    return s;
  }

  static String cleanRoom(String raw) {
    final parsed = parseAula(raw);
    String s = parsed['aula'] ?? raw;
    s = s.replaceAll(RegExp(r'^(LAB|LABORATORIO)\s*_?\s*', caseSensitive: false), '').trim();
    if (s.isEmpty) return raw;
    return s;
  }
}
