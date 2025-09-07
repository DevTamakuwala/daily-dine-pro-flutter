// In file: lib/Screens/user/mess_owner/menu_management_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Screen for managing daily and weekly menus for a mess owner.
class MenuManagementScreen extends StatefulWidget {
  // Optional date to pre-select when opening the screen.
  final DateTime? menuDate;
  final Map<dynamic, dynamic> messOwnerData;

  const MenuManagementScreen({super.key, this.menuDate, required this.messOwnerData});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // GlobalKey for the form to handle validation.
  final _formKey = GlobalKey<FormState>();

  // State variable to toggle between daily and weekly view.
  bool _isDailyView = true;
  // State variable to track the currently selected date for menu editing.
  late DateTime _selectedDate;
  // State variable to track the start of the currently displayed week in weekly view.
  late DateTime _startOfWeek;

  // State variables to control the availability of each meal.
  bool _isBreakfastAvailable = true;
  bool _isLunchAvailable = true;
  bool _isDinnerAvailable = true;

  // State variable to show a loading indicator while saving.
  bool _isSaving = false;

  // TODO: Replace with actual data fetching/persistence logic (e.g., API calls, database).
  // Dummy data for weekly menus.
  final Map<String, Map<String, String>> _weeklyMenus = {
    DateFormat('yyyy-MM-dd').format(DateTime.now()): {
      "breakfast": "Poha, Jalebi",
      "lunch": "Dal Makhani, Rice, Roti",
      "dinner": "Chole Bhature"
    },
    DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))): {
      "breakfast": "Aloo Paratha, Curd",
      "lunch": "Rajma Chawal",
      "dinner": "Paneer Butter Masala, Naan"
    },
    DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 2))): {
      "breakfast": "Upma",
      "lunch": "Mix Veg, Roti",
      "dinner": "Kadhai Paneer"
    },
    DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3))): {
      "breakfast": "Idli Sambar",
      "lunch": "Veg Thali",
      "dinner": "Masala Dosa"
    },
  };

  // Text editing controllers for breakfast meal details.
  final _breakfastItemsController = TextEditingController();
  final _breakfastPriceController = TextEditingController();
  final _breakfastTimeController = TextEditingController();

  // Text editing controllers for lunch meal details.
  final _lunchItemsController = TextEditingController();
  final _lunchPriceController = TextEditingController();
  final _lunchTimeController = TextEditingController();

  // Text editing controllers for dinner meal details.
  final _dinnerItemsController = TextEditingController();
  final _dinnerPriceController = TextEditingController();
  final _dinnerTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selected date to the passed date or current date.
    _selectedDate = widget.menuDate ?? DateTime.now();
    // Calculate the start of the week for the selected date.
    _startOfWeek = _getStartOfWeek(_selectedDate);
    // Load menu data for the initially selected date.
    _loadDailyMenuData(_selectedDate);
  }

  // Loads menu data for the given date into the respective text controllers.
  void _loadDailyMenuData(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    // Check if menu data exists for the given date.
    if (_weeklyMenus.containsKey(dateString)) {
      _breakfastItemsController.text =
          _weeklyMenus[dateString]!['breakfast'] ?? "";
      _breakfastPriceController.text = "50"; // TODO: Load actual price
      _breakfastTimeController.text =
      "08:00 AM - 10:00 AM"; // TODO: Load actual time

      _lunchItemsController.text = _weeklyMenus[dateString]!['lunch'] ?? "";
      _lunchPriceController.text = "80"; // TODO: Load actual price
      _lunchTimeController.text = "12:30 PM - 02:30 PM"; // TODO: Load actual time

      _dinnerItemsController.text = _weeklyMenus[dateString]!['dinner'] ?? "";
      _dinnerPriceController.text = "90"; // TODO: Load actual price
      _dinnerTimeController.text = "08:00 PM - 10:00 PM"; // TODO: Load actual time
    } else {
      // If no data exists, clear all controllers.
      _clearAllControllers();
    }
  }

  // Clears all text editing controllers.
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

  @override
  void dispose() {
    // Dispose all text editing controllers to free up resources.
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

  // Calculates the start of the week (Monday) for a given date.
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Changes the displayed week in the weekly view.
  // `weeks` can be positive (next week) or negative (previous week).
  void _changeWeek(int weeks) {
    setState(() {
      _startOfWeek = _startOfWeek.add(Duration(days: weeks * 7));
    });
  }

  // Switches the view to daily menu editing for the selected date.
  void _switchToDailyView(DateTime date) {
    setState(() {
      _isDailyView = true;
      _selectedDate = date;
      _loadDailyMenuData(date); // Load data for the newly selected day.
    });
  }

  // Shows a date picker to allow the user to select a date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _selectedDate, // Allow selecting dates from one year ago.
      lastDate: DateTime.now().add(const Duration(days: 7)),    // Allow selecting dates up to one year in the future.
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadDailyMenuData(picked); // Load menu for the newly picked date.
      });
    }
  }

  // Shows time pickers to allow the user to select a start and end time range.
  Future<void> _selectTimeRange(
      BuildContext context, TextEditingController controller) async {
    // Show time picker for start time.
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Start Time',
    );
    if (startTime == null) return; // User cancelled start time selection.

    // Show time picker for end time.
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime, // Default end time to the selected start time.
      helpText: 'Select End Time',
    );
    if (endTime == null) return; // User cancelled end time selection.

    // Update the controller text if the widget is still mounted.
    if (mounted) {
      controller.text =
      '${startTime.format(context)} - ${endTime.format(context)}';
    }
  }

  // Saves the current menu data.
  // TODO: Implement actual data saving logic (e.g., API call, database update).
  Future<void> _saveMenu() async {
    // Validate the form before saving.
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true); // Show loading indicator.
      // Simulate a network request or saving delay.
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isSaving = false); // Hide loading indicator.

      // Show a success message if the widget is still mounted.
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background for the screen.
      appBar: AppBar(
        title: const Text("Menu Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1, // Subtle shadow below the app bar.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildMenuFormCard(), // Main content card.
      ),
    );
  }

  // Builds the main card containing the tab bar and the form (daily or weekly view).
  Widget _buildMenuFormCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom tab bar to switch between daily and weekly views.
            _CustomTabBar(
              isDailySelected: _isDailyView,
              onTap: (isDaily) {
                setState(() {
                  _isDailyView = isDaily;
                  // If switching to daily view, ensure a date is selected and data loaded.
                  if (isDaily) {
                    _loadDailyMenuData(_selectedDate);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            // AnimatedSwitcher to smoothly transition between daily and weekly views.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isDailyView
                  ? Form(key: _formKey, child: _buildDailyView()) // Show daily view form.
                  : _buildWeeklyView(), // Show weekly view.
            ),
          ],
        ),
      ),
    );
  }

  // Builds the UI for the daily menu editing view.
  Widget _buildDailyView() {
    return Column(
      key: const ValueKey('daily'), // Key for AnimatedSwitcher.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selector section.
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
                      DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
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
        // Breakfast meal section.
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
        // Lunch meal section.
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
        // Dinner meal section.
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
        // Save menu button.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isSaving
                ? Container() // Hide icon when saving
                : const Icon(Icons.save_alt_rounded),
            label: _isSaving
                ? const SizedBox( // Show progress indicator when saving
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
                : const Text("Save Menu"),
            onPressed: _isSaving ? null : _saveMenu, // Disable button when saving.
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Builds the UI for the weekly menu schedule view.
  Widget _buildWeeklyView() {
    final endOfWeek = _startOfWeek.add(const Duration(days: 6));
    return Column(
      key: const ValueKey('weekly'), // Key for AnimatedSwitcher.
      children: [
        // Week navigation row.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeWeek(-1)), // Go to previous week.
            Text(
              "${DateFormat('d MMM').format(_startOfWeek)} - ${DateFormat('d MMM, yyyy').format(endOfWeek)}",
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeWeek(1)), // Go to next week.
          ],
        ),
        const Divider(height: 24),
        // List of day cards for the week.
        ListView.builder(
          shrinkWrap: true, // Important for ListView inside SingleChildScrollView.
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView itself.
          itemCount: 7, // Display 7 days of the week.
          itemBuilder: (context, index) {
            final day = _startOfWeek.add(Duration(days: index));
            final dateString = DateFormat('yyyy-MM-dd').format(day);
            final menu = _weeklyMenus[dateString]; // Get menu for the specific day.
            return _buildDayCard(day: day, menu: menu);
          },
        ),
      ],
    );
  }

  // Builds a card widget to display menu summary for a single day in the weekly view.
  Widget _buildDayCard({required DateTime day, Map<String, String>? menu}) {
    bool isMenuSet = menu != null; // Check if a menu is set for this day.
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
              DateFormat('EEEE, d MMMM').format(day), // Display day and date.
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            isMenuSet
                ? Column( // Display menu items if set.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("B: ${menu['breakfast'] ?? 'N/A'}", // Added null check for safety
                    overflow: TextOverflow.ellipsis, // Prevent long text overflow.
                    style: const TextStyle(color: Colors.grey)),
                Text("L: ${menu['lunch'] ?? 'N/A'}", // Added null check for safety
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
                Text("D: ${menu['dinner'] ?? 'N/A'}", // Added null check for safety
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
              ],
            )
                : const Text("No menu set for this day.", // Display message if no menu is set.
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _switchToDailyView(day), // Switch to daily view to edit/set menu.
                child: Text(isMenuSet ? "EDIT" : "SET MENU"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a section for a specific meal (Breakfast, Lunch, or Dinner).
  Widget _buildMealSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController itemsController,
    required TextEditingController priceController,
    required TextEditingController timeController,
    required bool isAvailable, // Whether the meal is currently available.
    required ValueChanged<bool> onAvailabilityChanged, // Callback when availability changes.
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal title and availability switch.
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
              activeColor: Colors.green, // Green color when active.
            )
          ],
        ),
        const SizedBox(height: 12),
        // AnimatedOpacity and IgnorePointer to enable/disable based on availability.
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isAvailable ? 1.0 : 0.5, // Dim fields if not available.
          child: IgnorePointer(
            ignoring: !isAvailable, // Disable interaction if not available.
            child: Column(
              children: [
                // Text field for menu items.
                TextFormField(
                  controller: itemsController,
                  decoration: _inputDecoration(hintText: "Enter menu items..."),
                  maxLines: 3, // Allow multiple lines for item input.
                  keyboardType: TextInputType.multiline,
                  validator: (value) =>
                  isAvailable && (value == null || value.isEmpty)
                      ? 'Please enter menu items'
                      : null, // Validate only if available.
                ),
                const SizedBox(height: 12),
                // Row for price and time fields.
                Row(
                  children: [
                    // Price field.
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: _inputDecoration(
                            labelText: "Price",
                            prefixIcon: Icons.currency_rupee), // Rupee icon for price.
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!isAvailable) return null; // Validate only if available.
                          if (value == null || value.isEmpty) return 'Enter price';
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Time range field.
                    Expanded(
                      child: TextFormField(
                        controller: timeController,
                        readOnly: true, // Time is selected via picker.
                        onTap: () => _selectTimeRange(context, timeController),
                        decoration: _inputDecoration(
                            labelText: "Time",
                            suffixIcon: Icons.access_time_filled), // Time icon.
                        validator: (value) =>
                        isAvailable && (value == null || value.isEmpty)
                            ? 'Please select a time'
                            : null, // Validate only if available.
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

  // Helper function to create a consistent InputDecoration for TextFormFields.
  InputDecoration _inputDecoration(
      {String? hintText,
        String? labelText,
        IconData? prefixIcon,
        IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, size: 18, color: Colors.grey)
          : null,
      filled: true,
      fillColor: const Color(0xFFF7F7F7), // Light fill color for text fields.
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none, // No border, for a modern look.
      ),
      errorStyle: const TextStyle(height: 0.8), // Adjust error text style.
    );
  }
}

// Custom TabBar widget for switching between "Daily Menu" and "Weekly Schedule".
class _CustomTabBar extends StatelessWidget {
  final bool isDailySelected; // True if "Daily Menu" is selected.
  final ValueChanged<bool> onTap; // Callback when a tab is tapped. `true` for daily, `false` for weekly.

  const _CustomTabBar({required this.isDailySelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // "Daily Menu" button.
      Expanded(
        child: TextButton(
          onPressed: () => onTap(true), // Notify parent that daily tab is selected.
          style: TextButton.styleFrom(
            backgroundColor: isDailySelected ? Colors.blue : Colors.white, // Active/inactive background.
            foregroundColor: isDailySelected ? Colors.white : Colors.black54, // Active/inactive text color.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: isDailySelected ? Colors.blue : Colors.grey.shade300), // Active/inactive border.
            ),
          ),
          child: const Text("Daily Menu"),
        ),
      ),
      const SizedBox(width: 10), // Spacer between buttons.
      // "Weekly Schedule" button.
      Expanded(
        child: TextButton(
          onPressed: () => onTap(false), // Notify parent that weekly tab is selected.
          style: TextButton.styleFrom(
            backgroundColor: !isDailySelected ? Colors.blue : Colors.white, // Active/inactive background.
            foregroundColor: !isDailySelected ? Colors.white : Colors.black54, // Active/inactive text color.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color:
                  !isDailySelected ? Colors.blue : Colors.grey.shade300), // Active/inactive border.
            ),
          ),
          child: const Text("Weekly Schedule"),
        ),
      ),
    ]);
  }
}
