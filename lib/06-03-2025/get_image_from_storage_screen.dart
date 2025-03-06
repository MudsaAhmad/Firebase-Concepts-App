import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GetImageFromStorageScreen extends StatefulWidget {
  const GetImageFromStorageScreen({super.key});

  @override
  State<GetImageFromStorageScreen> createState() => _GetImageFromStorageScreenState();
}

class _GetImageFromStorageScreenState extends State<GetImageFromStorageScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  String _imageUrl = '';

Future<void> getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('abcUsers')
          .doc(uid)
          .get();
      print('doc------------<${doc.id}');
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('data--------->${data.toString()}');
        setState(() {
          _imageUrl = data['currentUsersImage'] ?? '';
          print('get image ------->$_imageUrl');
        });
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error fetching user data-----> $e');
    }
  }

  // Logout Function
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut(); // Sign out from Google
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
    }
  }


  // Delete Account Function
  Future<void> deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete(); // Delete account from Firebase
        await GoogleSignIn().signOut(); // Sign out from Google
        print('User account deleted successfully');
      } else {
        print('No user is signed in');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Get image from storage'),

        actions: [
          IconButton(onPressed: (){
            signOut();
          }, icon: Icon(Icons.logout)),
          IconButton(onPressed: (){
            deleteAccount();
          }, icon: Icon(Icons.delete)),
        ],
      ),

      body: Column(
        children: [
          _imageUrl.isNotEmpty
              ? Image.network(
            _imageUrl,

            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          )
              : Icon(Icons.person, size: 100),

          ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;

                  await getUserDataFromFirestore('4ovkh55XygM2G7VCbsUxDGmt2Hn2');
              },
              child: Text('Get my data')),

        ],
      ),
    );
  }
}
