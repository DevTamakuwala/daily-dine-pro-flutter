// In file: lib/Screens/user/mess_owner/daily_menu_view.dart

import 'dart:convert';

import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../credentials/api_url.dart';

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

  int _breakfastId = 0;
  int _lunchId = 0;
  int _dinnerId = 0;

  final _breakfastItemsController = TextEditingController();
  final _breakfastPriceController = TextEditingController();
  final _breakfastTimeController = TextEditingController();

  final _lunchItemsController = TextEditingController();
  final _lunchPriceController = TextEditingController();
  final _lunchTimeController = TextEditingController();

  final _dinnerItemsController = TextEditingController();
  final _dinnerPriceController = TextEditingController();
  final _dinnerTimeController = TextEditingController();

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

  // Loading menu from the data if exist
  Future<void> _loadDailyMenuData(DateTime date) async {

    DateTime dateTime = date;

    // Fetching firebase auth token and mess owner data from the shared preference
    String? token = await getTokenId();
    String? messData = await getMessData();
    while (token == null && messData == null) {
      token = await getTokenId();
      messData = await getMessData();
    }

    // Fetching mess id from the mess owner data
    int id = jsonDecode(messData!)["mess"]["messId"];

    // API URL to fetch the menu of the selected date if exist in the table
    String apiUrl =
        '${url}menu/mess/$id/date/${DateFormat('dd-MM-yyyy').format(dateTime)}';

    // Making an API call to fetch the menu data
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      // If there is a data in tha database for selected date then load the data
      // Make it Iterable to access the data
      Iterable responses = jsonDecode(response.body);

      for (var response in responses) {
        // If breakfast is available then load the data
        if (response["mealType"] == "BREAKFAST") {
          _breakfastId = response["id"];
          _isBreakfastAvailable = true;
          _breakfastItemsController.text = response["description"];
          _breakfastPriceController.text = response["price"].toString();
          _breakfastTimeController.text =
              "${response['availableFrom'].toString()} - ${response['availableTill'].toString()}";
        }

        // If lunch is available then load the data
        if (response["mealType"] == "LUNCH") {
          _lunchId = response["id"];
          _isLunchAvailable = true;
          _lunchItemsController.text = response["description"];
          _lunchPriceController.text = response["price"].toString();
          _lunchTimeController.text =
              "${response['availableFrom'].toString()} - ${response['availableTill'].toString()}";
        }

        // If dinner is available then load the data
        if (response["mealType"] == "DINNER") {
          _dinnerId = response["id"];
          _isDinnerAvailable = true;
          _dinnerItemsController.text = response["description"];
          _dinnerPriceController.text = response["price"].toString();
          _dinnerTimeController.text =
              "${response['availableFrom'].toString()} - ${response['availableTill'].toString()}";
        }
      }
    } else {
      // If the data is not available then clear all the controllers and set the availability to false
      _clearAllControllers();
    }
  }

  // Clearing all the controllers and setting the availability to false
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
    _isBreakfastAvailable = false;
    _isLunchAvailable = false;
    _isDinnerAvailable = false;
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
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Select Start Time');
    if (startTime == null) return;
    final TimeOfDay? endTime = await showTimePicker(
        context: context, initialTime: startTime, helpText: 'Select End Time');
    if (endTime == null) return;
    if (mounted) {
      controller.text =
          '${startTime.format(context)} - ${endTime.format(context)}';
    }
  }

  // Save the menu items to the database
  Future<void> _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      // Fetching firebase auth token and mess owner data from the shared preference
      String? token = await getTokenId();
      String? messData = await getMessData();
      while (token == null && messData == null) {
        token = await getTokenId();
        messData = await getMessData();
      }

      // Fetching mess id from the mess owner data
      int id = jsonDecode(messData!)["mess"]["messId"];

      // If breakfast or lunch or dinner id is 0 means those items are not
      // in data so we need to add them to the database
      if (_breakfastId == 0 || _lunchId == 0 || _dinnerId == 0) {
        // API URL to add the menu items to the database
        String apiUrl = '${url}menu/mess/$id';
        http.Response response;

        // Making an API call to add the menu items to the database
        // If breakfast set to true means available then add the data to the database
        if (_isBreakfastAvailable) {
          response = await http.post(
            Uri.parse(apiUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({
              "id": 0,
              "date": DateFormat('dd-MM-yyyy').format(_currentDate),
              "mealType": "BREAKFAST",
              "description": _breakfastItemsController.text,
              "availableFrom": _breakfastTimeController.text.split("-")[0],
              "availableTill": _breakfastTimeController.text.split("-")[1],
              "price": _breakfastPriceController.text,
              "expired": false
            }),
          );

          // If the data stored successfully in the database then show a snackbar
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Breakfast Saved Successfully!"),
                  backgroundColor: Colors.green),
            );
          }
        }

        // If lunch set to true means available then add the data to the database
        if (_isLunchAvailable) {
          response = await http.post(
            Uri.parse(apiUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({
              "id": 0,
              "date": DateFormat('dd-MM-yyyy').format(_currentDate),
              "mealType": "LUNCH",
              "description": _lunchItemsController.text,
              "availableFrom": _lunchTimeController.text.split("-")[0],
              "availableTill": _lunchTimeController.text.split("-")[1],
              "price": _lunchPriceController.text,
              "expired": false
            }),
          );

          // If the data stored successfully in the database then show a snackbar
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Lunch Saved Successfully!"),
                  backgroundColor: Colors.green),
            );
          }
        }

        // If dinner set to true means available then add the data to the database
        if (_isDinnerAvailable) {
          response = await http.post(
            Uri.parse(apiUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({
              "id": 0,
              "date": DateFormat('dd-MM-yyyy').format(_currentDate),
              "mealType": "DINNER",
              "description": _dinnerItemsController.text,
              "availableFrom": _dinnerTimeController.text.split("-")[0],
              "availableTill": _dinnerTimeController.text.split("-")[1],
              "price": _dinnerPriceController.text,
              "expired": false
            }),
          );

          // If the data stored successfully in the database then show a snackbar
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Dinner Saved Successfully!"),
                  backgroundColor: Colors.green),
            );
          }
        }
      } else {
        // If the breakfast or lunch or dinner has id then we need to update the data
        //TODO: Update the menu items
      }
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
      child: Stack(
        children: [
          if (_isSaving)
            Container(
              decoration: BoxDecoration(color: Colors.grey),
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          Column(
            // key: const ValueKey('daily'),
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
                            DateFormat('EEEE, d MMMM yyyy')
                                .format(_currentDate),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_month_outlined,
                          color: Colors.blue),
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
          )
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
                          if (value == null || value.isEmpty) {
                            return 'Enter price';
                          }
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
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, size: 18, color: Colors.grey)
          : null,
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
