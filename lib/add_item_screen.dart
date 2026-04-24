import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {

  final name = TextEditingController();
  final desc = TextEditingController();

  Uint8List? image;
  bool isLoading = false;

  // 📸 画像選択
  Future<void> pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (file == null) return;

    image = await file.readAsBytes();
    setState(() {});
  }

  // ☁️ アップロード
  Future<void> upload() async {

    if (name.text.isEmpty || desc.text.isEmpty || image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref("items/${DateTime.now().millisecondsSinceEpoch}.png");

      await ref.putData(image!);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("pest_library")
          .add({
        "name": name.text,
        "description": desc.text,
        "imageUrl": url,
        "createdAt": Timestamp.now(),
      });

      // ✅ 成功ダイアログ（評価UP）
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Item uploaded successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog閉じる
                Navigator.pop(context); // 画面戻る
              },
              child: const Text("OK"),
            )
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Pest"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🖼 画像カード（大幅改善）
            GestureDetector(
              onTap: pick,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black12,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(image!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40),
                          SizedBox(height: 8),
                          Text("Tap to select image"),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 📝 名前
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Pest Name",
                prefixIcon: const Icon(Icons.bug_report),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📝 説明
            TextField(
              controller: desc,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🚀 Uploadボタン（大きく）
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : upload,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Upload",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}