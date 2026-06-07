import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final TextEditingController nimController =
      TextEditingController();

  final TextEditingController namaController =
      TextEditingController();

  final TextEditingController kelasController =
      TextEditingController();

  String status = "Hadir";

  Future<void> simpanAbsensi() async {

    User? user =
        FirebaseAuth.instance.currentUser;

    if (nimController.text.isEmpty ||
        namaController.text.isEmpty ||
        kelasController.text.isEmpty) {
      return;
    }

    await firestore.collection("absensi").add({
      "nim": nimController.text,
      "nama": namaController.text,
      "kelas": kelasController.text,
      "status": status,
      "userId": user?.uid,
      "createdAt": Timestamp.now(),
    });

    nimController.clear();
    namaController.clear();
    kelasController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data berhasil disimpan"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    User? user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi Mahasiswa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Text(
              "Login sebagai: ${user?.email}",
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nimController,
              decoration: const InputDecoration(
                labelText: "NIM",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Mahasiswa",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: kelasController,
              decoration: const InputDecoration(
                labelText: "Kelas",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Status Kehadiran",
              ),
              items: const [
                DropdownMenuItem(
                  value: "Hadir",
                  child: Text("Hadir"),
                ),
                DropdownMenuItem(
                  value: "Izin",
                  child: Text("Izin"),
                ),
                DropdownMenuItem(
                  value: "Sakit",
                  child: Text("Sakit"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: simpanAbsensi,
              child: const Text("Simpan Absensi"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Data Absensi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("absensi")
                    .orderBy(
                      "createdAt",
                      descending: true,
                    )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Belum ada data absensi",
                      ),
                    );
                  }

                  var docs =
                      snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,

                    itemBuilder: (context, index) {

                      var data =
                          docs[index].data()
                              as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(
                            data["nama"] ?? "",
                          ),
                          subtitle: Text(
                            "NIM: ${data["nim"]}\n"
                            "Kelas: ${data["kelas"]}\n"
                            "Status: ${data["status"]}",
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