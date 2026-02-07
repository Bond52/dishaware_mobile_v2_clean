import 'package:flutter/material.dart';

import '../theme/da_colors.dart';
import 'home_screen.dart';
import 'explorer_screen.dart';
import 'favorites_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    ExplorerScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: DAColors.mutedForeground,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
