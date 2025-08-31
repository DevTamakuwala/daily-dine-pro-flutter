import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Note: Ensure you have the 'geolocator' package and the necessary permissions set up.

// A detailed screen for an admin to verify a mess owner's details and location.
class VerifyMessDetailsScreen extends StatefulWidget {
  const VerifyMessDetailsScreen({super.key});

  @override
  State<VerifyMessDetailsScreen> createState() => _VerifyMessDetailsScreenState();
}

class _VerifyMessDetailsScreenState extends State<VerifyMessDetailsScreen> {
  // --- State Variables ---
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _isFetchingLocation = false;
  String? _locationError;
  bool _locationFetched = false; // New state to track if location has been fetched
  bool _isEditing = false; // New state to track if the details are being edited

  // --- Controllers for Editable Fields ---
  late TextEditingController _messNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;


  // --- Mock Data (will be loaded into controllers) ---
  final Map<String, String> _messOwnerData = {
    "messName": "Shree Krishna Mess",
    "ownerName": "Rajesh Gupta",
    "address": "123, Sunshine Apartments, Kothrud, Pune, Maharashtra 411038",
    "phone": "+91 98765 43210",
    "email": "rajesh.gupta@example.com",
  };

  @override
  void initState() {
    super.initState();
    // Initialize controllers with mock data
    _messNameController = TextEditingController(text: _messOwnerData['messName']);
    _ownerNameController = TextEditingController(text: _messOwnerData['ownerName']);
    _addressController = TextEditingController(text: _messOwnerData['address']);
    _phoneController = TextEditingController(text: _messOwnerData['phone']);
    _emailController = TextEditingController(text: _messOwnerData['email']);
  }


  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _messNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
        setState(() => _locationError = "Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

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

  void _saveDetails() {
    // In a real app, you would save the data from the controllers here.
    // For this example, we just exit the editing mode.
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Details saved!"), backgroundColor: Colors.green),
    );
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
                    ? Expanded(child: _buildEditableField(_messNameController, "Mess Name", isTitle: true))
                    : Text(_messNameController.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                _buildEditableField(_phoneController, "Phone", keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildEditableField(_emailController, "Email", keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveDetails,
                    child: const Text("Save Changes"),
                  ),
                )
              ],
            )
                : Column(
              children: [
                _buildDetailRow(Icons.person_outline, "Owner Name", _ownerNameController.text),
                _buildDetailRow(Icons.location_on_outlined, "Address", _addressController.text),
                _buildDetailRow(Icons.phone_outlined, "Phone", _phoneController.text),
                _buildDetailRow(Icons.email_outlined, "Email", _emailController.text),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String label, {bool isTitle = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isTitle ? 22 : 16, fontWeight: isTitle ? FontWeight.bold : FontWeight.normal),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
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
            const Text("Location Verification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCoordinateField("Latitude", _latitudeController)),
                const SizedBox(width: 16),
                Expanded(child: _buildCoordinateField("Longitude", _longitudeController)),
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
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () { /* TODO: Implement reject logic */ },
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
            // --- CHANGE: Button is disabled if location has not been fetched ---
            onPressed: _locationFetched ? () { /* TODO: Implement approve logic */ } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              // --- CHANGE: Add a disabled style ---
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

