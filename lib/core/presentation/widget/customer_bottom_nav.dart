// File: lib/core/presentation/widget/customer_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quan_ly_chi_tieu/core/routing/app_routes.dart';
import '../theme/app_colors.dart';

class CustomerBottomNav extends StatefulWidget {
  final int initialIndex;
  const CustomerBottomNav({super.key, required this.initialIndex});

  @override
  State<CustomerBottomNav> createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Home Tab
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                index: 0,
              ),

              // Transactions Tab
              _buildNavItem(
                icon: Icons.credit_card_outlined,
                activeIcon: Icons.credit_card,
                label: 'Giao dịch',
                index: 1,
              ),

              // Add Button - FAB Style (TO VÀ NỔI BẬT)
              _buildAddButton(),

              // Statistics Tab
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Thống kê',
                index: 3,
              ),

              // Profile Tab
              _buildNavItem(
                icon: Icons.person_outlined,
                activeIcon: Icons.person,
                label: 'Tài khoản',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Normal Nav Item
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(context, index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.bottomNavSelected : AppColors.bottomNavUnselected,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.bottomNavSelected : AppColors.bottomNavUnselected,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add Button - FAB Style (TO VÀ NỔI BẬT)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(context, 2),
      child: Container(
        width: 56, // TO hơn các icon khác
        height: 56, // TO hơn các icon khác
        decoration: BoxDecoration(
          color: AppColors.primary, // Màu chính nổi bật
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28, // Icon to hơn
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.transactions);
        break;
      case 2:
        context.go(AppRoutes.addTransaction);
        break;
      case 3:
        context.go(AppRoutes.statistics);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}