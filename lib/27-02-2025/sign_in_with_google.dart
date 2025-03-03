import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInWithGoogle extends StatefulWidget {
  const SignInWithGoogle({super.key});

  @override
  State<SignInWithGoogle> createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 300,
            ),
            ElevatedButton(
                onPressed: () {
                  signInWithGoogle(context);
                },
                child: const Text('SIgn in wirh googlr')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                deleteAccount();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
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

  // function for google sign in
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('User canceled Google sign-in------------>');
        return;
      }

      print(
          'Google User----> ${googleUser.email}, ${googleUser.displayName}, ${googleUser.photoUrl}, ${googleUser.id}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('Firebase Sign-In Successful: ${userCredential.user?.uid}');
    } catch (e) {
      print('error--------->$e');
    } finally {}
  }
}
