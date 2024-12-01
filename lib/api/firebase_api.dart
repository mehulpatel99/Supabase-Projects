
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  /// create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  /// function to initialize notification
  Future<void> initNotification() async{

    /// request permission from user
  NotificationSettings setting =  await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true
    );

   // if(setting.authorizationStatus == AuthorizationStatus.authorized){
   //   print("User granted permission");
   // }else{
   //   print("User denied permission");
   // }

    /// fetch the FCM token for the device
    final getToken = await _firebaseMessaging.getToken();
    print("Token is : $getToken");
     FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
     firebaseMsg();
  }


   void firebaseMsg()async{
     // /// Handle foreground messages
     FirebaseMessaging.onMessage.listen((message) {
       print("Received a message while in the foreground!");
       print("Title: ${message.notification?.title}");
       print("Body: ${message.notification?.body}");
       print("Payload: ${message.data}");
       showNotification(message);
     });
   }

   void localMsg(RemoteMessage message)async{
    // var androidInitializationSetting = const AndroidInitializationSettings('@mipmap/ic_launcher');
    //
    // var initializationSetting = InitializationSettings(
    //   android: androidInitializationSetting
    // );
    // await _flutterLocalNotificationsPlugin.initialize(
    //   initializationSetting,
    //   onDidReceiveNotificationResponse: (payload){
    //   }
    // );
    showNotification(message);
   }

   Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notification',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.name.toString(),
    channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker'
    );

    /// For IOs --------------------------------
    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );
    // var androidInitializationSetting = const AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSetting = InitializationSettings(android: androidInitializationSetting);
    // await _flutterLocalNotificationsPlugin.initialize(initializationSetting);

    if(message.notification != null){
     print("Notification data");
     Future.delayed(Duration.zero,(){
       _flutterLocalNotificationsPlugin.show(0, message.notification!.title, message.notification!.body, notificationDetails);
     });

   }else{
     print("Notification data is NULL");
   }

  }

  Future<void> _firebaseBackgroundHandler(RemoteMessage message)async {
    print('background handler');
    await Firebase.initializeApp();
  }


}