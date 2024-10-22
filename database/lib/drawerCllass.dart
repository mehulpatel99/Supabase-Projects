import 'package:flutter/material.dart';
import 'package:myproject/allUsers.dart';
import 'package:myproject/home_page.dart';
import 'package:myproject/profle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerClass extends StatefulWidget {
  final String screenName;
  const DrawerClass({super.key,required this.screenName});

  @override
  State<DrawerClass> createState() => _DrawerClassState();
}

class _DrawerClassState extends State<DrawerClass> {
  String? selectScreen;
  List<DrawerModel> drawerList = [];

  String? name;

  String? email;
  fillDrawerList(){
    drawerList.add(DrawerModel(title: "Home",icon: Icons.home,redirect: const HomePage()));
    drawerList.add(DrawerModel(title: "Profile",icon: Icons.person_pin_sharp,redirect: const Profile()));
    drawerList.add(DrawerModel(title: "Promptia Users",icon: Icons.supervised_user_circle,redirect: const AllUsers()));
    drawerList.forEach((element) {
      if(element.title == widget.screenName){
        element.isSelect = true;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fillDrawerList();
    getPromptiaUser();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children:  [
           DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.3)),
            child: Center(
              child: ListTile(
                leading: CircleAvatar(
                  // backgroundColor: Color.fromARGB(255, 165, 255, 137),
                  child: Text(
                    name![0].toUpperCase(),
                    style: const TextStyle(fontSize: 20.0,),
                  ), //Text
                ),
                title: Text(
                  name.toString(),
                  style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                ),
                subtitle:  Text(
                  email.toString(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: drawerList.length,shrinkWrap: true,itemBuilder: (context, index) {
            return  drawerUI(item: drawerList[index]);
          },)
        ],
      ),
    );
  }

   drawerUI({required DrawerModel item}) {
    return Container(
      margin: const EdgeInsets.only(left: 10,right: 10),
      decoration: BoxDecoration(
        color: item.isSelect! ?  Colors.deepPurpleAccent.withOpacity(0.3): null,
        borderRadius: BorderRadius.circular(20)
      ),
      child: ListTile(
        leading: Icon(item.icon,color: item.isSelect! ? Colors.deepPurple : Colors.black,),
        title: Text(item.title.toString(),style: TextStyle(fontWeight: item.isSelect! ? FontWeight.bold : FontWeight.normal,color:  item.isSelect! ? Colors.deepPurple : Colors.black),),
        onTap: (){
          setState(() {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => item.redirect!));
          });
        },
      ),
    );
   }

  void getPromptiaUser() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      name = currentUser.userMetadata!["name"];
      email = currentUser.email;
    }
    setState(() { });
  }
}

class DrawerModel{
  String? title;
  IconData? icon;
  bool? isSelect;
  Widget? redirect;
  DrawerModel({this.title, this.icon,this.isSelect = false,this.redirect});
}
