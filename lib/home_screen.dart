import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'detail_screen.dart';
import 'login_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String searchText = "";

  @override
  void initState() {
    super.initState();

    print("🔥 HOME SCREEN LOADED");

    FirebaseFirestore.instance
        .collection('pest_library')
        .get()
        .then((snapshot) {
      print("🔥 DOC COUNT = ${snapshot.docs.length}");
    });
  }

  // 🔥 CORS回避URL
  String fixImageUrl(String url) {
    return url
        .replaceFirst(
          "firebasestorage.googleapis.com",
          "storage.googleapis.com",
        )
        .replaceAll("/v0/b/", "/");
  }

  // ❤️ お気に入り
  Future<void> toggleFavorite(String pestId, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .doc(pestId);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set(data);
    }
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // 🔥 UI本体
      body: Column(
        children: [

          // 🔍 検索バー
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search pests...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase().trim();
                });
              },
            ),
          ),

          // 🔥 Firestore表示
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pest_library')
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // 🔍 フィルタ
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data['name'] ?? "")
                      .toString()
                      .toLowerCase();

                  final desc = (data['description'] ?? "")
                      .toString()
                      .toLowerCase();

                  return name.contains(searchText) ||
                         desc.contains(searchText);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No results"));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {

                    final doc = filteredDocs[index];
                    final data =
                        doc.data() as Map<String, dynamic>;
                    final pestId = doc.id;

                    final imageUrl = data['imageUrl'];

                    final fixedUrl = (imageUrl != null &&
                            imageUrl.toString().isNotEmpty)
                        ? fixImageUrl(imageUrl.toString())
                        : null;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: fixedUrl != null
                            ? Image.network(
                                fixedUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  print("❌ IMAGE ERROR: $error");
                                  return const Icon(Icons.broken_image);
                                },
                              )
                            : const Icon(Icons.image_not_supported),
                      ),

                      title: Text(data['name'] ?? ''),

                      subtitle: Text(
                        data['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ❤️ お気に入り
                      trailing: user == null
                          ? null
                          : StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('favorites')
                                  .doc(user.uid)
                                  .collection('items')
                                  .doc(pestId)
                                  .snapshots(),
                              builder: (context, favSnapshot) {

                                final isFav =
                                    favSnapshot.data?.exists ?? false;

                                return IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFav
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    toggleFavorite(pestId, data);
                                  },
                                );
                              },
                            ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailScreen(data: data),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}