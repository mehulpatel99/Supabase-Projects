
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:myproject/AuthScreens/singUp.dart';
import 'package:myproject/api/firebase_api.dart';
import 'package:myproject/screens/home_page.dart';
// import 'package:myproject/firebase_options.dart';
import 'package:myproject/utils/session.dart';
import 'package:myproject/utils/supabase_const.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'demo_freelance/unity_demo.dart';
import 'screens/allUsers.dart';
import 'screens/demoNotification.dart';
import 'firebase_options.dart';
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
 FirebaseApi firebaseApi = FirebaseApi();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // name: "myproject",
      options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotification();
  await _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: true);

  runApp(const MyApp());
  await Supabase.initialize(url: appUrl, anonKey: appKey);
  // await Supabase.initialize(url: demoUrl, anonKey: demoKey);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? email;

  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInformation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: email == null ? const SignUp() : const HomePage(),
      // home:Rotating3DContainer(),
    );
  }

   getInformation() async {
    email = await SessionManager.getString(k: "email");
    print('Email is : $email');
    setState(() { });
   }
}
