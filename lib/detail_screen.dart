import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data['imageUrl'] ?? '',
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),

            const SizedBox(height: 10),

            Text(
              data['name'] ?? '',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(data['description'] ?? ''),

            const SizedBox(height: 10),

            Text("Scientific: ${data['scientificName'] ?? ''}"),

            const SizedBox(height: 10),

            Text("Treatment: ${data['treatment'] ?? ''}"),
          ],
        ),
      ),
    );
  }
}