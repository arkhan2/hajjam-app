import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_appointments_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Keep both screens persistent using IndexedStack
  late final List<Widget> _screens;
  final GlobalKey _appointmentsScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      MyAppointmentsScreen(key: _appointmentsScreenKey),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Ensure appointments refresh whenever the tab is shown
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = _appointmentsScreenKey.currentState;
        try {
          // ignore: avoid_dynamic_calls
          (state as dynamic).refreshAppointments();
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withAlpha(25),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.calendar_today_rounded,
                  activeIcon: Icons.calendar_today_rounded,
                  label: 'Appointments',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.person_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style:
                  theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(153),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ) ??
                  const TextStyle(),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
