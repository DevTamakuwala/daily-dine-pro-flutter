import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget messList(List<dynamic> listItems, void Function(dynamic item) onItemTap) {

  if (listItems.isEmpty) {
    return const Center(child: Text("No Mess to verify."));
  }

  return ListView.builder(
    padding: const EdgeInsets.all(12.0),
    itemCount: listItems.length,
    itemBuilder: (context, index) {
      final item = listItems[index];
      final createdAtValue = item['createdAt'];
      // Use a robust parser that accepts numeric timestamps (seconds or milliseconds)
      // or ISO date strings. This avoids the 'String.toInt' runtime error.
      DateTime parseCreatedAt(dynamic v) {
        if (v == null) return DateTime.now();
        if (v is num) {
          int millis = v.toInt();
          // If value looks like seconds (10 digits), convert to ms
          if (millis.abs() < 1000000000000) millis = millis * 1000;
          return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
        }
        final s = v.toString();
        try {
          return DateTime.parse(s).toLocal();
        } catch (_) {
          // Fallback: try parsing a common 'yyyy-MM-dd HH:mm:ss' format
          try {
            return DateTime.parse(s.replaceFirst(' ', 'T')).toLocal();
          } catch (_) {
            return DateTime.now();
          }
        }
      }

      final dateTime = parseCreatedAt(createdAtValue);
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            onItemTap(item);
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
                        item['mess']['messName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Owner: ${item['firstName']!} ${item['lastName']}",
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
                      DateFormat('dd-MM-yyyy').format(dateTime),
                      // item['createdAt'].toString(),
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
