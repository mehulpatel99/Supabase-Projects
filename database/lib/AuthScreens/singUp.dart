import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/AuthScreens/login.dart';
import 'package:myproject/AuthScreens/style_constant.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import '../utils/session.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passController = TextEditingController();

  TextEditingController nameController = TextEditingController();
final formKey = GlobalKey<FormState>();
  late  XFile? image;
  String? _imageUrl;

  String defaultImage = "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg=";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          leading: const Icon(Icons.input_outlined),
          title: const Text("SingUp")),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Promptia',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black)),
                const Text('Welcome to the world of AI chat',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black)),
                const SizedBox(height: 20),
                imgWidget(),
                const SizedBox(height: 20),
                textField(controller: nameController,hintTxt: "Enter your name",labelTxt: "Name"),
                const SizedBox(height: 20),
                textField(controller: emailController,hintTxt: "Enter your email",labelTxt: "Email"),
                const SizedBox(height: 20),
                textField(controller: passController,hintTxt: "Enter your Password",labelTxt: "Password"),
                const SizedBox(height: 20),
                signupButton(),
                const SizedBox(height: 20),
                const Text('------OR-----'),
                const SizedBox(height: 20),
                loginButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
  textField({required TextEditingController controller,String labelTxt = '',String hintTxt = ''}) {
    return  TextFormField(
      controller: controller,
      validator: (value) {
        if(value!.isEmpty){
          return "Required this $labelTxt";
        }
        return null;
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

  signupButton() {
    return ElevatedButton(onPressed: ()async{
        if(formKey.currentState!.validate()){

      final email = emailController.text.toString();
      final pass = passController.text.toString();
      print("email $email");
      print("pass $pass");
          try{
        final response = await Supabase.instance.client.auth.signUp(
                email:email,
                password: pass,
                data: {
                  "name": nameController.text.toString(),
                }
                ).then((value) async {
                 if(_imageUrl != null) {
                   CommonMethods.profileUpload(
                       userID: value.user!.id, image: image);
                 }
          SessionManager.setString(k: "email", value: value.user!.email.toString());
              print("Supabase.instance.client.auth.signUp : ${value.user!.id}");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
            });
        if(response.error != null){
          throw response.error;
        }
          } catch (e) {
            print("exception : $e");
          }
      }
      // });
        },style:commonButtonStyle(), child: const Text('SignUp'));
  }

  loginButton() {
    return
      InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder:  (context) => const LoginPage(),));
        },
        child: const Text.rich(TextSpan(
            text: "Already have an accont ",
            children: [
              TextSpan(text: "Login",style: TextStyle(fontWeight: FontWeight.bold))
            ]
        )),
      );
  }

  Future<void> imgSelect() async {
    final ImagePicker picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return; // No image was selected
    }
    setState(() {
      _imageUrl = image!.path; // Set the path of the image
    });
  }

  imgWidget() {
    return Center(
      child: Container(
        alignment: Alignment.bottomRight,
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black),
            image: _imageUrl == null
                ?  DecorationImage(
                image: NetworkImage(
                    defaultImage))
                : DecorationImage(image:FileImage(File(_imageUrl!)),fit: BoxFit.cover)),
        child:  InkWell(
            onTap: (){
              imgSelect();
              print('img $_imageUrl');
            },
            child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add,color: Colors.white,size: 15,))),
      ),
    );
  }
}
