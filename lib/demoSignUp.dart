import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class DemoSignup extends StatefulWidget {
  const DemoSignup({super.key});

  @override
  State<DemoSignup> createState() => _DemoSignupState();
}

class _DemoSignupState extends State<DemoSignup> {
  var nameController = TextEditingController();

  var emailController = TextEditingController();

  var passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Name',labelText: "Name"),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: 'Email',labelText: "Email"),
          ),
          TextField(
            controller: passController,
            decoration: const InputDecoration(hintText: 'Password',labelText: "Pass"),
          ),
          ElevatedButton(onPressed: () async {
            print("Email ${emailController.text}");
            print("Password ${passController.text}");

                  try{
                    await Supabase.instance.client.auth.signUp(
                      password: passController.text,
                      email: emailController.text,
                      data: {
                        'Name': nameController.text.toString()
                      }
                    );
                  }catch(e){
                    print("Exception : $e");
                  }
            //           .then((value) {
            //   print("Succesfully Signup");
            // }) ;
          }, child: const Text("SignUp"))
        ],),
      ),
    );
  }
}
