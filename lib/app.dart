// File: lib/app.dart

import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/core/presentation/theme/app_theme.dart';  // Custom theme
import 'package:quan_ly_chi_tieu/core/routing/app_go_router.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router dùng cho GoRouter (thay thế MaterialApp thường)
    return MaterialApp.router(
      title: 'Clean Flutter Demo',      // Tên app
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      theme: AppTheme.lightTheme,       // Áp dụng custom theme
      routerConfig: AppGoRouter.router, // Config routing với GoRouter
    );
  }
}