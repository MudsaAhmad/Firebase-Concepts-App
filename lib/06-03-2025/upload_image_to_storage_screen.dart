import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'get_image_from_storage_screen.dart';

class UploadImageToStorageScreen extends StatefulWidget {
  const UploadImageToStorageScreen({super.key});

  @override
  State<UploadImageToStorageScreen> createState() =>
      _UploadImageToStorageScreenState();
}

class _UploadImageToStorageScreenState
    extends State<UploadImageToStorageScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  File? _selectedImage;
  String? _imageUrl;

  // store user data in firestore // String? imageUrl
  Future<void> storeUserDataInFirestore(
    String uid,
    String profileImage,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('currentUsers').doc(uid).set({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "confirmPassword": confirmPasswordController.text,
        "userImage": profileImage, // Store Image URL
      });
    } catch (e) {
      print('error------$e');
    }
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? xFile = await picker.pickImage(source: ImageSource.camera);

    print('xfile ---->${xFile?.path}');

    if (xFile != null) {
      setState(() {
        _selectedImage = File(xFile.path);
        print('selected image ------->$_selectedImage');
      });
    } else {
      print('error------->');
    }
  }

  Future<String?> uploadImageToStorage(String uid, File imageFile) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('uploadImages/$uid.jpg');

      print('reference ----->${storageReference.name}');

      UploadTask uploadTask = storageReference.putFile(imageFile);

      print('upload task ----> ${uploadTask.toString()}');

      TaskSnapshot snapshot = await uploadTask;
      print('snapshot -----> ${snapshot.toString()}');

      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('download url ------> $downloadUrl');
      return downloadUrl;
    } catch (error) {
      print('error----------->$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              GestureDetector(
                onTap: pickImageFromGallery,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : _imageUrl != null
                          ? NetworkImage(_imageUrl!) as ImageProvider
                          : null,
                  child: _selectedImage == null && _imageUrl == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(
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
                    try {
                      if (passwordController.text ==
                          confirmPasswordController.text) {
                        setState(() {
                          loading = true;
                        });
                        UserCredential? user = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim());
                        print('user id---->${user.user?.uid}');
                        if (_selectedImage != null) {
                          String? imageUrl = await uploadImageToStorage(
                              user.user!.uid, _selectedImage!);
                          await storeUserDataInFirestore(
                              user.user!.uid, imageUrl!);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Account created successfully!')));
                        } else {
                          //  await storeUserDataInFirestore(user.user!.uid, null);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Account created successfully!')));
                        }

                        setState(() {
                          loading = false;
                        });
                      } else {
                        print('password and confirm password not matched!!');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Password and confirm password not matched!!')));
                      }
                    } on FirebaseAuthException catch (error) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$error')));
                      print('firebase exception error------->$error');
                      setState(() {
                        loading = false;
                      });
                    } catch (error) {
                      print('error----->$error');
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
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetImageFromStorageScreen()));
                  },
                  child: Text('Navigate')),
              ElevatedButton(
                  onPressed: () async {
                    signInWithGoogle();
                  },
                  child: Text('Sign in with google')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    FirebaseAuth.instance.signOut();
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    print('user detail email---- > ${googleSignInAccount?.email}');
    print('user detail name ---- > ${googleSignInAccount?.displayName}');
    print('user detail id  ---- > ${googleSignInAccount?.id}');
    print('user detail photo ---- > ${googleSignInAccount?.photoUrl}');

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    print(
        'googleSignInAuthentication access token-----> ${googleSignInAuthentication.accessToken}');
    print(
        'googleSignInAuthentication id token -----> ${googleSignInAuthentication.idToken}');

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    print('credential ----------> ${credential.idToken}');

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print('user uniques id ---------> ${userCredential.user?.displayName}');
    print('user uniques id ---------> ${userCredential.user?.uid}');

    // Navigate
  }

  // // function for google sign in
  // Future<void> signInWithGoogle(BuildContext context) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       print('User canceled Google sign-in------------>');
  //       return;
  //     }
  //     print('Google User----> ${googleUser.email}, ${googleUser.displayName}, ${googleUser.photoUrl}, ${googleUser.id}');
  //     final GoogleSignInAuthentication googleAuth =
  //     await googleUser.authentication;
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final UserCredential userCredential =
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     print('Firebase Sign-In Successful: ${userCredential.user?.uid}');
  //   } catch (e) {
  //     print('error--------->$e');
  //   } finally {}
  // }
}
