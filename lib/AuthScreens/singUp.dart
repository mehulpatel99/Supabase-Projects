import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/AuthScreens/login.dart';
import 'package:myproject/AuthScreens/style_constant.dart';
import 'package:myproject/api/apiCallBack.dart';
import 'package:myproject/api/apiPresenter.dart';
import 'package:myproject/api/requestCode.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/home_page.dart';
import '../utils/session.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> implements ApiCallBacks{
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

final formKey = GlobalKey<FormState>();
  late  XFile? image;
  String? _imageUrl;

  String defaultImage = "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg=";

   bool isOtp = false;

  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();
  TextEditingController otp5Controller = TextEditingController();
  TextEditingController otp6Controller = TextEditingController();

  bool isLoader = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          leading: const Icon(Icons.input_outlined),
          title: const Text("SingUp")),
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
                    const Text('Welcome to the world of AI chat',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black)),
                    const SizedBox(height: 20),
                    imgWidget(),
                    const SizedBox(height: 20),
                    allTextField(),
                    if(isOtp)
                      otpWidget(),
                      resendOTPBtn(),
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
          if(isLoader)
            const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }




  textField({required TextEditingController controller,String labelTxt = '',String hintTxt = ''}) {
    bool isNumber = false;
    if(controller == passController || controller == phoneController){
      isNumber = true;
      setState(() { });
    }
    return  TextFormField(
      controller: controller,
      obscureText: controller == passController,
      keyboardType: isNumber ? TextInputType.number : null,
      decoration: InputDecoration(labelText: labelTxt,hintText: hintTxt,border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:const BorderSide(width: 2.5)
          )
      ),

      validator: (value) {
        if(value!.isEmpty){
          return "Required this $labelTxt";
        }else{
          if(controller == emailController){
            if(RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(emailController.text)){
              return null;
            }else{
              return "Please Enter Valid Email";
            }
          }else if(controller == phoneController){
            if (phoneController.text.length != 10) {
              return 'Mobile Number must be of 10 digit';
            }
            else{
              return null;
          }
          }else if(controller == passController){
            if (passController.text.length < 6) {
              return 'Password must be of 6 digit';
            }
            else{
              return null;
            }
          }
        }
        return null;
      },

    );
  }


  signupButton() {
    return ElevatedButton(onPressed: () async{
      if(formKey.currentState!.validate()){
      if (!isOtp) {
        ApiPresenter(this).oTpSend(phone: phoneController.text.toString());
        // final otpResponse = await Supabase.instance.client.auth.signInWithOtp(
        //   phone: '+91${phoneController.text}',
        // ).then((value) {
        //   isOtp = true;
        //   setState(() {});
        // });

      } else {
        setState(() {
          isLoader = true;
        });

        String oTP = otp1Controller.text + otp2Controller.text + otp3Controller.text + otp4Controller.text + otp5Controller.text + otp6Controller.text;
        print("OTP is $oTP");

        ApiPresenter(this).otpVerifyForSignUp(otp: oTP,phone:phoneController.text );

      //   try{
      //     final AuthResponse res = await Supabase.instance.client.auth.verifyOTP(
      //       type: OtpType.sms, // Ensure to use signup type
      //       token: oTP, // The OTP entered by the user
      //       phone: '+91${phoneController.text}',
      //     ).then((value) {
      //       signUpSupabase();
      //       print('OTP Signup value $value');
      //       return value;
      //     });
      //   }catch(e){
      //     print("Exception $e");
      //     ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("OTP is not valid!")));
      //   setState(() {
      //     isLoader = false;
      //   });
      //   }
      }
    }
      },style:commonButtonStyle(), child:  Text(isOtp ? 'SignUp' : "Submit"));
  }

  loginButton() {
    return
      InkWell(
        onTap: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder:  (context) => const LoginPage(),));
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
      _imageUrl = image!.path;
      print("Selected Image is $_imageUrl");
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
            },
            child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add,color: Colors.white,size: 15,))),
      ),
    );
  }

  otpWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        otpField(controller: otp1Controller),
        otpField(controller: otp2Controller),
        otpField(controller: otp3Controller),
        otpField(controller: otp4Controller),
        otpField(controller: otp5Controller),
        otpField(controller: otp6Controller),
      ],
    );
  }

  otpField({required TextEditingController controller}) {
    return Card(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 54,
        width: 50,
        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10),/*border: Border.all(color: Colors.black)*/),
        child: TextField(
          controller: controller,
          onChanged: (value){
            if(value.length == 1){
              FocusScope.of(context).nextFocus();
            }else if(value.length == 0){
            FocusScope.of(context).previousFocus();
            }
          },
          style: Theme.of(context).textTheme.headlineSmall,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

   signUpSupabase() async {
      final email = emailController.text.toString();
      final pass = passController.text.toString();
      print("email $email");
      print("pass $pass");

      ApiPresenter(this).signUp(email: email,pass: pass,name: nameController.text.toString(),phone: phoneController.text.toString());

      //     try{
      //           final response = await Supabase.instance.client.auth.signUp(
      //           email:email,
      //           password: pass,
      //           data: {
      //             "name": nameController.text.toString(),
      //             "phone": phoneController.text.toString(),
      //           }
      //           ).then((value) async {
      //            if(_imageUrl != null) {
      //              CommonMethods.profileUpload(context,
      //                  userID: value.user!.id, image: image);
      //            }
      //     SessionManager.setString(k: "email", value: value.user!.email.toString());
      //         print("User_ID : ${value.user!.id}");
      //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      //       });
      //   if(response.error != null){
      //     throw response.error;
      //   }
      //     } catch (e) {
      //       print("exception : $e");
      //       isLoader = false;
      //     }
      // setState(() {
      //   isLoader = false;
      // });
      }

  resendOTPBtn() {
    return isOtp ? Row(
      children: [
        TextButton(onPressed: (){
          setState(() {
            isOtp = false;
            phoneController.clear();
          });
        }, child: const Text("Resend OTP!")),
      ],
    ) : Container();
  }

  allTextField() {
    return Column(
      children: [
        textField(controller: nameController,hintTxt: "Enter your name",labelTxt: "Name"),
        const SizedBox(height: 20),
        textField(controller: emailController,hintTxt: "Enter your email",labelTxt: "Email"),
        const SizedBox(height: 20),
        textField(controller: passController,hintTxt: "Enter your Password",labelTxt: "Password"),
        const SizedBox(height: 20),
        textField(controller: phoneController,hintTxt: "Enter your Phone No.",labelTxt: "Phone No."),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void onConnectionError(String error, String requestCode) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check your internet connection")));
    setState(() {
      isLoader = false;
    });
  }

  @override
  void onError(String errorMsg, String requestCode, String statusCode) {
    if(requestCode.contains(RequestCode.OTP_CHECK)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP is not valid! $errorMsg")));
    }else{
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("$errorMsg")));
      print("Error $errorMsg");
    }
    setState(() {
      isLoader = false;
    });
  }

  @override
  void onSuccess(object, String strMsg, String requestCode) {
    if(requestCode.contains(RequestCode.OTP_CHECK)){
      signUpSupabase();
      print("Supabase SignUp");

    }else if(requestCode.contains(RequestCode.SIGN_UP)){

      if(_imageUrl != null) {
        CommonMethods.profileUpload(context,
            userID: object.user!.id, image: image);
      }
      SessionManager.setString(k: "email", value: object.user!.email.toString());
      print("User_ID : ${object.user!.id}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));

    }else if(requestCode.contains(RequestCode.OTP_SEND)){
      isOtp = true;
    }
    setState(() { });
  }

}
