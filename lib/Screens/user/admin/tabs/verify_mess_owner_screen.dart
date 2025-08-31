import 'package:flutter/material.dart';
import '../verify_mess_details_screen.dart'; // Import the details screen

// A screen that displays a list of mess owners pending verification.
class VerifyMessOwnerScreen extends StatefulWidget {
  const VerifyMessOwnerScreen({super.key});
  @override
  State<VerifyMessOwnerScreen> createState() => _VerifyMessOwnerScreenState();
}

class _VerifyMessOwnerScreenState extends State<VerifyMessOwnerScreen> {
  // --- Mock Data (In a real app, you would fetch this from your API) ---
  final List<Map<String, String>> _pendingVerifications = [
    {
      "messName": "Shree Krishna Mess",
      "ownerName": "Rajesh Gupta",
      "date": "2025-08-30",
    },
    {
      "messName": "Annapurna Tiffins",
      "ownerName": "Priya Singh",
      "date": "2025-08-29",
    },
    {
      "messName": "Ghar Ka Khana",
      "ownerName": "Amit Patel",
      "date": "2025-08-29",
    },
    {
      "messName": "Student's Corner",
      "ownerName": "Sunita Rao",
      "date": "2025-08-28",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _pendingVerifications.length,
        itemBuilder: (context, index) {
          final item = _pendingVerifications[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // When tapped, navigate to the detailed verification screen.
                // In a real app, you would pass the specific item's data to the screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerifyMessDetailsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.storefront),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['messName']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Owner: ${item['ownerName']!}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['date']!,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

