import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myproject/api/apiCallBack.dart';
import 'package:myproject/api/apiPresenter.dart';
import 'package:myproject/api/requestCode.dart';
import 'package:myproject/drawerCllass.dart';
import 'package:myproject/home_page.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:myproject/utils/imageFullScreen.dart';
import 'package:myproject/utils/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'AuthScreens/style_constant.dart';
import 'model_prompt.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> implements  ApiCallBacks {
  String? name;
  String? phone;

  String? email;

  bool isData = false;

  List<PromptModel> userPromptList = [];

  bool isLoading = false;

  String? _imageUrl;

  bool isEdit = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isEditLoader = false;

  bool isPromptEdit = false;

  var userId = Supabase.instance.client.auth.currentUser!.id;

  String? selectImg;

  String imgLike = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    demoUser();
    getUserPromptReal();
    // getUser();
  }

  @override
  void dispose() {
    // Cancel the stream if the widget is disposed
    super.dispose();
    // You can also cancel the stream or listener here if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                logOutWidget();
                setState(() {});
              },
              icon: const Icon(Icons.logout)),
        ],
        title: const Text(
          "Profile",
          style: TextStyle(fontFamily: "Agdasima", fontStyle: FontStyle.italic),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      imgWidget(),
                      userDetailFields(),
                      submitBtn(),
                      // SizedBox(height: 20),
                      // promptsWidget(),
                      realTimeList(),
                    ],
                  ),
                ),
          isEditLoader
              ? const Center(child: CircularProgressIndicator())
              : Container()
        ],
      ),
      drawer: const DrawerClass(screenName: "Profile"),
    );
  }

  // getUser() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final currentUser = Supabase.instance.client.auth.currentUser;
  //   if (currentUser != null) {
  //
  //     final response = await Supabase.instance.client.from('users').select('metadata').eq('id', userId).single();
  //     if (response != null) {
  //       // Update the variables with the latest data
  //       final metadata = response['metadata'];
  //       name = metadata['name'];
  //       phone = metadata['phone'];
  //       email = currentUser.email;
  //
  //       // Update the controller with the latest name
  //       nameController.text = name.toString();
  //     } else {
  //       print('User not found');
  //     }
  //   } else {
  //     print("User is null");
  //   }
  //   print("User = $name");
  //
  //   /// Fetch Prompts LIst---------------------------
  //   // fetchUserPrompt();
  //   userImage();
  // }

  final StreamController<bool> controller = StreamController<bool>.broadcast();

  /// For Real Time changes -------------------------------------
  realTimeList() {
    return Expanded(
      child: StreamBuilder(
        stream: controller.stream,
        builder: (context, snapshot) {
          if (userPromptList.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: userPromptList.length,
              // itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return CommonMethods.dataUI(context,
                    item: userPromptList[index],
                    // item: PromptModel.fromJson(snapshot.data[index]),
                    index: index,
                    onDeleteTap: () {
                      // deletePromp(id: userPromptList[index].id!, index: index);
                      ApiPresenter(this).deleteUserPrompt(id: userPromptList[index].id!,tableName: 'promp');
                    },
                    isEditAndDelete: true,
                    isEdit: isPromptEdit,
                    onEditTap: () {
                      setState(() {
                        isPromptEdit = !isPromptEdit;
                      });
                    });
              },
            );
          } else {
            return Container(
                margin: const EdgeInsets.only(top: 100),
                child: const Text("No prompt found"));
          }
        },
      ),
    );
  }

  void fetchUserPrompt() async {
    userPromptList = (await CommonMethods.fetchUserPrompts() as List)
        .map((e) => PromptModel.fromJson(e))
        .toList();
    print("PrompList : ${userPromptList.length}");
    // if (userPromptList.isEmpty) {
    //   isData = true;
    // }
    // setState(() {
    //   isLoading = false;
    // });

  }

  logOutWidget() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure want to logout!"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              CommonMethods.signOut(context);
              SessionManager.remove();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  imgWidget() {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          if (selectImg != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Imageview(imgUrl: selectImg!, isFile: true,)));
          } else if (_imageUrl != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Imageview(imgUrl: _imageUrl!)));
          }
        },
        child: Container(
          alignment: Alignment.bottomRight,
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.black),
              image: selectImg == null
                  ? _imageUrl == null
                      ? const DecorationImage(
                          image: NetworkImage(
                              "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg="))
                      : DecorationImage(
                          image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                  : DecorationImage(
                      image: FileImage(File(selectImg!)), fit: BoxFit.cover)),
          child: InkWell(
              onTap: () {
                imgSelect();
                // var imageUrl;
                // imageUrl = await CommonMethods.imageUpdate(context, isUpdate: _imageUrl != null);
                // _imageUrl = imageUrl;
                // print("Update Image :> $_imageUrl");
                // setState(() {});
              },
              child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 15,
                  ))),
        ),
      ),
    );
  }

  Future<void> profileNameUpdate() async {
    if (isEdit) {
      ApiPresenter(this).updateUserData(name: nameController.text,phone: phoneController.text);
      // final user_id = await Supabase.instance.client.auth.currentUser!.id;
      // await Supabase.instance.client.from("users").update({"metadata": {"name": nameController.text,"phone":phone}}).eq("id", user_id);
      //      setState(() {
      //        isEdit = false;
      //        print('-------------------------false');
      //      });
    } else {
      isEdit = true;
    }
  }

  textField({TextEditingController? controller, bool isBool = false}) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: nameController,
        textAlign: TextAlign.center,
        enabled: isEdit,
        decoration: InputDecoration(
          border: isEdit
              ? const UnderlineInputBorder()
              : InputBorder.none, // Remove the underline
        ),
        scrollPadding: const EdgeInsets.only(left: 20),
        style: const TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> userImage() async {
    final imagePath = '/$userId/flutterflowbucket';
    final imageUrl = Supabase.instance.client.storage
        .from('flutterflowbucket')
        .getPublicUrl(imagePath);

    List<userModel> usersList = await CommonMethods.fetchUsers();
    for (int i = 0; i < usersList.length; i++) {
      if (usersList[i].imageUrl == imageUrl) {

        _imageUrl = imageUrl;

      }
    }
    print("_imageUrl $_imageUrl");
    setState(() {
      isLoading = false;
    });
  }



  Future<void> imgSelect() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final imagePath = '/$userId/flutterflowbucket';
    if (image != null) {
      setState(() {
        // isLoading = true;
        selectImg = image.path;
      });
      final file = File(image.path);
      _imageUrl != null

          ? Supabase.instance.client.storage
              .from('flutterflowbucket')
              .update(imagePath, file)

          : Supabase.instance.client.storage
              .from('flutterflowbucket')
              .upload(imagePath, file);
      //     .then((value)  {
      //    _imageUrl =  Supabase.instance.client.storage.from('flutterflowbucket').getPublicUrl(imagePath);
      //   print("Update imageUrl : $_imageUrl");
      //   print("UserId = $userId");
      //   setState(() {});
      //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Profile(),));
      //   // userImage();
      // });

    }
  }

  userDetailFields() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            enabled: isEdit,
            decoration: InputDecoration(
              border: isEdit
                  ? const UnderlineInputBorder()
                  : InputBorder.none, // Remove the underline
            ),
            scrollPadding: const EdgeInsets.only(left: 20),
            style: const TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          "$email",
          style: const TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        if (phone != null)
          // Text(
          //   "$phone",
          //   style: const TextStyle(
          //       fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          // ),
        SizedBox(
          height: 50,
          child: TextField(
            controller: phoneController,
            textAlign: TextAlign.center,
            enabled: isEdit,
            decoration: InputDecoration(
              border: isEdit
                  ? const UnderlineInputBorder()
                  : InputBorder.none, // Remove the underline
            ),
            scrollPadding: const EdgeInsets.only(left: 20),
            style: const TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  submitBtn() {
    return SizedBox(
        width: 100,
        child: ElevatedButton(
            onPressed: () async {
              profileNameUpdate();
              setState(() {});
            },
            style: commonButtonStyle(height: 30),
            child: Text(isEdit ? "Submit" : "Edit")));
  }

  // void deletePromp({required int id, required int index}) {
  //   CommonMethods.deletePrompt(context, id: id, tableName: "promp");
  //   setState(() {
  //     userPromptList.removeAt(index);
  //   });
  // }

 getUserPromptReal() async {
      ApiPresenter(this).getUserPrompt();
   // return Supabase.instance.client.from("promp").stream(primaryKey: ["id"]).order("id",ascending: false);

  // await Supabase.instance.client
  //       .from("promp")
  //       .stream(primaryKey: ["id"])
  //       // .eq("user_id", currentUserId)
  //       .order("id", ascending: false).listen((event) {
  //         print("Prompt Table Updated");
  //           userPromptList = (event as List).map((e) => PromptModel.fromJson(e)).toList();
  //           userPromptList.removeWhere((newvalue) =>newvalue.userId != currentUserId);
  //
  //         controller.add(true);
  //  });
  }


  void demoUser() async {
    setState(() {
      isLoading = true;
    });
    ApiPresenter(this).getUserProfileData();
   // if(mounted){
   //   await Supabase.instance.client.from('users').stream(primaryKey: ['id']).eq('id', userId).listen((event) {
   //    if(mounted){
   //      print("UserEvent ${event.first['metadata']['name']}");
   //      name = event.first['metadata']['name'];
   //      phone = event.first['metadata']['phone'];
   //      email = event.first['email'];
   //      nameController.text = name.toString();
   //      // setState(() {
   //      // });
   //    }
   //   });
   // }
     userImage();
  }

  @override
  void onConnectionError(String error, String requestCode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please check Internet")));
  }

  @override
  void onError(String errorMsg, String requestCode, String statusCode) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
  }

  @override
  void onSuccess(object, String strMsg, String requestCode) {
    if(mounted) {
      if (requestCode.contains(RequestCode.GET_USER_INFO)) {
        print("UserName ${object.first['metadata']['name']}");
        print("Response ${object}");
        // userModel model = userModel.fromJson(object);
        name = object.first['metadata']['name'];
        phone = object.first['metadata']['phone'];
        email = object.first['email'];
        // imgLike = object.first['metadata']['imgLike'];
        nameController.text = name.toString();
        phoneController.text = phone.toString();
        // setState(() {
        // });
      }else if(requestCode.contains(RequestCode.UPDATE_USER_INFO)){
        isEdit = false;

      }else if(requestCode.contains(RequestCode.GET_USER_PROMPT)){
        userPromptList = (object as List).map((e) => PromptModel.fromJson(e)).toList();
        userPromptList.removeWhere((newvalue) =>newvalue.userId != userId);

        controller.add(true);
      }else if(requestCode.contains(RequestCode.DELETE_USER_PROMPT)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strMsg),backgroundColor: Colors.green,));
      }

      setState(() {});
    }
  }
}
