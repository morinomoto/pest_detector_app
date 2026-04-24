import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';
import 'add_item_screen.dart';

class MainNavigation extends StatefulWidget {
  final String role;

  const MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  @override
  Widget build(BuildContext context) {

    final screens = [
      HomeScreen(role: widget.role),
      const FavoritesScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: screens[index],

      // ⭐中央＋ボタン（Add Item）
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ⭐バランス調整済みBottomNav
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // 左：Home + Favorites
              Row(
                children: [

                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => setState(() => index = 0),
                    color: index == 0 ? Colors.blue : Colors.grey,
                  ),

                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () => setState(() => index = 1),
                    color: index == 1 ? Colors.blue : Colors.grey,
                  ),
                ],
              ),

              // 中央スペース（FAB用）
              const SizedBox(width: 40),

              // 右：Account
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => setState(() => index = 2),
                color: index == 2 ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}