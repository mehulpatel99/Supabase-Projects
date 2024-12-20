import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myproject/AuthScreens/login.dart';
import 'package:myproject/model_prompt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import '../profle.dart';

class CommonMethods{

  var currentUser = Supabase.instance.client.auth.currentUser;
  /// Listen for changes----------------------
  static  listenChanges()async{
   await Supabase.instance.client
        .channel('public:users')
        .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'users',
        callback: (payload) {
          PromptModel model = PromptModel.fromJson(payload.newRecord["newRow"]);
          updateFeed(model: model);
          print('Insert event received: ${payload.toString()}');
        })
       .onPostgresChanges(
     event: PostgresChangeEvent.update,
     schema: 'public',
     table: 'users',
     callback: (payload) {
       PromptModel model = PromptModel.fromJson(payload.newRecord["newRow"]);
       updateFeed(model: model);
       print('Update event received: ${payload.toString()}');
     },
   )
        .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'promp',
        callback: (payload) {
          print('Delete event received: ${payload.toString()}');
        })
        .subscribe();

  }

  /// for delete item in supabase table-----------------
  static  deletePrompt(BuildContext context,{required int id,required String tableName}) async {
    await Supabase.instance.client.from(tableName).delete().match({"id":id}).then((value){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profile()));
    });
  }

  /// For insert prompt in table---------------------
  static  insertPrompt(BuildContext context,{required String title,required String prompt})async{
    await Supabase.instance.client.from("promp").insert({
      "title": title,
      "prompt" : prompt,
      "user_id" : Supabase.instance.client.auth.currentUser!.id,
    }
    ).then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Addedd")));
    });
  }

  /// Fetch Prompts from table---------------------------------------
   static fetchAllPrompts() async{
     var response = Supabase.instance.client.from("promp").select(''' id,title, prompt , user_id,created_at,users:user_id(metadata,email) ''').order("id",ascending: false);
     List<dynamic> response2 = await response;
     fetchUsers();
     if(response2.isNotEmpty){
       return response2;
     }
   }

   /// Fetch Only Authintication users------------------------------
static fetchUsers()async{
  var response = Supabase.instance.client.from("users").select().order("id",ascending: false);
  List<dynamic> response2 = await response;
  print("response2 : ${jsonEncode(response2)}");
  List<userModel> usersList = response2.map((e) => userModel.fromJson(e)).toList();
  print("usersList : ${usersList.length}");


  List<String> _fileNames = [];
  final responseStorage = await Supabase.instance.client.storage
      .from('flutterflowbucket') // Replace with your bucket name
      .list();

    // Extract file names from the response
    _fileNames = responseStorage.map((file) => file.name).toList();

  for(var element in usersList){
    final imagePath = '/${element.id}/flutterflowbucket';

    for(var file in _fileNames){
      // print('This is file name loop');
      // print('element id = ${element.id}');
      // print('file id = ${file.toString()}');
      if(file == element.id){
        print("Id is Matched--------");
        element.imageUrl =  Supabase.instance.client.storage
            .from('flutterflowbucket').getPublicUrl(imagePath);
      }
    }
    print("ImageUrl = ${element.imageUrl}");
  }
  // for(var m in _fileNames) {
  //   print("FIle names = ${m}");
  // }
  if(response2.isNotEmpty){
    return usersList;
  }
}

/// Fetch User Prompts---------------------------
   static fetchUserPrompts() async{
     var response = Supabase.instance.client
         .from("promp")
         .select(''' id,title, prompt , user_id,created_at,users:user_id(metadata,email) ''')
         .match({"user_id": Supabase.instance.client.auth.currentUser!.id})
         .order("id",ascending: false);
     List<dynamic> response2 = await response;
     if(response2.isNotEmpty){
       return response2;
     }else{
       return [];
     }
   }

   static Stream getUserPromptReal(){
    return Supabase.instance.client.from("promp").stream(primaryKey: ["id"]);
    }
   /// For user sign out ------------------------
   static signOut(BuildContext context) async{
    if(Supabase.instance.client.auth.currentUser != null){
      await Supabase.instance.client.auth.signOut().then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())));
    }
   }

   /// To Update Feed --------
   static updateFeed({required PromptModel model,/*required List<PromptModel> list*/})async{
    List<dynamic> user = await Supabase.instance.client.from("users").select("email, metadata").match({"id":model.userId.toString()});
    if(user.isNotEmpty){
      model.users = Users.fromJson(user[0]);
      // list.insert(0, model);
    }
  }

  /// For Profile Image Update and Get  --------------------------
 static Future<String> imageUpdate() async {
    final ImagePicker picker = ImagePicker();
    String? imageUrl;
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      final file = File(image.path);
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final imagePath = '/$userId/flutterflowbucket';
      await Supabase.instance.client.storage.from('flutterflowbucket').update(imagePath, file).then((value) {
         imageUrl = Supabase.instance.client.storage.from('flutterflowbucket').getPublicUrl(imagePath);
        print("imageUrl : $imageUrl");
        print("UserId = $userId");
      });
    }
   return imageUrl!;
  }


  /// Profile Image Upload in Database---------
  static profileUpload({required String userID,required XFile? image})async{
    final userId =  userID;
    final imagePath = '/$userId/flutterflowbucket';
    final file = File(image!.path);
    await Supabase.instance.client.storage.from('flutterflowbucket').upload(imagePath, file);
  }


 static dataUI(BuildContext context,{required PromptModel item,bool isEditAndDelete = false,bool isEdit = false,Function? onEditTap}) {
   TextEditingController titleController = TextEditingController();
   TextEditingController promptController = TextEditingController();
   titleController.text = item.title.toString();
   promptController.text = item.prompt.toString();

    DateTime dateTime = DateTime.parse(item.createdAt.toString());
   var formatter = DateFormat('dd-MMM-yyyy');
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(isEditAndDelete)  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  print("ID : ${item.id}");
                  if(onEditTap != null){
                    onEditTap();
                  }
                  if(isEdit) {
                    try{
                        await Supabase.instance.client.from('promp').update({
                          'title': titleController.text,
                          'prompt': promptController.text,
                          'user_id': Supabase.instance.client.auth.currentUser!.id
                        }).match({"id":item.id!})
                          .then((value) {
                            print('updated value = $value');
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profile()));
                      });
                    }catch(e){
                      print("Exception $e");
                    }
                    print("Call update event -----------");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.green,borderRadius: BorderRadius.only(topLeft: Radius.circular(12),bottomRight: Radius.circular(12))),
                child:  Icon(isEdit ? Icons.done : Icons.edit,color: Colors.white,),
                ),
              ),
              InkWell(
                onTap: () async {
                  deletePrompt(context,id: item.id!,tableName: "promp");
                    await listenChanges();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.red,borderRadius: BorderRadius.only(topRight: Radius.circular(12),bottomLeft: Radius.circular(12))),
                  child: const Icon(Icons.delete,color: Colors.white),
                ),
              )
            ],
          ),

          ListTile(
            title: textField(controller: titleController,isEdit:isEdit),
            // title:Text(item.title.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
            subtitle: Text(formatter.format(dateTime)),
            // trailing: const Icon(Icons.copy_all),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                        flex: 1,
                        child: Text("User : ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15))),
                    Expanded(
                        flex: 3,
                        child: Text("${item.users!.metadata!.name}",style: const TextStyle(fontSize: 15))),
                  ],
                ),
                Row(
                  children: [
                     Expanded(
                        flex: 1,
                        child: Text("Prompt : ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15))),
                    Expanded(
                        flex: 3,
                        // child: Text("${item.prompt}",style: const TextStyle(fontSize: 15))),
                      child:textField(isEdit: isEdit,controller: promptController,isPrompt:true) , ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date);
    var formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(dateTime);
  }
 static textField({TextEditingController? controller, required bool isEdit, bool isPrompt = false}){
    return  SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.start,
        enabled: isEdit,
        decoration: InputDecoration(
          border: isEdit
              ? const UnderlineInputBorder()
              : InputBorder.none, // Remove the underline
        ),
        scrollPadding: const EdgeInsets.only(left: 20),
        style:  TextStyle(
            fontSize:isPrompt ? 15 : 18,
            color: Colors.black,
            fontWeight:isPrompt ?FontWeight.normal : FontWeight.bold),
      ),
    );
  }
}
class userModel {
  String? id;
  String? createdAt;
  String? email;
  String? imageUrl;
  Metadata? metadata;

  userModel({this.id, this.createdAt, this.email, this.metadata,this.imageUrl});

  userModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    email = json['email'];
    imageUrl = json['imageUrl'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['email'] = this.email;
    data['imageUrl'] = this.imageUrl;
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    return data;
  }
}

class Metadata {
  String? name;

  Metadata({this.name});

  Metadata.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
