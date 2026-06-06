import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _dataController = TextEditingController();

  Future<void> _addData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _dataController.text.isNotEmpty) {
      await _firestore.collection('user_data').add({
        'text': _dataController.text,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userEmail': user.email,
      });

      _dataController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda & Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Selamat datang, ${user?.email ?? "Pengguna"}!',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'Masukkan data baru',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _addData,
              child: const Text('Simpan Data'),
            ),

            const SizedBox(height: 20),

            const Text(
              'Data Tersimpan:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('user_data')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data.'),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;
                    return data['userId'] == user?.uid;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(
                            data['text'] ?? '',
                          ),
                          subtitle: Text(
                            data['userEmail'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}