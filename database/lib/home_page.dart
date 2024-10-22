import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:myproject/allUsers.dart';
import 'package:myproject/profle.dart';
import 'package:myproject/promp_add.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:myproject/utils/supabase_const.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'drawerCllass.dart';
import 'model_prompt.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? name;
  String? email;
  List<PromptModel> prompList = [];

  bool isLoading = false;
  bool isData = false;
  double screenHeight = 0.0;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    // fetchPropm();
    fetchAllPrompt();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title:  const Text("Promptia"),
        // leading: const Icon(Icons.home),
      ),
      body: Container(
        height: screenHeight,
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : isData ? const Text("No Data Found") : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: prompList.length,
                      itemBuilder: (context, index) {
                        return CommonMethods.dataUI(context,item: prompList[index]);//dataUI(item: prompList[index]);
                      },),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
         Navigator.push(context, MaterialPageRoute(builder: (context) => const PromptAdd()));
      },child: const Icon(Icons.add)),
      drawer: DrawerClass(screenName: 'Home'),
    );
  }


  void fetchAllPrompt() async{
   prompList = (await CommonMethods.fetchAllPrompts() as List).map((e) => PromptModel.fromJson(e)).toList();
   print("PrompList : ${prompList.length}");
    if(prompList.isEmpty){
      isData = true;
    }
    setState(() {
      isLoading = false;
    });
  }

}

