// In file: lib/Screens/user/mess_owner/edit_profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../widgets/build_text_form_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers are created here. In a StatelessWidget, they are recreated on every build.
    final _formKey = GlobalKey<FormState>();
    final _firstNameController = TextEditingController(text: "Priya");
    final _lastNameController = TextEditingController(text: "Sharma");
    final _emailController = TextEditingController(text: "annapurna.mess@example.com");
    final _phoneController = TextEditingController(text: "+91 98765 43210");
    final _messNameController = TextEditingController(text: "Annapurna Mess");
    final _addressController = TextEditingController(text: "123 Sunshine Apts, Kothrud");
    final _zipCodeController = TextEditingController(text: "411038");
    final _cityController = TextEditingController(text: "Pune");
    final _stateController = TextEditingController(text: "Maharashtra");
    final _establishmentDateController = TextEditingController(text: "2020-05-15");

    // Logic to fetch city/state from ZIP code
    Future<void> _fetchCityStateFromZipCode(String zipCode) async {
      if (zipCode.length != 6) return;
      final url = Uri.parse("https://api.postalpincode.in/pincode/$zipCode");
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          if (data.isNotEmpty && data[0]['Status'] == "Success") {
            final postOffice = data[0]['PostOffice'][0];
            // In a StatelessWidget, we can't use setState, so we just update controllers.
            // This won't rebuild the widget if it's managed by a parent state.
            _cityController.text = postOffice['District'];
            _stateController.text = postOffice['State'];
          }
        }
      } catch (e) {
        // Handle error
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 24),
              _buildSectionCard("Personal Details", [
                Row(
                  children: [
                    Expanded(
                        child: buildTextFormField(
                            controller: _firstNameController,
                            label: "First Name",
                            icon: Icons.person_outline)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: buildTextFormField(
                            controller: _lastNameController,
                            label: "Last Name",
                            icon: Icons.person_outline)),
                  ],
                ),
                const SizedBox(height: 16),
                buildTextFormField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    enabled: false), // Email is not editable
                const SizedBox(height: 16),
                buildTextFormField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
              ]),
              const SizedBox(height: 24),
              _buildSectionCard("Business Details", [
                buildTextFormField(
                    controller: _messNameController,
                    label: "Mess Name",
                    icon: Icons.storefront_outlined),
                const SizedBox(height: 16),
                buildTextFormField(
                    controller: _addressController,
                    label: "Address",
                    icon: Icons.location_on_outlined),
                const SizedBox(height: 16),
                buildTextFormField(
                    controller: _zipCodeController,
                    label: "ZIP Code",
                    icon: Icons.map_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: _fetchCityStateFromZipCode),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: buildTextFormField(
                            controller: _cityController,
                            label: "City",
                            icon: Icons.location_city,
                            enabled: false)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: buildTextFormField(
                            controller: _stateController,
                            label: "State",
                            icon: Icons.location_city,
                            enabled: false)),
                  ],
                ),
                const SizedBox(height: 16),
                buildTextFormField(
                  controller: _establishmentDateController,
                  label: "Establishment Date",
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _establishmentDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement API call to save changes
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.orange,
            child: Text("A", style: TextStyle(color: Colors.white, fontSize: 50)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement image picker logic
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.edit, size: 20, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}