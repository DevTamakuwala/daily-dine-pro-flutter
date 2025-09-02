import 'dart:convert';

import 'package:dailydine/Screens/Auth/two_factor/enable_two_factor.dart';
import 'package:dailydine/Screens/user/mess_owner/mess_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // CHANGE: Import for date formatting

import '../../credentials/api_url.dart';
import '../../encryption/encrypt_text.dart';
import '../../enums/user_types.dart';
import '../../service/save_shared_preference.dart';
import '../../widgets/build_flip_button.dart';
import '../../widgets/build_submit_button.dart';
import '../../widgets/build_text_form_field.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onFlip;

  const SignupForm({super.key, required this.onFlip});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  // State and controllers from your provided UI
  final _messOwnerFormKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();

  // CHANGE: The default user type is changed to "Customer" to prioritize the more common user type.
  UserType _selectedUserType = UserType.Customer;

  // Mess Owner Controllers
  final _messNameController = TextEditingController();

  // CHANGE: Added separate controllers for first and last name for Mess Owner.
  final _ownerFirstNameController = TextEditingController();
  final _ownerLastNameController = TextEditingController();
  final _addressController = TextEditingController();

  // CHANGE: Added controllers for city, zip code, and state for Mess Owner.
  final _messOwnerCityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _ownerConfirmPasswordController = TextEditingController();

  bool _isOwnerPasswordObscured = true;
  // bool _isOwnerConfirmPasswordObscured = true;
  // bool _isCustomerPasswordObscured = true;
  // bool _isCustomerConfirmPasswordObscured = true;

  // CHANGE: New controller for establishment date picker.
  final _establishmentDateController =
      TextEditingController(); // New controller for establishment date

  // Customer Controllers
  final _customerFirstNameController = TextEditingController();
  final _customerLastNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerPasswordController = TextEditingController();
  final _customerConfirmPasswordController = TextEditingController();

  // Common Controllers
  final _signupPhoneController = TextEditingController();
  final _signupEmailController = TextEditingController();

  @override
  void dispose() {
    _messNameController.dispose();
    _ownerFirstNameController.dispose();
    _ownerLastNameController.dispose();
    _addressController.dispose();
    _messOwnerCityController.dispose();
    _zipCodeController.dispose(); // CHANGE: Dispose zip code controller
    _stateController.dispose(); // CHANGE: Dispose state controller
    _signupPhoneController.dispose();
    _signupEmailController.dispose();
    _customerFirstNameController.dispose();
    _customerLastNameController.dispose();
    _customerPhoneController.dispose();
    _ownerPasswordController.dispose();
    _ownerConfirmPasswordController.dispose();
    _customerPasswordController.dispose();
    _customerConfirmPasswordController.dispose();
    _establishmentDateController
        .dispose(); // CHANGE: Dispose the new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signupForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Create Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ToggleButtons(
          // CHANGE: The order of the toggle buttons is changed to reflect the new default user type.
          isSelected: [
            _selectedUserType == UserType.Customer,
            _selectedUserType == UserType.MessOwner
          ],
          onPressed: (index) {
            setState(() {
              _selectedUserType =
                  index == 0 ? UserType.Customer : UserType.MessOwner;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.orange.shade700,
          color: Colors.orange.shade700,
          borderColor: Colors.orange.shade700,
          selectedBorderColor: Colors.orange.shade700,
          children: const [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Customer")),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Mess Owner")),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          // CHANGE: The default form is changed to the customer form.
          child: _selectedUserType == UserType.Customer
              ? _buildCustomerSubForm()
              : _buildMessOwnerSubForm(),
        ),
        const SizedBox(height: 16),
        buildFlipButton(
            label: "Already have an account? Login", onFlip: widget.onFlip),
      ],
    );
  }

  Widget _buildMessOwnerSubForm() {
    return Form(
      key: _messOwnerFormKey,
      child: Column(
        key: const ValueKey('messOwnerForm'),
        mainAxisSize: MainAxisSize.min,
        children: [
          // CHANGE: First Name and Last Name fields for Mess Owner in a single row.
          Row(
            children: [
              Expanded(
                child: buildTextFormField(
                    controller: _ownerFirstNameController,
                    label: "First Name",
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? "First Name is required" : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextFormField(
                    controller: _ownerLastNameController,
                    label: "Last Name",
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? "Last Name is required" : null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _messNameController,
              label: "Mess Name",
              icon: Icons.storefront,
              validator: (v) => v!.isEmpty ? "Mess Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _addressController,
              label: "Address",
              icon: Icons.location_on_outlined,
              validator: (v) => v!.isEmpty ? "Address is required" : null),
          const SizedBox(height: 12),
          // CHANGE: Added Zip Code text field with onChanged to fetch city/state.
          buildTextFormField(
              controller: _zipCodeController,
              label: "Zip Code",
              icon: Icons.location_on_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty || v.length != 6
                  ? "Enter a valid 6-digit Zip Code"
                  : null,
              onChanged: (value) {
                if (value.length == 6) {
                  _fetchCityStateFromZipCode(value);
                } else {
                  setState(() {
                    _messOwnerCityController.clear();
                    _stateController.clear();
                  });
                }
              }),
          const SizedBox(height: 12),
          // CHANGE: City text field, disabled and populated by _fetchCityStateFromZipCode.
          buildTextFormField(
              controller: _messOwnerCityController,
              label: "City",
              icon: Icons.location_city,
              enabled: false,
              validator: (v) => v!.isEmpty ? "City is required" : null),
          const SizedBox(height: 12),
          // CHANGE: State text field, disabled and populated by _fetchCityStateFromZipCode.
          buildTextFormField(
              controller: _stateController,
              label: "State",
              icon: Icons.location_city,
              enabled: false,
              validator: (v) => v!.isEmpty ? "State is required" : null),
          const SizedBox(height: 12),
          // CHANGE: New TextFormField for Establishment Date with a date picker dialog.
          buildTextFormField(
            controller: _establishmentDateController,
            label: "Establishment Date",
            icon: Icons.calendar_today,
            readOnly: true,
            // Make it read-only so the date picker handles input
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                setState(() {
                  _establishmentDateController.text = formattedDate;
                });
              }
            },
            validator: (v) =>
                v!.isEmpty ? "Establishment Date is required" : null,
          ),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _signupPhoneController,
              label: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v!.length < 10 ? "Enter a valid phone number" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _signupEmailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!)
                  ? "Enter a valid email"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
            controller: _ownerPasswordController,
            label: "Password",
            icon: Icons.lock_outline,
            obscureText: _isOwnerPasswordObscured,
            suffixIcon: _isOwnerPasswordObscured
                ? Icons.visibility_off
                : Icons.visibility,
            onSuffixIconPressed: () {
              setState(() {
                _isOwnerPasswordObscured = !_isOwnerPasswordObscured;
              });
            },
            validator: (v) => v!.length < 6
                ? "Password must be at least 6 characters"
                : null,
          ),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _ownerConfirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v != _ownerPasswordController.text
                  ? "Passwords do not match"
                  : null),
          const SizedBox(height: 20),
          buildSubmitButton(
              label: "Sign Up as Owner",
              onPressed: () async {
                if (_messOwnerFormKey.currentState!.validate()) {
                  await handleMessOwnerSignUp(
                      _ownerFirstNameController.text,
                      _ownerLastNameController.text,
                      _messNameController.text,
                      _addressController.text,
                      _signupEmailController.text,
                      _signupPhoneController.text,
                      _ownerPasswordController.text,
                      context,
                      DateTime.now().toUtc().toIso8601String(),
                      // CHANGE: Pass zip code, city, state, and establishment date.
                      int.parse(_zipCodeController.text),
                      _messOwnerCityController.text,
                      _stateController.text,
                      _establishmentDateController.text);
                }
              }),
        ],
      ),
    );
  }

  Widget _buildCustomerSubForm() {
    return Form(
      key: _customerFormKey,
      child: Column(
        key: const ValueKey('customerForm'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: buildTextFormField(
                    controller: _customerFirstNameController,
                    label: "First Name",
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? "First Name is required" : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextFormField(
                    controller: _customerLastNameController,
                    label: "Last Name",
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? "Last Name is required" : null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerPhoneController,
              label: "Contact no",
              icon: Icons.phone,
              validator: (v) => v!.isEmpty ? "contact no is required" : null,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _signupEmailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!)
                  ? "Enter a valid email"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerPasswordController,
              label: "Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v!.length < 6
                  ? "Password must be at least 6 characters"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerConfirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v != _customerPasswordController.text
                  ? "password does not matching please check"
                  : null),
          const SizedBox(height: 20),
          buildSubmitButton(
              label: "Sign Up as Customer",
              onPressed: () {
                if (_customerFormKey.currentState!.validate()) {
                  handleCustomerSignUp(
                    _customerFirstNameController.text,
                    _customerLastNameController.text,
                    _signupEmailController.text,
                    _customerPhoneController.text,
                    _customerPasswordController.text,
                    context,
                    null,
                    DateTime.now().toUtc().toIso8601String(),
                  );
                }
              }),
        ],
      ),
    );
  }

  /*
  * CHANGE: Function to fetch city and state name from the zip code using a public API.
  */
  Future<void> _fetchCityStateFromZipCode(String zipCode) async {
    final url = Uri.parse("https://api.postalpincode.in/pincode/$zipCode");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isNotEmpty && data[0]['Status'] == "Success") {
          final postOffice = data[0]['PostOffice'][0];
          String district = postOffice['District'];
          String state = postOffice['State'];

          setState(() {
            _messOwnerCityController.text = district;
            _stateController.text = state;
          });
        } else {
          setState(() {
            _messOwnerCityController.clear();
            _stateController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No city/state found for this zip code."),
            ),
          );
        }
      } else {
        setState(() {
          _messOwnerCityController.clear();
          _stateController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to fetch city and state."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _messOwnerCityController.clear();
        _stateController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching city and state: $e"),
        ),
      );
    }
  }

  Future<void> handleCustomerSignUp(
      String fname,
      String lname,
      String email,
      String phone,
      String password,
      BuildContext context,
      DateTime? birthDate,
      String date) async {
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/register';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $encryptedPassword"
      },
      body: jsonEncode({
        "createdBy": 0,
        "createdAt": date,
        "modifiedBy": 0,
        "modifiedAt": date,
        "userId": 0,
        "email": email,
        "password": encryptedPassword,
        "firstName": fname,
        "lastName": lname,
        "phoneNo": phone,
        "role": _selectedUserType.name,
        "active": true,
        "customer": {
          "createdBy": 0,
          "createdAt": date,
          "modifiedBy": 0,
          "modifiedAt": date,
          "customerId": 0,
          "status": "ACTIVE",
          "dateOfBirth": birthDate ?? "",
        }
      }),
    );

    if (response.statusCode == 201) {
      saveTokenId(response.body);
      saveUserRole(_selectedUserType.name);
      saveEmail(email);
      savePassword(password);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) => EnableTwoFactor(idToken: response.body),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  //Mess owner sign up
  Future<void> handleMessOwnerSignUp(
      String fname,
      String lname,
      String messName,
      String address,
      String email,
      String phone,
      String password,
      BuildContext context,
      String date,
      // CHANGE: Added parameters for zip code, city, state, and establishment date.
      int zipcode,
      String city,
      String state,
      String establishmentDate) async {
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/register';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "createdBy": 0,
        "createdAt": date,
        "modifiedBy": 0,
        "modifiedAt": date,
        "userId": 0,
        "email": email,
        "password": encryptedPassword,
        "firstName": fname,
        "lastName": lname,
        "phoneNo": phone,
        "role": _selectedUserType.name,
        "active": false,
        "mess": {
          "createdBy": 0,
          "createdAt": date,
          "modifiedBy": 0,
          "modifiedAt": date,
          "messId": 0,
          "messName": messName,
          "address": address,
          "city": city,
          "state": state,
          "zipCode": zipcode,
          "messPhoneNo": phone,
          "establisheDate": establishmentDate, // Use the new establishmentDate
        },
        "customer": null
      }),
    );

    if (response.statusCode == 201) {
      saveTokenId(response.body);
      saveUserRole(_selectedUserType.name);
      saveEmail(email);
      savePassword(password);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) => MessDashboardScreen(token: response.body),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }
}
