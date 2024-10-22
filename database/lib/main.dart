import 'package:flutter/material.dart';
import 'package:myproject/AuthScreens/singUp.dart';
import 'package:myproject/home_page.dart';
import 'package:myproject/utils/session.dart';
import 'package:myproject/utils/supabase_const.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'allUsers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await Supabase.initialize(url: appUrl, anonKey: appKey);
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
      // home:AllUsers(),
    );
  }

   getInformation() async {
    email = await SessionManager.getString(k: "email");
    print('Email is : $email');
    setState(() { });
   }
}
