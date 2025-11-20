// In file: lib/Screens/user/mess_owner/weekly_menu_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// TODO: Weekly menu adding
class WeeklyMenuView extends StatefulWidget {
  // Callback to tell the parent screen to switch to the daily view for a specific date.
  final Function(DateTime date) onEditDay;

  const WeeklyMenuView({super.key, required this.onEditDay});

  @override
  State<WeeklyMenuView> createState() => _WeeklyMenuViewState();
}

class _WeeklyMenuViewState extends State<WeeklyMenuView> {
  late DateTime _startOfWeek;

  // In a real app, this data would come from a shared state/provider.
  final Map<String, Map<String, String>> _weeklyMenus = {
    DateFormat('yyyy-MM-dd').format(DateTime.now()): {
      "breakfast": "Poha, Jalebi",
      "lunch": "Rajma Chawal",
      "dinner": "Paneer Tikka Masala"
    },
    DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))): {
      "breakfast": "Aloo Paratha",
      "lunch": "Chole Bhature",
      "dinner": "Veg Biryani"
    },
  };

  @override
  void initState() {
    super.initState();
    _startOfWeek = _getStartOfWeek(DateTime.now());
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _changeWeek(int weeks) {
    setState(() {
      _startOfWeek = _startOfWeek.add(Duration(days: weeks * 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final endOfWeek = _startOfWeek.add(const Duration(days: 6));
    return Column(
      key: const ValueKey('weekly'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeWeek(-1)),
            Text(
              "${DateFormat('d MMM').format(_startOfWeek)} - ${DateFormat('d MMM, yyyy').format(endOfWeek)}",
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeWeek(1)),
          ],
        ),
        const Divider(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7,
          itemBuilder: (context, index) {
            final day = _startOfWeek.add(Duration(days: index));
            final dateString = DateFormat('yyyy-MM-dd').format(day);
            final menu = _weeklyMenus[dateString];
            return _buildDayCard(day: day, menu: menu);
          },
        ),
      ],
    );
  }

  Widget _buildDayCard({required DateTime day, Map<String, String>? menu}) {
    bool isMenuSet = menu != null;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM').format(day),
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            isMenuSet
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("B: ${menu['breakfast'] ?? 'N/A'}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
                Text("L: ${menu['lunch'] ?? 'N/A'}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
                Text("D: ${menu['dinner'] ?? 'N/A'}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
              ],
            )
                : const Text("No menu set for this day.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => widget.onEditDay(day),
                child: Text(isMenuSet ? "EDIT" : "SET MENU"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}