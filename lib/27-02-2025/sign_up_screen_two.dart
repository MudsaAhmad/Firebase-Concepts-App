import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreenTwo extends StatefulWidget {
  const SignUpScreenTwo({super.key});

  @override
  State<SignUpScreenTwo> createState() => _SignUpScreenTwoState();
}

class _SignUpScreenTwoState extends State<SignUpScreenTwo> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // File? selectedImage;

  // store user data in firestore

  Future<void> storeUserDataInFirestore(String uid) async {
    try {
      String encryptedPassword = encryptPassword(passwordController.text);
      String encryptedConfirmPassword =
          encryptPassword(confirmPasswordController.text);

      await FirebaseFirestore.instance.collection('currentUsers').doc(uid).set({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "password": encryptedPassword,
        "confirmPassword": encryptedConfirmPassword,
      });
    } catch (e) {
      print('error------$e');
    }
  }

  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  String decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
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
        String encryptedPassword = data['password'];
        String encryptedConfirmPassword = data['confirmPassword'];

        print('encryp password----->$encryptedPassword');
        print('encryp password----->$encryptedConfirmPassword');

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
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: 'first name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: 'last name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'confirm password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential? user = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim());

                      print('user id---->${user.user?.uid}');

                      await storeUserDataInFirestore(user.user!.uid);
                    } on FirebaseAuthException catch (error) {
                      print('firebase exception error------->$error');
                    } catch (error) {
                      print('error----->$error');
                    }
                  },
                  child: Text('Sign Up')),
              SizedBox(height: 20,),

              ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential? user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim()
                      );

                      print('User ID: ${user.user?.uid}');

                      await storeUserDataInFirestore(user.user!.uid);
                      await getUserDataFromFirestore(user.user!.uid); // Decryption call

                    } on FirebaseAuthException catch (error) {
                      print('Firebase Exception: $error');
                    } catch (error) {
                      print('Error: $error');
                    }
                  },
                  child: Text('Sign Up below')
              ),


            ],
          ),
        ),
      ),
    );
  }
}
