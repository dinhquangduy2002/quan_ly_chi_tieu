// File: lib/core/routing/go_router_refresh_change.dart

import 'dart:async';
import 'package:flutter/material.dart';

// Class này giúp GoRouter lắng nghe stream và refresh khi có thay đổi
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;  // Subscription để quản lý stream

  // Constructor: nhận 1 stream và lắng nghe thay đổi
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Khi stream có data mới, gọi notifyListeners() để GoRouter refresh
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();  // Hủy subscription khi không dùng nữa để tránh memory leak
    super.dispose();
  }
}