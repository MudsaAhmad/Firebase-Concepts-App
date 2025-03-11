import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrudOperationScreen extends StatefulWidget {
  const CrudOperationScreen({super.key});

  @override
  State<CrudOperationScreen> createState() => _CrudOperationScreenState();
}

class _CrudOperationScreenState extends State<CrudOperationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add data to Firestore
  Future<void> addData() async {
    if (_nameController.text.isNotEmpty) {
      await _firestore.collection('crudData').add({
        'name': _nameController.text,
        'createdAt': Timestamp.now(),
      });
      _nameController.clear();
    }
  }

  // Function to update existing data
  Future<void> updateData(String docId, String currentName) async {
    TextEditingController updateController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Name"),
          content: TextField(
            controller: updateController,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (updateController.text.isNotEmpty) {
                  await _firestore.collection('crudData').doc(docId).update({
                    'name': updateController.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Function to get real-time data using Stream
  Stream<QuerySnapshot> getStreamData() {
    return _firestore
        .collection('crudData').snapshots();
  }

  // Function to get one-time data using Future
  Future<QuerySnapshot> getFutureData() {
    return _firestore
        .collection('crudData').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CRUD Operations',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addData,
              child: const Text('Add Data'),
            ),
            const SizedBox(height: 20),

            // Using StreamBuilder (Real-time Updates)
            const Text(
              "Data from StreamBuilder (Real-time Updates)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getStreamData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No Data Found"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => updateData(doc.id, data['name']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _firestore
                                  .collection('crudData')
                                  .doc(doc.id)
                                  .delete(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Using FutureBuilder (Fetches Data Once)
            const Text(
              "Data from FutureBuilder (One-time Fetch)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: getFutureData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No Data Found"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name']),
                      );
                    }).toList(),
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
