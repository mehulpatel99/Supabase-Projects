import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:myproject/allUsers.dart';
import 'package:myproject/api/apiPresenter.dart';
import 'package:myproject/api/requestCode.dart';
import 'package:myproject/profle.dart';
import 'package:myproject/promp_add.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:myproject/utils/imageFullScreen.dart';
import 'package:myproject/utils/supabase_const.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api/apiCallBack.dart';
import 'demoNotification.dart';
import 'drawerCllass.dart';
import 'model_prompt.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements ApiCallBacks {
  String? name;
  String? email;
  List<PromptModel> prompList = [];

  bool isLoading = false;
  bool isData = false;
  double screenHeight = 0.0;

  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchAllPrompt2();
    // fetchAllPrompt();
    supabaseNotification();
    getOldFcmToken();
  }

  @override
  void dispose() {
    // Cancel the stream if the widget is disposed
    super.dispose();
    // You can also cancel the stream or listener here if needed.
  }

  final currentUser = Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promptia"),
        // leading: const Icon(Icons.home),
      ),
      body: Container(
        height: screenHeight,
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Expanded(
            //   child: StreamBuilder(
            //     stream: fetchRealTimePrompt(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //       else if (snapshot.hasError) {
            //         return Center(child: Text('Error: ${snapshot.error}'));
            //       }
            //       else if (snapshot.hasData) {
            //         final data = snapshot.data as List; // Make sure snapshot.data is a list of records
            //         return ListView.builder(
            //           shrinkWrap: true,
            //           itemCount: data.length,
            //           itemBuilder: (context, index) {
            //             final prompt = PromptModel.fromJson(data[index]);
            //             // final prompt = data.map((e) => PromptModel.fromJson(e)).toList();
            //             return  dataUI(item: prompt);
            //           },
            //         );
            //       } else {
            //         return const Text("No Data Found");
            //       }
            //     },
            //   ),
            // )
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: prompList.length,
                itemBuilder: (context, index) {
                  return dataUI(item: prompList[index]);
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PromptAdd()));
      }, child: const Icon(Icons.add)),
      drawer: const DrawerClass(screenName: 'Home'),
    );
  }


  void fetchAllPrompt() async {
    // prompList = (await CommonMethods.fetchAllPrompts() as List).map((e) => PromptModel.fromJson(e)).toList();
    prompList = await CommonMethods.fetchAllPrompts();
    print("PrompList : ${prompList.length}");
    if (prompList.isEmpty) {
      isData = true;
    }
    setState(() {
      isLoading = false;
    });
  }


  List<userModel> userList = [];

  fetchAllPrompt2() async {
    ApiPresenter(this).getAllUsers();
    // if(mounted){
    // Supabase.instance.client.from('users').stream(primaryKey: ['id']).listen((value) {
    //  if(mounted){
    //    userList = (value as List).map((e) => userModel.fromJson(e)).toList();
    //    print("Userlist ${userList.length}");
    //    prompListFill();
    //  }
    // });
    // }
  }

  static Stream fetchRealTimePrompt() {
    return Supabase.instance.client.from("promp")
        .select(
        ''' id,title, prompt , user_id,created_at,users:user_id(metadata,email) ''')
        .order("id", ascending: false)
        .asStream();
  }

  void supabaseNotification() async {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      // if(event.event == AuthChangeEvent.signedIn){
      print("Sign in user------------------------");
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.getAPNSToken();
      final fCMToken = await FirebaseMessaging.instance.getToken();
      print("fCMToken $fCMToken");
      sendNotification(fCMToken!,'for tst');
      if (fCMToken != null) {
        await setFcmToken(fCMToken);
      }
      // }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await setFcmToken(fcmToken);
    });

    FirebaseMessaging.onMessage.listen((payload) {
      final notification = payload.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
              content: Text("${notification.title} ${notification.body}")));
      }
    });
  }

  Future<void> setFcmToken(String fCMToken) async {
    final userID = Supabase.instance.client.auth.currentUser!.id;
    print("ID : $userID");
    if (userID != null) {
      // await  Supabase.instance.client.from('profile').update({
      //   // 'id':userID,
      //   'fcmToken':fCMToken.toString()
      // }).eq('id', userID);
      await Supabase.instance.client.from('profiles').upsert({
        'id': userID,
        'fcmToken': fCMToken.toString()
      }).eq('id', userID).not('email', 'eq', 'test@example.com');
    }
  }

  Future<void> getOldFcmToken() async {
    final userID = Supabase.instance.client.auth.currentUser!.id;
    var response = await Supabase.instance.client.from('profile').select(
        ''' fcmToken  ''').match({'id': userID});
    print('Response = $response');
  }

  Widget dataUI({required PromptModel item}) {
    return Card(
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Imageview(imgUrl: item.imageUrl!)));
            },
            child: Container(
              alignment: Alignment.bottomRight,
              height: screenWidth / 3.5,
              width: screenWidth / 3.5,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12)),
                  // border: Border.all(color: Colors.black),
                  image: item.imageUrl == null
                      ? const DecorationImage(
                      image: NetworkImage(
                          "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg="))
                      : DecorationImage(
                      image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)),

            ),
          ),
          Container(
            // height: screenWidth/5,
            width: screenWidth - 200,
            margin: const EdgeInsets.only(
                left: 20, right: 10, bottom: 10, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // item.users!.metadata!.name.toString(),
                  item.userName.toString(),
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10,),

                txtWidget(title: "Title", value: item.title.toString()),
                txtWidget(title: "Prompt", value: item.prompt.toString()),
              ],
            ),
          )
        ],
      ),
    );
  }

  txtWidget({required String title, required String value}) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(title, style: const TextStyle(fontSize: 12)),),
        Expanded(
            flex: 2,
            child: Text(value, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500, /*fontFamily: "Agdasima"*/),)),
      ],
    );
  }

  void prompListFill(dynamic event) async {
    // Supabase.instance.client
    //     .from("promp")
    //     .stream(primaryKey: ['id']).order(
    //     "id",
    //     ascending: false).listen((event)async {
    //       if(mounted){

    prompList =
        (await event as List).map((e) => PromptModel.fromJson(e)).toList();

    /// For images add on list-------------------------------------
    List<String> _fileNames = [];
    final responseStorage =
    await Supabase.instance.client.storage.from('flutterflowbucket').list();

    // Extract file names from the response
    _fileNames = responseStorage.map((file) => file.name).toList();

    for (var element in prompList) {
      final imagePath = '/${element.userId}/flutterflowbucket';
      print("ID = ${element.userId}");
      for (var file in _fileNames) {
        if (file == element.userId) {
          print("Id is Matched--------");
          element.imageUrl = Supabase.instance.client.storage
              .from('flutterflowbucket')
              .getPublicUrl(imagePath);
        }
      }
    }

    /// For users add on List-----------------------

    for (var element in prompList) {
      for (var u in userList) {
        if (element.userId == u.id) {
          // element.users!.metadata!.name = u.metadata!.name;
          element.userName = u.metadata!.name;
          // print("element.users!.metadata!.name ${element.users!.metadata!.name}");
        }
      }
    }
    setState(() {
      isLoading = false;
    });
    // }
    // });
    // });
  }

  @override
  void onConnectionError(String error, String requestCode) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please check Internet")));
  }

  @override
  void onError(String errorMsg, String requestCode, String statusCode) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)));
  }

  @override
  void onSuccess(object, String strMsg, String requestCode) {
    if (mounted) {
      if (requestCode.contains(RequestCode.GET_ALL_USERS)) {
        userList =
            (object as List).map((e) => userModel.fromJson(e)).toList();
        print("Userlist ${userList.length}");

        /// For user prompts api-----------------
        ApiPresenter(this).getUserPrompt();
      } else if (requestCode.contains(RequestCode.GET_USER_PROMPT)) {
        prompListFill(object);
      }
    }
  }
}