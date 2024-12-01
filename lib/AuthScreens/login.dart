import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myproject/AuthScreens/singUp.dart';
import 'package:myproject/AuthScreens/style_constant.dart';
import 'package:myproject/api/apiCallBack.dart';
import 'package:myproject/api/apiPresenter.dart';
import 'package:myproject/api/requestCode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import '../utils/session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements ApiCallBacks {
  TextEditingController emailController = TextEditingController();

  TextEditingController passController = TextEditingController();
 bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.login),
        title: const Text('SupaBase Login'),),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Promptia',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black)),
                    const Text('Welcome back',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black)),
                   const SizedBox(height: 20),
                    textField(controller: emailController,hintTxt: "Enter your email",labelTxt: "Email"),
                    const SizedBox(height: 20),
                    textField(controller: passController,hintTxt: "Enter your Password",labelTxt: "Password"),
                    const SizedBox(height: 20),
                    loginButton(),
                    const SizedBox(height: 20),
                    const Text('------OR-----'),
                    const SizedBox(height: 20),
                    signUpButton()
                  ],
                ),
              ),
            ),
          ),
         if(isLoading)
           const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }

  textField({required TextEditingController controller,String labelTxt = '',String hintTxt = ''}) {
    return  TextFormField(
      controller: controller,
      obscureText: controller == passController,
      keyboardType: controller == passController ? TextInputType.number : null,
      validator: (value) {
        if(labelTxt == "Email") {
          if (value!.isEmpty ||
              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value)) {
            return 'Enter a valid email!';
          }
        }else if(labelTxt == "Password"){
          if (passController.text.length < 6) {
            return 'Password must be of 6 digit';
          }
          else{
            return null;
          }
        }
        else{
         if (value!.isEmpty) {
            return "Required this $labelTxt";
          }
        }
      },

      decoration: InputDecoration(labelText: labelTxt,hintText: hintTxt,border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
      ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:const BorderSide(width: 2.5)
          )
      ),
    );
  }

  loginButton() {
    return ElevatedButton(onPressed: ()async{
            if (formKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
              });

              ApiPresenter(this).signIn(password:passController.text.toString(),email: emailController.text.toString());

             // try{
             //   await Supabase.instance.client.auth
             //       .signInWithPassword(
             //       password: passController.text.toString(),
             //       email: emailController.text.toString())
             //       .then((value){
             //         print("${value.user}");
             //         SessionManager.setString(k: "email", value: value.user!.email.toString());
             //     ScaffoldMessenger.of(context).showSnackBar(
             //         const SnackBar(content: Text("Successfully Login")));
             //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
             //   }
             //   );
             // }catch(e){
             //   print("exception : $e");
             //   isLoading = false;
             //   ScaffoldMessenger.of(context).showSnackBar(
             //       const SnackBar(content: Text("User Not Found")));
             // }
             // setState(() {  });
            }
        },style:commonButtonStyle(), child:  const Text('Login'));
  }

  signUpButton() {
    return InkWell(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
        },
        child: const Text("Don't have an account! SignUp"));
  }

  @override
  void onConnectionError(String error, String requestCode) {
    setState(() {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please check your Internet Connection")));
    });

  }

  @override
  void onError(String errorMsg, String requestCode, String statusCode) {
   setState(() {
     isLoading = false;
     ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User Not Found ${errorMsg.toString()}")));
   });

  }

  @override
  void onSuccess(object, String strMsg, String requestCode) {
    if(requestCode.contains(RequestCode.SIGN_IN)) {
      print("${object.user}");
      SessionManager.setString(k: "email", value: object.user!.email.toString());
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }
}
