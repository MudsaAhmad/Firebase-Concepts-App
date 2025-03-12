import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CrudOperationsScreens extends StatefulWidget {
  const CrudOperationsScreens({super.key});

  @override
  State<CrudOperationsScreens> createState() => _CrudOperationsScreensState();
}

class _CrudOperationsScreensState extends State<CrudOperationsScreens> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataWithFuture();
  }

  final nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addData() async {
    if (nameController.text.isNotEmpty) {
      await _firestore.collection('crudOperation').add({
        'userName': nameController.text,
      });
      nameController.clear();
    }
  }

  Stream<QuerySnapshot> getDataWithStream() {
    return _firestore.collection('crudOperation').snapshots();
  }

  Future<QuerySnapshot> getDataWithFuture() {
    return _firestore.collection('crudOperation').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crud Operations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Enter name'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(onPressed: addData, child: const Text('Add Data')),
            const Text('Data show through stream builder'),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: getDataWithStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Text('Data not found!!');
                    } else {
                      return ListView(
                          children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        print('data --------->${data.toString()}');

                        return ListTile(
                          leading: Text(data['userName']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    await _firestore
                                        .collection('crudOperation')
                                        .doc(doc.id)
                                        .delete();
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit)),
                            ],
                          ),
                        );
                      }).toList());
                    }
                  }),
            ),
            SizedBox(
              height: 20,
            ),
            const Text('Data show through Future builder'),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                  future: getDataWithFuture(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Text('Data not found!!');
                    } else {
                      return ListView(
                          children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        print('data --------->${data.toString()}');
                        print('doc ids --------->${doc.id}');

                        return ListTile(
                          leading: Text(data['userName']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    await _firestore
                                        .collection('crudOperation')
                                        .doc(doc.id)
                                        .delete();
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit)),
                            ],
                          ),
                        );
                      }).toList());
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
