import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../credentials/api_url.dart';
import '../../../service/save_shared_preference.dart';
import 'approval_successful_screen.dart';
// Note: Ensure you have the 'geolocator' package and the necessary permissions set up.

// A detailed screen for an admin to verify a mess owner's details and location.
class VerifyMessDetailsScreen extends StatefulWidget {
  final int userId;

  const VerifyMessDetailsScreen({super.key, required this.userId});

  @override
  State<VerifyMessDetailsScreen> createState() =>
      _VerifyMessDetailsScreenState();
}

class _VerifyMessDetailsScreenState extends State<VerifyMessDetailsScreen> {
  // --- State Variables ---
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _isFetchingLocation = false;
  String? _locationError;
  bool _locationFetched =
      false; // New state to track if location has been fetched
  bool _isEditing = false; // New state to track if the details are being edited
  bool _isLoading = true;
  String establishmentDate = "";

  // --- Controllers for Editable Fields ---
  late TextEditingController _messNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _ownerPhoneController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;

  // --- Mock Data (will be loaded into controllers) ---
  Map<String, dynamic> _messOwnerData = {
    "messName": "Shree Krishna Mess",
    "ownerName": "Rajesh Gupta",
    "address": "123, Sunshine Apartments, Kothrud, Pune, Maharashtra 411038",
    "phone": "+91 98765 43210",
    "email": "rajesh.gupta@example.com",
  };

  bool fetched = false;

  // @override
  // void initState() {
  //   super.initState();
  //   Initialize controllers with mock data
  //   init();
  // }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _messNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationError = "Location permissions are denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() =>
            _locationError = "Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _locationFetched = true; // Enable the approve button
      });
    } catch (e) {
      setState(() => _locationError = "Could not get location: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveDetails() async {
    // In a real app, you would save the data from the controllers here.
    // For this example, we just exit the editing mode.
    bool changed = await handleChanges(
        _addressController.text,
        _ownerNameController.text,
        _phoneController.text,
        _ownerPhoneController.text,
        _latitudeController.text,
        _longitudeController.text,
        int.parse(_zipCodeController.text),
        _cityController.text,
        _stateController.text);
    if (changed) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Details saved!"), backgroundColor: Colors.green),
      );
    } else {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("There is some problem with data change"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched) {
      fetchMessData();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Mess Owner"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailsCard(),
            const SizedBox(height: 24),
            _buildLocationCard(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _isEditing
                      ? Expanded(
                          child: _buildEditableField(
                              _messNameController, "Mess Name",
                              isTitle: true, enabled: false)) // <-- CHANGE HERE
                      : Text(_messNameController.text,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                    onPressed: _toggleEdit,
                    tooltip: _isEditing ? "Cancel" : "Edit Details",
                  ),
                ],
              ),
              const Divider(height: 20),
              _isEditing
                  ? Column(
                      children: [
                        _buildEditableField(_ownerNameController, "Owner Name"),
                        const SizedBox(height: 12),
                        _buildEditableField(_addressController, "Address"),
                        const SizedBox(height: 12),
                        _buildEditableField(_phoneController, "Mess Phone",
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        _buildEditableField(
                            _ownerPhoneController, "Owner Phone",
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        _buildEditableField(_emailController, "Email",
                            keyboardType: TextInputType.emailAddress,
                            enabled: false),
                        const SizedBox(height: 20),
                        _buildEditableField(_zipCodeController, "Postal Code",
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty || v.length != 6
                                ? "Enter a valid 6-digit Zip Code"
                                : null,
                            onChanged: (value) {
                              if (value.length == 6) {
                                _fetchCityStateFromZipCode(value);
                              } else {
                                setState(() {
                                  _cityController.clear();
                                  _stateController.clear();
                                });
                              }
                            }),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildEditableField(
                                  _cityController, "City",
                                  keyboardType: TextInputType.text,
                                  enabled: false),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildEditableField(
                                  _stateController, "State",
                                  keyboardType: TextInputType.text,
                                  enabled: false),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _saveDetails();
                            },
                            child: const Text("Save Changes"),
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        _buildDetailRow(Icons.person_outline, "Owner Name",
                            _ownerNameController.text),
                        _buildDetailRow(Icons.location_on_outlined, "Address",
                            _addressController.text),
                        _buildDetailRow(Icons.phone_outlined,
                            "Mess Phone Number", _phoneController.text),
                        _buildDetailRow(Icons.phone_outlined,
                            "Owner Phone Number", _ownerPhoneController.text),
                        _buildDetailRow(Icons.email_outlined, "Email",
                            _emailController.text),
                        _buildDetailRow(Icons.pin_drop_outlined, "Postal Code",
                            _zipCodeController.text),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(Icons.pin_drop_outlined,
                                  "City: ", _cityController.text),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildDetailRow(Icons.pin_drop_outlined,
                                  "State: ", _stateController.text),
                            ),
                          ],
                        )
                      ],
                    ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEditableField(
    TextEditingController controller,
    String label, {
    bool isTitle = false,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool readOnly = false, // Add readOnly parameter
    VoidCallback? onTap, // Add onTap parameter
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      // Use the enabled parameter
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      // Use readOnly parameter
      onTap: onTap,
      style: TextStyle(
        fontSize: isTitle ? 22 : 16,
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        color: enabled
            ? Colors.black87
            : Colors.grey.shade700, // Change color when disabled
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        // Add a fill color when disabled
        fillColor: Colors.grey.shade200,
        // The fill color
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Location Verification",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child:
                        _buildCoordinateField("Latitude", _latitudeController)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildCoordinateField(
                        "Longitude", _longitudeController)),
              ],
            ),
            const SizedBox(height: 16),
            if (_locationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_locationError!,
                    style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isFetchingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location),
                label: Text(_isFetchingLocation
                    ? "Fetching..."
                    : "Get Current Location"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isFetchingLocation ? null : _getCurrentLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              /* TODO: Implement reject logic */
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Reject", style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            // START of CHANGE
            onPressed: _locationFetched
                ? () async {
                    bool isApproved = await handleApprove(
                        _latitudeController.text, _longitudeController.text);
                    // TODO: Implement your API call to approve the mess owner here.
                    // On success, navigate to the new screen.
                    if(isApproved){
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApprovalSuccessfulScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("There is some problem with approval"),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                : null,
            // END of CHANGE
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: const Text("Approve", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 16, color: Colors.black87, fontFamily: 'Poppins'),
                children: [
                  TextSpan(
                      text: "$title: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fetch Mess Data
  Future<void> fetchMessData() async {
    String apiUrl = '${url}mess/${widget.userId}';
    String? token = await getTokenId();
    while (token == null) {
      token = await getTokenId();
    }
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    setState(() {
      _messOwnerData = jsonDecode(response.body);
      fetched = true;
      init();
      _isLoading = false;
    });
  }

  Future<bool> handleChanges(
      String address,
      String ownerName,
      String phone,
      String ownerPhone,
      String latitude,
      String longitude,
      int zipCode,
      String city,
      String state) async {
    String? token = await getTokenId();
    while (token == null) {
      token = await getTokenId();
    }
    String apiUrl = '${url}mess/${widget.userId}';
    List<String> ownerNameParts = ownerName.split(' ');
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "createdBy": 0,
        "createdAt": null,
        "modifiedBy": 0,
        "modifiedAt": DateTime.now().toUtc().toIso8601String(),
        "userId": 0,
        "email": _emailController.text,
        "password": null,
        "firstName": ownerNameParts[0],
        "lastName": ownerNameParts[1],
        "phoneNo": ownerPhone,
        "role": "MessOwner",
        "active": false,
        "mess": {
          "createdBy": 0,
          "createdAt": null,
          "modifiedBy": 0,
          "modifiedAt": DateTime.now().toUtc().toIso8601String(),
          "messId": 0,
          "messName": _messNameController.text,
          "address": address,
          "city": city,
          "state": state,
          "zipCode": zipCode,
          "messPhoneNo": phone,
          "establisheDate": establishmentDate, // Use the new establishmentDate
          "latitude": latitude,
          "longitude": longitude,
        },
        "customer": null,
        "mfaEnabled": null,
        "mfaSecret": null,
        "backupCodes": []
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        _messOwnerData = jsonDecode(response.body);
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleApprove(String latitude, String longitude) async {
    String? token = await getTokenId();
    while (token == null) {
      token = await getTokenId();
    }
    String apiUrl = '${url}mess/approve/${widget.userId}';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "latitude": latitude,
        "longitude": longitude,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void init() {
    establishmentDate = _messOwnerData['mess']['establisheDate'];
    _messNameController =
        TextEditingController(text: _messOwnerData['mess']['messName']);
    _ownerNameController = TextEditingController(
        text: "${_messOwnerData['firstName']} ${_messOwnerData['lastName']}");
    _addressController =
        TextEditingController(text: _messOwnerData['mess']['address']);
    _phoneController = TextEditingController(
        text: _messOwnerData['mess']['messPhoneNo'].toString());
    _ownerPhoneController =
        TextEditingController(text: _messOwnerData['phoneNo'].toString());
    _emailController = TextEditingController(text: _messOwnerData['email']);
    _cityController =
        TextEditingController(text: _messOwnerData['mess']['city']);
    _stateController =
        TextEditingController(text: _messOwnerData['mess']['state']);
    _zipCodeController =
        TextEditingController(text: _messOwnerData['mess']['zipCode']);
  }

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
            _cityController.text = district;
            _stateController.text = state;
          });
        } else {
          setState(() {
            _cityController.clear();
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
          _cityController.clear();
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
        _cityController.clear();
        _stateController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching city and state: $e"),
        ),
      );
    }
  }
}
