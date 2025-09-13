// In file: lib/Screens/user/mess_owner/daily_menu_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyMenuView extends StatefulWidget {
  final DateTime selectedDate;

  const DailyMenuView({super.key, required this.selectedDate});

  @override
  State<DailyMenuView> createState() => _DailyMenuViewState();
}

class _DailyMenuViewState extends State<DailyMenuView> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _currentDate;
  bool _isSaving = false;

  bool _isBreakfastAvailable = true;
  bool _isLunchAvailable = true;
  bool _isDinnerAvailable = true;

  final _breakfastItemsController = TextEditingController();
  final _breakfastPriceController = TextEditingController();
  final _breakfastTimeController = TextEditingController();

  final _lunchItemsController = TextEditingController();
  final _lunchPriceController = TextEditingController();
  final _lunchTimeController = TextEditingController();

  final _dinnerItemsController = TextEditingController();
  final _dinnerPriceController = TextEditingController();
  final _dinnerTimeController = TextEditingController();

  // In a real app, this data would be fetched from a shared service or provider
  final Map<String, Map<String, String>> _weeklyMenus = {
    DateFormat('yyyy-MM-dd').format(DateTime.now()): {
      "breakfast": "Poha, Jalebi", "lunch": "Dal Makhani, Rice, Roti", "dinner": "Chole Bhature"
    },
    DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))): {
      "breakfast": "Aloo Paratha, Curd", "lunch": "Rajma Chawal", "dinner": "Paneer Butter Masala, Naan"
    },
  };

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _loadDailyMenuData(_currentDate);
  }

  @override
  void didUpdateWidget(covariant DailyMenuView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent screen passes a new date, reload the data
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _currentDate = widget.selectedDate;
        _loadDailyMenuData(_currentDate);
      });
    }
  }

  void _loadDailyMenuData(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    if (_weeklyMenus.containsKey(dateString)) {
      _breakfastItemsController.text = _weeklyMenus[dateString]!['breakfast'] ?? "";
      _breakfastPriceController.text = "50";
      _breakfastTimeController.text = "08:00 AM - 10:00 AM";
      _lunchItemsController.text = _weeklyMenus[dateString]!['lunch'] ?? "";
      _lunchPriceController.text = "80";
      _lunchTimeController.text = "12:30 PM - 02:30 PM";
      _dinnerItemsController.text = _weeklyMenus[dateString]!['dinner'] ?? "";
      _dinnerPriceController.text = "90";
      _dinnerTimeController.text = "08:00 PM - 10:00 PM";
    } else {
      _clearAllControllers();
    }
  }

  void _clearAllControllers() {
    _breakfastItemsController.clear();
    _breakfastPriceController.clear();
    _breakfastTimeController.clear();
    _lunchItemsController.clear();
    _lunchPriceController.clear();
    _lunchTimeController.clear();
    _dinnerItemsController.clear();
    _dinnerPriceController.clear();
    _dinnerTimeController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _currentDate) {
      setState(() {
        _currentDate = picked;
        _loadDailyMenuData(picked);
      });
    }
  }

  Future<void> _selectTimeRange(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? startTime = await showTimePicker(
        context: context, initialTime: TimeOfDay.now(), helpText: 'Select Start Time');
    if (startTime == null) return;
    final TimeOfDay? endTime = await showTimePicker(
        context: context, initialTime: startTime, helpText: 'Select End Time');
    if (endTime == null) return;
    if (mounted) {
      controller.text = '${startTime.format(context)} - ${endTime.format(context)}';
    }
  }

  Future<void> _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Menu Saved Successfully!"),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  void dispose() {
    _breakfastItemsController.dispose();
    _breakfastPriceController.dispose();
    _breakfastTimeController.dispose();
    _lunchItemsController.dispose();
    _lunchPriceController.dispose();
    _lunchTimeController.dispose();
    _dinnerItemsController.dispose();
    _dinnerPriceController.dispose();
    _dinnerTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('daily'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Editing Menu For",
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(_currentDate),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_month_outlined, color: Colors.blue),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
          _buildMealSection(
            title: "Breakfast",
            icon: Icons.breakfast_dining_outlined,
            iconColor: Colors.orange,
            itemsController: _breakfastItemsController,
            priceController: _breakfastPriceController,
            timeController: _breakfastTimeController,
            isAvailable: _isBreakfastAvailable,
            onAvailabilityChanged: (value) {
              setState(() => _isBreakfastAvailable = value);
            },
          ),
          const SizedBox(height: 24),
          _buildMealSection(
            title: "Lunch",
            icon: Icons.lunch_dining_outlined,
            iconColor: Colors.yellow.shade800,
            itemsController: _lunchItemsController,
            priceController: _lunchPriceController,
            timeController: _lunchTimeController,
            isAvailable: _isLunchAvailable,
            onAvailabilityChanged: (value) {
              setState(() => _isLunchAvailable = value);
            },
          ),
          const SizedBox(height: 24),
          _buildMealSection(
            title: "Dinner",
            icon: Icons.dinner_dining_outlined,
            iconColor: Colors.blue.shade800,
            itemsController: _dinnerItemsController,
            priceController: _dinnerPriceController,
            timeController: _dinnerTimeController,
            isAvailable: _isDinnerAvailable,
            onAvailabilityChanged: (value) {
              setState(() => _isDinnerAvailable = value);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isSaving
                  ? Container()
                  : const Icon(Icons.save_alt_rounded),
              label: _isSaving
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
                  : const Text("Save Menu"),
              onPressed: _isSaving ? null : _saveMenu,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(
      {required String title,
        required IconData icon,
        required Color iconColor,
        required TextEditingController itemsController,
        required TextEditingController priceController,
        required TextEditingController timeController,
        required bool isAvailable,
        required ValueChanged<bool> onAvailabilityChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Switch(
              value: isAvailable,
              onChanged: onAvailabilityChanged,
              activeColor: Colors.green,
            )
          ],
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isAvailable ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !isAvailable,
            child: Column(
              children: [
                TextFormField(
                  controller: itemsController,
                  decoration: _inputDecoration(hintText: "Enter menu items..."),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  validator: (value) =>
                  isAvailable && (value == null || value.isEmpty)
                      ? 'Please enter menu items'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: _inputDecoration(
                            labelText: "Price",
                            prefixIcon: Icons.currency_rupee),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!isAvailable) return null;
                          if (value == null || value.isEmpty)
                            return 'Enter price';
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: timeController,
                        readOnly: true,
                        onTap: () => _selectTimeRange(context, timeController),
                        decoration: _inputDecoration(
                            labelText: "Time",
                            suffixIcon: Icons.access_time_filled),
                        validator: (value) =>
                        isAvailable && (value == null || value.isEmpty)
                            ? 'Please select a time'
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {String? hintText,
        String? labelText,
        IconData? prefixIcon,
        IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
      suffixIcon:
      suffixIcon != null ? Icon(suffixIcon, size: 18, color: Colors.grey) : null,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(height: 0.8),
    );
  }
}