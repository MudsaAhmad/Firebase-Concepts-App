import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class Sign1 extends StatefulWidget {
  const Sign1({super.key});

  @override
  State<Sign1> createState() => _Sign1State();
}

class _Sign1State extends State<Sign1> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  File? selectedImage;
  String? imageUrl;

  Future<void> pickImageFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();

    final XFile? xFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      setState(() {
        selectedImage = File(xFile.path);
        print('image selected ------> $selectedImage');
      });
    } else {
      print('error------->');
    }
  }

  Future<String?> uploadImageToFirebase(String uid, File imageFile) async {
    Reference reference = FirebaseStorage.instance.ref().child('abc/$uid.jpg');

    print('directory name ---->${reference.name}');

    UploadTask uploadTask = reference.putFile(imageFile);

    TaskSnapshot snapshot = await uploadTask;

    String? downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> storeUserDataInFirestore(
    String uid,
    String profileImage,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('abcUsers').doc(uid).set({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "confirmPassword": confirmPasswordController.text,
        "currentUsersImage": profileImage, // Store Image URL
      });
    } catch (e) {
      print('error------$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Sign Up with user image',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: pickImageFromGallery,
                child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : imageUrl != null
                            ? NetworkImage(imageUrl!) as ImageProvider
                            : null,
                    child: selectedImage == null ? Icon(Icons.camera) : null),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  hintText: 'first name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  hintText: 'last name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  hintText: 'confirm password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });

                    UserCredential? user = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim());

                    if (selectedImage != null) {
                      String? getImageUrl = await uploadImageToFirebase(
                          user.user!.uid, selectedImage!);

                      print('select image url ------->$selectedImage');
                      print('get image url ------->$getImageUrl');

                      await storeUserDataInFirestore(
                          user.user!.uid, getImageUrl!);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Account created successfully!')));
                      setState(() {
                        loading = false;
                      });
                    } else {
                      print('error---------->');
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up')),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  signInWithGoogle();
                },
                child: loading ? CircularProgressIndicator() : Text('Sign in with google'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // sign in with google function

  Future<void> signInWithGoogle() async {
    try{

      setState(() {
        loading = true;
      });

      final GoogleSignInAccount? googleSignInAccount =
      await GoogleSignIn().signIn();

      print(
          'user detail --------> ${googleSignInAccount?.email} name--->${googleSignInAccount?.displayName}');

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        loading = false;
      });      print('Firebase Sign-In Successful-------> ${userCredential.user?.uid}');
    }catch (error){
      print('error----------->$error');
      setState(() {
        loading = false;
      });
    }

  }
}
