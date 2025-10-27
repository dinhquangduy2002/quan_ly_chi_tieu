// File: lib/main.dart

// Import các package cần thiết
import 'package:firebase_core/firebase_core.dart';  // Firebase core
import 'package:flutter/material.dart';              // Flutter UI framework
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Biến môi trường
import 'app.dart';                                   // App chính
import 'core/config/firebase_env.dart';              // Config Firebase

Future<void> main() async {
  // Đảm bảo Flutter engine đã khởi tạo trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized();

  // Load biến môi trường từ file .env
  await dotenv.load(fileName: ".env");

  // Khởi tạo Firebase với config từ biến môi trường
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseEnv.apiKey,                    // API key để gọi Firebase services
      appId: FirebaseEnv.appId,                      // App ID của Firebase project
      messagingSenderId: FirebaseEnv.messagingSenderId, // ID để gửi notification
      projectId: FirebaseEnv.projectId,              // Project ID trên Firebase console
      authDomain: FirebaseEnv.authDomain,            // Domain cho authentication
      storageBucket: FirebaseEnv.storageBucket,      // Bucket cho file storage
      measurementId: FirebaseEnv.measurementId,      // ID cho Google Analytics
    ),
  );

  // Chạy ứng dụng Flutter
  runApp(const MyApp());
}