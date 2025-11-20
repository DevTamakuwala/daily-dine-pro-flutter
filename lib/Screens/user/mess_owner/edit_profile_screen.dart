import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../credentials/api_url.dart';
import '../../../service/save_shared_preference.dart';
import '../../../widgets/build_text_form_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers are created here. In a StatelessWidget, they are recreated on every build.
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: "Priya");
    final lastNameController = TextEditingController(text: "Sharma");
    final emailController =
        TextEditingController(text: "annapurna.mess@example.com");
    final phoneController = TextEditingController(text: "+91 98765 43210");
    final messNameController = TextEditingController(text: "Annapurna Mess");
    final addressController =
        TextEditingController(text: "123 Sunshine Ats, Rothko");
    final zipCodeController = TextEditingController(text: "411038");
    final cityController = TextEditingController(text: "Pune");
    final stateController = TextEditingController(text: "Maharashtra");
    final establishmentDateController =
        TextEditingController(text: "2020-05-15");
    Map<String, dynamic> messOwnerData = {};

    // Logic to fetch city/state from ZIP code
    Future<void> fetchCityStateFromZipCode(String zipCode) async {
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
            cityController.text = postOffice['District'];
            stateController.text = postOffice['State'];
          }
        }
      } catch (e) {
        // Handle error
      }
    }

    Future<void> initFields() async {
      messNameController.text = messOwnerData['mess']['messName'];
      addressController.text = messOwnerData['mess']['address'];
      zipCodeController.text = messOwnerData['mess']['zipCode'];
      fetchCityStateFromZipCode(zipCodeController.text);
      establishmentDateController.text =
          messOwnerData['mess']['establisheDate'];
      firstNameController.text = messOwnerData['firstName'];
      lastNameController.text = messOwnerData['lastName'];
      emailController.text = messOwnerData['email'];
      phoneController.text = messOwnerData['phone'];
    }

    Future<void> messData() async {
      String? messData = await getMessData();
      while (messData == null) {
        messData = await getMessData();
      }

      messOwnerData = jsonDecode(messData);
      print(messOwnerData);
      await initFields();
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
        child: FutureBuilder(
          future: messData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Form(
                key: formKey,
                child: Column(
                  children: [
                    _buildProfilePicture(messOwnerData['firstName'][0] +
                        messOwnerData['lastName'][0]),
                    const SizedBox(height: 24),
                    _buildSectionCard("Personal Details", [
                      Row(
                        children: [
                          Expanded(
                              child: buildTextFormField(
                                  controller: firstNameController,
                                  label: "First Name",
                                  icon: Icons.person_outline)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: buildTextFormField(
                                  controller: lastNameController,
                                  label: "Last Name",
                                  icon: Icons.person_outline)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      buildTextFormField(
                          controller: emailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          enabled: false),
                      // Email is not editable
                      const SizedBox(height: 16),
                      buildTextFormField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionCard("Business Details", [
                      buildTextFormField(
                          controller: messNameController,
                          label: "Mess Name",
                          icon: Icons.storefront_outlined),
                      const SizedBox(height: 16),
                      buildTextFormField(
                          controller: addressController,
                          label: "Address",
                          icon: Icons.location_on_outlined),
                      const SizedBox(height: 16),
                      buildTextFormField(
                          controller: zipCodeController,
                          label: "ZIP Code",
                          icon: Icons.map_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: fetchCityStateFromZipCode),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: buildTextFormField(
                                  controller: cityController,
                                  label: "City",
                                  icon: Icons.location_city,
                                  enabled: false)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: buildTextFormField(
                                  controller: stateController,
                                  label: "State",
                                  icon: Icons.location_city,
                                  enabled: false)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      buildTextFormField(
                        controller: establishmentDateController,
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
                            establishmentDateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            int id = messOwnerData['userId'];
                            String? token = await getTokenId() ?? "";

                            while (token == null) {
                              token = await getTokenId();
                            }

                            String apiUrl = '${url}menu/mess/$id';

                            final response = await http.post(
                              Uri.parse(apiUrl),
                              headers: {
                                "Content-Type": "application/json",
                                "Authorization": "Bearer $token"
                              },
                              body: jsonEncode({
                                "fname": firstNameController.text,
                                "lname": lastNameController.text,
                                "phoneNo": phoneController.text,
                                "messName": messNameController.text,
                                "address": addressController.text,
                                "city": cityController.text,
                                "state": stateController.text,
                                "zipCode": zipCodeController.text,
                              }),
                            );

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile updated successfully"),
                                ),
                              );

                              String apiUrl = '${url}user/$id';
                              final response = await http.get(
                                Uri.parse(apiUrl),
                                headers: {
                                  "Content-Type": "application/json",
                                  "Authorization": "Bearer $token"
                                },
                              );

                              await saveMessData(response.body);

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please try again later"),
                                ),
                              );
                            }
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
                        child: const Text("Save Changes",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfilePicture(String imageUrl) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.orange,
            child: Text(imageUrl,
                style: TextStyle(color: Colors.white, fontSize: 50)),
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
