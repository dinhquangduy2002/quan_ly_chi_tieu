// File: lib/core/config/firebase_env.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';  // Environment variables

class FirebaseEnv {
  // Lấy API Key từ .env file, nếu không có thì trả về empty string
  static String get apiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  // Lấy App ID từ .env file
  static String get appId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // Lấy Messaging Sender ID từ .env file
  static String get messagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  // Lấy Project ID từ .env file
  static String get projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  // Lấy Auth Domain từ .env file
  static String get authDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  // Lấy Storage Bucket từ .env file
  static String get storageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  // Lấy Measurement ID từ .env file (cho Google Analytics)
  static String get measurementId => dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';
}