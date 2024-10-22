import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myproject/drawerCllass.dart';
import 'package:myproject/home_page.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:myproject/utils/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'AuthScreens/style_constant.dart';
import 'model_prompt.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name;

  String? email;

  bool isData = false;

  List<PromptModel> userPromptList = [];

  bool isLoading = false;

  String? _imageUrl;

  bool isEdit = false;

  TextEditingController nameController = TextEditingController();

  bool isEditLoader = false;

  bool isPromptEdit = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    getUser();
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
        title: const Text("Profile"),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                imgWidget(),
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
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "$email",
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                        onPressed: () async {
                          profileNameUpdate();
                          setState(() {});
                        },
                        style: commonButtonStyle(height: 30),
                        child: Text(isEdit ? "Submit" : "Edit"))),
                // SizedBox(height: 20),
                promptsWidget(),
              ],
            ),
          ),
          isEditLoader
              ? const Center(child: CircularProgressIndicator())
              : Container()
        ],
      ),
      drawer: DrawerClass(screenName: "Profile"),
    );
  }

  getUser() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      name = currentUser.userMetadata!["name"];
      email = currentUser.email;
      nameController.text = name.toString();
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final imagePath = '/$userId/flutterflowbucket';
      final imageUrl = Supabase.instance.client.storage
          .from('flutterflowbucket')
          .getPublicUrl(imagePath);
        _imageUrl = imageUrl;
      print("_imageUrl $_imageUrl");
    } else {
      print("User is null");
    }
    print("User = $name");

    /// Fetch Prompts LIst---------------------------
    fetchUserPrompt();
  }

  promptsWidget() {
    return isLoading
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const CircularProgressIndicator(),
          )
        : isData
            ? Container(
                margin: const EdgeInsets.only(top: 100),
                child: const Text("No Data Found"))
            : Expanded(
                child: ListView.builder(
                shrinkWrap: true,
                itemCount: userPromptList.length,
                itemBuilder: (context, index) {
                  return CommonMethods.dataUI(context,
                      item: userPromptList[index],
                      isEditAndDelete: true,isEdit: isPromptEdit,onEditTap: (){
                    setState(() {
                      isPromptEdit = !isPromptEdit;
                    });
                      }); //dataUI(item: userPromptList[index]);
                },
              ));
  }

  void fetchUserPrompt() async {
    userPromptList = (await CommonMethods.fetchUserPrompts() as List)
        .map((e) => PromptModel.fromJson(e))
        .toList();
    print("PrompList : ${userPromptList.length}");
    if (userPromptList.isEmpty) {
      isData = true;
    }
    setState(() {
      isLoading = false;
    });
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
      child: Container(
        alignment: Alignment.bottomRight,
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black),
            image: _imageUrl == null
                ? const DecorationImage(
                    image: NetworkImage(
                        "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg="))
                : DecorationImage(
                    image: NetworkImage(_imageUrl!), fit: BoxFit.cover)),
        child: InkWell(
            onTap: () async {
              // imgSelect();
              _imageUrl = await CommonMethods.imageUpdate();
              setState(() {});
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
    );
  }

  Future<void> profileNameUpdate() async {
    if (isEdit) {
      isEditLoader = true;
      final user_id = await Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from("users")
          .update({
            "metadata": {"name": nameController.text}
          })
          .eq("id", user_id)
          .then((value) {
            isEdit = false;
            isEditLoader = false;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Profile(),
                ));
          });
      await CommonMethods.listenChanges();
    } else {
      isEdit = true;
    }
  }
   textField({TextEditingController? controller,bool isBool = false}){
    return  SizedBox(
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
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
