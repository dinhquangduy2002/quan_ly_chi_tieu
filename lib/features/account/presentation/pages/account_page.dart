// File: lib/features/account/presentation/pages/account_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';

class AccountPage extends StatelessWidget {
  final UserEntity user;

  const AccountPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Tài khoản',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ảnh đại diện cố định
              CircleAvatar(
                radius: 45,
                backgroundImage: const AssetImage('assets/images/default_avatar.png'),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 12),
              Text(
                user.email ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${user.uid}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),

              // Danh sách mục cài đặt
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingItem(
                      icon: Icons.settings,
                      title: 'Cài đặt tài khoản',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.notifications_none,
                      title: 'Thông báo',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Giao diện',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.support_agent_outlined,
                      title: 'Liên hệ hỗ trợ',
                      onTap: () {},
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Nút đăng xuất
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            // Không cần context.go(), GoRouter tự redirect về login
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng xuất thất bại!'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
