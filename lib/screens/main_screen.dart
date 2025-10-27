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
  final GlobalKey<State<MyAppointmentsScreen>> _appointmentsKey =
      GlobalKey<State<MyAppointmentsScreen>>();

  // Keep both screens persistent using IndexedStack
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onBookingSuccess: refreshAppointments),
      MyAppointmentsScreen(key: _appointmentsKey),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void refreshAppointments() {
    // Cast to the specific state type to access the refresh method
    final appointmentsState = _appointmentsKey.currentState;
    if (appointmentsState != null && appointmentsState.mounted) {
      // Call the refresh method if it exists
      (appointmentsState as dynamic).refreshAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
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
              ? theme.colorScheme.primary.withOpacity(0.1)
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
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style:
                  theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
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
