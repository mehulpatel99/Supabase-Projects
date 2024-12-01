import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myproject/api/requestCode.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/session.dart';
import 'apiCallBack.dart';

class ApiPresenter {

  ApiCallBacks _apiCallBack;

  ApiPresenter(this._apiCallBack);

  var supabase = Supabase.instance.client;


  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

   signIn({String? email,password}) async {
     bool isOnline = await hasNetwork();
     if(isOnline){

       try{
         await supabase.auth.signInWithPassword(email: email, password: password).then((value){
           _apiCallBack.onSuccess(value, "Success", RequestCode.SIGN_IN);
         });
       }catch(e){
         print("Exception---- $e");
         _apiCallBack.onError(e.toString(), RequestCode.SIGN_IN, '');
       }

     }else{
       print("Please check Internet Connection");
       _apiCallBack.onConnectionError("Check your internet connection and try again", RequestCode.SIGN_IN);
     }
   }

   /// For signUp new user---------------------------------------------

  otpVerifyForSignUp({required String otp,phone}) async {
    bool isOnline = await hasNetwork();
     if(isOnline){
       try{
           await supabase.auth.verifyOTP(
           type: OtpType.sms, // Ensure to use signup type
           token: otp, // The OTP entered by the user
           phone: '+91$phone',
         ).then((value) {
           _apiCallBack.onSuccess(value, "Otp is verified", RequestCode.OTP_CHECK);
           // signUpSupabase();
           print('OTP Signup value $value');
           // return value;
         });
       }catch(e){
         print("Exception $e");
        _apiCallBack.onError("Otp not valid $e", RequestCode.OTP_CHECK, '');
       }
     }else{
       print("Check internet connection");
       _apiCallBack.onConnectionError('Check Internet Connection', RequestCode.OTP_CHECK);
     }
  }


   Future<void> signUp({required String email,pass,name,phone})async {
     bool isOnline = await hasNetwork();
     if(isOnline) {
       try {
         final response = await supabase.auth.signUp(
             email: email,
             password: pass,
             data: {
               "name": name,
               "phone": phone,
             }
         ).then((value) async {
           _apiCallBack.onSuccess(value, 'Success', RequestCode.SIGN_UP);
         });
         if (response.error != null) {
           throw response.error;
         }
       } catch (e) {
         print("exception : $e");
         _apiCallBack.onError("Not SignUp $e", RequestCode.SIGN_UP, '');
         // isLoader = false;
       }
     }else{
       _apiCallBack.onConnectionError('Please check internet Connection', '');
     }
   }

   /// OTP Send Api-----------------------
    oTpSend({required String phone})async{
      bool isOnline = await hasNetwork();
      if(isOnline) {
        try {
          await Supabase.instance.client.auth.signInWithOtp(
            phone: '+91$phone',
          ).then((value) {
            _apiCallBack.onSuccess('', 'success', RequestCode.OTP_SEND);
          });
        } catch (e) {
          _apiCallBack.onError(e.toString(), RequestCode.OTP_SEND, '');
        }
      }else{
        _apiCallBack.onConnectionError('Please check internet connection', '');
      }
    }

    /// Get User Profile Data ---------------------------------
   getUserProfileData()async{
     var currentUserId = Supabase.instance.client.auth.currentUser!.id;
     bool isOnline = await hasNetwork();
     if(isOnline) {
    try{
      await Supabase.instance.client.from('users').stream(primaryKey: ['id']).eq('id', currentUserId).listen((event) {
          print("UserEvent ${event.first['metadata']['name']}");
          _apiCallBack.onSuccess(event, 'success', RequestCode.GET_USER_INFO);
          // name = event.first['metadata']['name'];
          // phone = event.first['metadata']['phone'];
          // email = event.first['email'];
          // nameController.text = name.toString();
          // setState(() {
          // });
      });
    }catch(e){
         print("Exception $e");
         _apiCallBack.onError(e.toString(), RequestCode.GET_USER_INFO, '');
    }
   }else{
       _apiCallBack.onConnectionError('Please check internet connection', '');
     }
  }

/// Update User Profile Data ---------------------------------

  updateUserData({required String  name,phone}) async {
    var currentUserId = Supabase.instance.client.auth.currentUser!.id;
    bool isOnline = await hasNetwork();
    if(isOnline) {
      try {
        await Supabase.instance.client.from("users").update(
            {"metadata": {"name": name, "phone": phone}}).eq(
            "id", currentUserId).then((value) {
          _apiCallBack.onSuccess(
              value, 'success', RequestCode.UPDATE_USER_INFO);
        });
      } catch (e) {
        print("Exception $e");
        _apiCallBack.onError(e.toString(), RequestCode.UPDATE_USER_INFO, '');
      }
    }else{
      _apiCallBack.onConnectionError('Please check internet connection', '');
    }
  }

  /// Metadata update for like IMage---------------------------------------

  // updateUserDataForLike({required String name,phone,id,imgLike}) async {
  //   bool isOnline = await hasNetwork();
  //   if(isOnline) {
  //     try {
  //       await Supabase.instance.client.from("users").update(
  //           {"metadata": {"name": name, "phone": "090909","imgLike": "5"}}).eq(
  //           "id", id).then((value) {
  //         _apiCallBack.onSuccess(
  //             value, 'success', RequestCode.UPDATE_USER_INFO_LIKE);
  //       });
  //     } catch (e) {
  //       print("Exception $e");
  //       _apiCallBack.onError(e.toString(), RequestCode.UPDATE_USER_INFO_LIKE, '');
  //     }
  //   }else{
  //     _apiCallBack.onConnectionError('Please check internet connection', '');
  //   }
  // }

  /// GET USER PROMPTS-----------------------------------------------
 getUserPrompt()async{
   bool isOnline = await hasNetwork();
   if(isOnline) {
     try {
       await supabase
           .from("promp")
           .stream(primaryKey: ["id"])
       // .eq("user_id", currentUserId)
           .order("id", ascending: false).listen((event) {
         _apiCallBack.onSuccess(event, 'success', RequestCode.GET_USER_PROMPT);
       });
     } catch (e) {
       print("Exception $e");
       _apiCallBack.onError(e.toString(), RequestCode.GET_USER_PROMPT, '');
     }
   }else{
     _apiCallBack.onConnectionError('Please check internet connection', '');
   }
 }

 /// Delete User prompt---------------------------------------------------------
 deleteUserPrompt({required int id, required String tableName})async{
   bool isOnline = await hasNetwork();
   if(isOnline) {
     try {
       await Supabase.instance.client
           .from(tableName)
           .delete()
           .match({"id": id}).then((value) {
         _apiCallBack.onSuccess(
             value, 'successfully delete', RequestCode.DELETE_USER_PROMPT);
       });
     } catch (e) {
       _apiCallBack.onError(
           "Exception : $e", RequestCode.DELETE_USER_PROMPT, '');
     }
   }else{
     _apiCallBack.onConnectionError('Please check internet connection', '');
   }
 }

 /// Get All Users-------------------------------------
  getAllUsers()async{
    bool isOnline = await hasNetwork();
    if(isOnline) {

      try{
       await Supabase.instance.client.from('users').stream(primaryKey: ['id']).listen((value) {
         _apiCallBack.onSuccess(value, 'success', RequestCode.GET_ALL_USERS);
       });
        }catch(e){
        _apiCallBack.onError("Exception : $e", RequestCode.GET_ALL_USERS, '');
      }

    }else{
      _apiCallBack.onConnectionError('Please check internet connection', '');
    }
  }
}