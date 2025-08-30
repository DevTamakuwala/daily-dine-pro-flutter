//import 'package.flutter/material.dart';
//import 'package:geolocator/geolocator.dart'; // You need to add this package to your pubspec.yaml

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Note: To use this screen, you must add the 'geolocator' package to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   geolocator: ^10.1.0 # Or the latest version
//
// You also need to add location permissions for Android and iOS.
// Android: Add the following to your android/app/src/main/AndroidManifest.xml
// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
//
// iOS: Add the following to your ios/Runner/Info.plist
// <key>NSLocationWhenInUseUsageDescription</key>
// <string>This app needs access to location to verify the mess address.</string>

// A detailed screen for an admin to verify a mess owner's details and location.
class VerifyMessDetailsScreen extends StatefulWidget {
  // In a real app, you would pass the mess owner's data to this screen.
  // final MessOwnerData messOwner;
  // const VerifyMessDetailsScreen({super.key, required this.messOwner});

  const VerifyMessDetailsScreen({super.key});

  @override
  State<VerifyMessDetailsScreen> createState() => _VerifyMessDetailsScreenState();
}

class _VerifyMessDetailsScreenState extends State<VerifyMessDetailsScreen> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  bool _isFetchingLocation = false;
  String? _locationError;

  // --- Mock Data (replace with actual data from your model) ---
  final Map<String, String> _messOwnerData = {
    "messName": "Shree Krishna Mess",
    "ownerName": "Rajesh Gupta",
    "address": "123, Sunshine Apartments, Kothrud, Pune, Maharashtra 411038",
    "phone": "+91 98765 43210",
    "email": "rajesh.gupta@example.com",
  };

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // --- Function to get the current GPS coordinates ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      // 1. Check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Location permissions are permanently denied. Please enable them in settings.";
        });
        return;
      }

      // 2. Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Update the text fields
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });

    } catch (e) {
      setState(() {
        _locationError = "Could not get location: $e";
      });
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
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
            // --- Owner Details Card ---
            _buildDetailsCard(),
            const SizedBox(height: 24),

            // --- Location Verification Card ---
            _buildLocationCard(),
            const SizedBox(height: 32),

            // --- Action Buttons ---
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _messOwnerData['messName']!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.person_outline, "Owner Name", _messOwnerData['ownerName']!),
            _buildDetailRow(Icons.location_on_outlined, "Address", _messOwnerData['address']!),
            _buildDetailRow(Icons.phone_outlined, "Phone", _messOwnerData['phone']!),
            _buildDetailRow(Icons.email_outlined, "Email", _messOwnerData['email']!),
          ],
        ),
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
            const Text(
              "Location Verification",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCoordinateField("Latitude", _latitudeController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCoordinateField("Longitude", _longitudeController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_locationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_locationError!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isFetchingLocation
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location),
                label: Text(_isFetchingLocation ? "Fetching..." : "Get Current Location"),
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
      readOnly: true, // This makes the field disabled
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200, // Visual cue for being disabled
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement reject logic
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
            onPressed: () {
              // TODO: Implement approve logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Poppins'),
                children: [
                  TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
