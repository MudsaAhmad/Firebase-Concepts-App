import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewSignUpScreen extends StatefulWidget {
  const NewSignUpScreen({super.key});

  @override
  State<NewSignUpScreen> createState() => _NewSignUpScreenState();
}

class _NewSignUpScreenState extends State<NewSignUpScreen> {
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
        "currentUsersImage": profileImage, // Store Image URL
      });
    } catch (e) {
      print('error------$e');
    }
  }

  // Future<void> getUserDataFromFirestore(String uid) async {
  //   try {
  //     DocumentSnapshot doc = await FirebaseFirestore.instance
  //         .collection('currentUsers')
  //         .doc(uid)
  //         .get();
  //     print('doc------------<${doc.id}');
  //     if (doc.exists) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       print('data--------->${data.toString()}');
  //       String pass = data['password'];
  //       String confirmPass = data['confirmPassword'];
  //       setState(() {
  //         _imageUrl = data['profileImage'];
  //         print('get image ------->$_imageUrl');
  //       });
  //       print(' password----->$pass');
  //       print('confirm password----->$confirmPass');
  //     } else {
  //       print('User not found');
  //     }
  //   } catch (e) {
  //     print('Error fetching user data-----> $e');
  //   }
  // }

  File? selectedImage;

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
    print('get image from gallery ----> $xFile');

    if (xFile != null) {
      setState(() {
        selectedImage = File(xFile.path);
        print('select image path ---> $selectedImage');
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image not selected!!')));
    }
  }

  Future<String?> uploadCurrentUsersImageToStorage(String uid, File uploadFile) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('current_users_profile_images/$uid.jpg');

    print('storage reference ---->${storageReference.name}');

    UploadTask uploadTask = storageReference.putFile(uploadFile);

    print('upload task ---->${uploadTask.toString()}');

    TaskSnapshot snapshot = await uploadTask;
    print('storage reference ---->${snapshot.toString()}');

    String downloadUrl = await snapshot.ref.getDownloadURL();
    print('get download url------->$downloadUrl');
    return downloadUrl;
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
              // IconButton(
              //     onPressed: () {
              //       getImage();
              //     },
              //     icon: const Icon(Icons.browse_gallery)),

              GestureDetector(
                onTap: getImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : _imageUrl != null
                          ? NetworkImage(_imageUrl!) as ImageProvider
                          : null,
                  child: selectedImage == null && _imageUrl == null
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
                          String? imageUrl =
                              await uploadCurrentUsersImageToStorage(
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
                    final uid = FirebaseAuth.instance.currentUser?.uid;

                    //  await getUserDataFromFirestore(uid!);
                  },
                  child: Text('Get my data')),
            ],
          ),
        ),
      ),
    );
  }
}
