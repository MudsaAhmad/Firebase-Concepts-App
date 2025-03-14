import 'package:firebase_concepts_app/testing/sign1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '03-03-2025/sign_up_with_user_image.dart';
import '05-03-2025/new_sign_screen.dart';
import '06-03-2025/upload_image_to_storage_screen.dart';
import '11-03-2025/crud_operation_screen.dart';
import '12-03-2025/crud_operations_screens.dart';
import '26-02-2025/sign_up_screen.dart';
import '27-02-2025/sign_in_with_google.dart';
import '27-02-2025/sign_up_screen_two.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CrudOperationsScreens(),
    );
  }
}
