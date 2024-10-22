import 'package:flutter/material.dart';
import 'package:myproject/utils/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckEvent{

  static void listenAuthChange({required BuildContext context})async{
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if(data.event == AuthChangeEvent.signedIn){
        print('User sign in');
        SessionManager.setString(k: "email", value: data.session!.user.email.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Sign in')));
      }else if(data.event == AuthChangeEvent.signedOut){
        print("User log out");
      }
    });
  }
}
