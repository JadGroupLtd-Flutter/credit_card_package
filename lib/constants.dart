import 'package:intl/intl.dart';

class AppConstants {
  static const double webBreakPoint = 800;
  static const double creditCardAspectRatio = 0.5714;
  static const double creditCardPadding = 16;
}

extension StringExtensions on String {
  bool isRTL() => Bidi.detectRtlDirectionality(this);
}


