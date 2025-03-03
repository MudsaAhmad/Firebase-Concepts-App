import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpWithUserImage extends StatefulWidget {
  const SignUpWithUserImage({super.key});

  @override
  State<SignUpWithUserImage> createState() => _SignUpWithUserImageState();
}

class _SignUpWithUserImageState extends State<SignUpWithUserImage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  File? _selectedImage;
  String? _imageUrl;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print("Image Selected: ${pickedFile.path}");
    } else {
      print("No Image Selected");
    }
  }

  Future<String?> uploadImageToStorage(String userId, File imageFile) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("my_current_userd_profile_images/$userId.jpg");

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('image url get------>$downloadUrl');

      return downloadUrl;
    } catch (error) {
      print('error------->$error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
      return null;
    }
  }

  // Future<String?> uploadImageToStorage(String userId, File imageFile) async {
  //   try {
  //     Reference storageRef = FirebaseStorage.instance
  //         .ref()
  //         .child("mu_user_profile_images/$userId.jpg");
  //     UploadTask uploadTask = storageRef.putFile(imageFile);
  //
  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //
  //     print("Image Uploaded Successfully: $downloadUrl");
  //     return downloadUrl;
  //   } catch (e) {
  //     print("Error Uploading Image: $e");
  //     return null;
  //   }
  // }

  // store user data in firestore
  Future<void> storeUserDataInFirestore(String uid, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('currentUsers').doc(uid).set({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "confirmPassword": confirmPasswordController.text,
        "profileImage": imageUrl, // Store Image URL
      });
    } catch (e) {
      print('error------$e');
    }
  }

  Future<void> getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('currentUsers')
          .doc(uid)
          .get();

      print('doc------------<${doc.id}');

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('data--------->${data.toString()}');
        String pass = data['password'];
        String confirmPass = data['confirmPassword'];

        setState(() {
          _imageUrl = data['profileImage'];
          print('get image ------->$_imageUrl');
        });

        print(' password----->$pass');
        print('confirm password----->$confirmPass');
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error fetching user data-----> $e');
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
                onTap: pickImage,
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
                              user.user!.uid, imageUrl);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Account created successfully!')));
                        } else {
                          await storeUserDataInFirestore(user.user!.uid, null);
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
                    final uid = FirebaseAuth.instance.currentUser?.uid;

                    await getUserDataFromFirestore(uid!);
                  },
                  child: Text('Get my data')),
            ],
          ),
        ),
      ),
    );
  }
}
