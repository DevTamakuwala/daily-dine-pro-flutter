// In file: lib/Screens/user/mess_owner/menu_management_screen.dart

import 'package:flutter/material.dart';
import 'mess_management/daily_menu_view.dart'; // Import the new daily view
import 'mess_management/weekly_menu_view.dart'; // Import the new weekly view

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  bool _isDailyView = true;
  DateTime _selectedDateForDailyView = DateTime.now();

  // Callback function to be passed to the weekly view
  void _switchToDailyView(DateTime date) {
    setState(() {
      _isDailyView = true;
      _selectedDateForDailyView = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Menu Management"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _CustomTabBar(
                  isDailySelected: _isDailyView,
                  onTap: (isDaily) {
                    setState(() {
                      _isDailyView = isDaily;
                    });
                  },
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isDailyView
                      ? DailyMenuView(key: ValueKey(_selectedDateForDailyView), selectedDate: _selectedDateForDailyView)
                      : WeeklyMenuView(onEditDay: _switchToDailyView),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom TabBar widget can remain in this file or be moved to its own file.
class _CustomTabBar extends StatelessWidget {
  final bool isDailySelected;
  final ValueChanged<bool> onTap;

  const _CustomTabBar({required this.isDailySelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextButton(
          onPressed: () => onTap(true),
          style: TextButton.styleFrom(
            backgroundColor: isDailySelected ? Colors.blue : Colors.white,
            foregroundColor: isDailySelected ? Colors.white : Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color:
                  isDailySelected ? Colors.blue : Colors.grey.shade300),
            ),
          ),
          child: const Text("Daily Menu"),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: TextButton(
          onPressed: () => onTap(false),
          style: TextButton.styleFrom(
            backgroundColor: !isDailySelected ? Colors.blue : Colors.white,
            foregroundColor: !isDailySelected ? Colors.white : Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color:
                  !isDailySelected ? Colors.blue : Colors.grey.shade300),
            ),
          ),
          child: const Text("Weekly Schedule"),
        ),
      ),
    ]);
  }
}