import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// class AppDateUtils {
//   static final DateFormat fullDateTimeFr = DateFormat("d MMMM y 'à' HH'h'mm", 'fr');
//   static final DateFormat shortDateFr = DateFormat("d MMM y", 'fr');
//   static final DateFormat timeFr = DateFormat("HH'h'mm", 'fr');

//   static Future<void> init() async {
//     await initializeDateFormatting('fr', null);
//   }

//   static String formatDate(String isoDate) {
//     try {
//       final DateTime parsed = DateTime.parse(isoDate);
//       return shortDateFr.format(parsed);
//     } catch (_) {
//       return isoDate;
//     }
//   }
// }

class AppDateUtils {
  static final DateFormat fullDateTimeFr = DateFormat("d MMMM y 'à' HH'h'mm", 'fr');
  static final DateFormat shortDateFr = DateFormat("d MMM y", 'fr');
  static final DateFormat timeFr = DateFormat("HH'h'mm", 'fr');

  static Future<void> init() async {
    await initializeDateFormatting('fr', null);
  }

  static String formatDate(String isoDate) {
    try {
      final DateTime parsed = DateTime.parse(isoDate);
      return shortDateFr.format(parsed);
    } catch (_) {
      return isoDate;
    }
  }

  /// Parse une date "YYYY-MM-DD..." en ignorant tout fuseau horaire,
  /// pour éviter les décalages de ±1 jour dus à la conversion UTC/local.
  static DateTime? parseDateOnly(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString();
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(str);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}