import 'package:flutter/material.dart';

class IconUtils {
  /// Returns a constant IconData for a given codepoint.
  /// This is used to avoid non-constant IconData invocations which break icon tree shaking.
  static IconData getIconData(int codePoint) {
    // Map of all icons used in transactions and quick actions
    final iconMap = <int, IconData>{
      Icons.account_balance_wallet_rounded.codePoint:
          Icons.account_balance_wallet_rounded,
      Icons.file_download_outlined.codePoint: Icons.file_download_outlined,
      Icons.currency_exchange_rounded.codePoint:
          Icons.currency_exchange_rounded,
      Icons.send_rounded.codePoint: Icons.send_rounded,
      Icons.bolt_rounded.codePoint: Icons.bolt_rounded,
      Icons.water_drop_rounded.codePoint: Icons.water_drop_rounded,
      Icons.wifi_rounded.codePoint: Icons.wifi_rounded,
      Icons.gavel_rounded.codePoint: Icons.gavel_rounded,
      Icons.confirmation_number_rounded.codePoint:
          Icons.confirmation_number_rounded,
      Icons.flight_takeoff_rounded.codePoint: Icons.flight_takeoff_rounded,
      Icons.directions_bus_rounded.codePoint: Icons.directions_bus_rounded,
      Icons.qr_code_scanner_rounded.codePoint: Icons.qr_code_scanner_rounded,
      Icons.add_circle_rounded.codePoint: Icons.add_circle_rounded,
      Icons.movie_rounded.codePoint: Icons.movie_rounded,
      Icons.account_balance_rounded.codePoint: Icons.account_balance_rounded,
      Icons.restaurant_rounded.codePoint: Icons.restaurant_rounded,
      Icons.shopping_bag_rounded.codePoint: Icons.shopping_bag_rounded,
      Icons.celebration_rounded.codePoint: Icons.celebration_rounded,
      Icons.receipt_long_rounded.codePoint: Icons.receipt_long_rounded,
    };

    return iconMap[codePoint] ?? Icons.receipt_long_rounded;
  }
}
