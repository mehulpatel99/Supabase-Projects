import 'package:flutter/material.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../AuthScreens/style_constant.dart';
class PromptAdd extends StatefulWidget {
  const PromptAdd({super.key});

  @override
  State<PromptAdd> createState() => _PromptAddState();
}

class _PromptAddState extends State<PromptAdd> {
  TextEditingController titleController = TextEditingController();

  TextEditingController prompController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    prompController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Propmt"),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            textField(controller: titleController,labelTxt: "Title",hintTxt: "Enter title"),
            const SizedBox(height: 20,),
            textField(controller: prompController,labelTxt: "Prompt",hintTxt: "Enter prompt",isPromp: true),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: () async {
              CommonMethods.insertPrompt(context, title: titleController.text, prompt: prompController.text);
              await CommonMethods.listenChanges();
              },style: commonButtonStyle(), child: const Text("Submit"),)
          ],
        ),
      ),
    );
  }
  textField({required TextEditingController controller,String labelTxt = '',String hintTxt = '',bool isPromp = false}) {
    return  TextFormField(
      maxLines: isPromp ? 3 : 1,
      controller: controller,
      // maxLength: isPromp ? 3 : 1,
      validator: (value) {
        if(value!.isEmpty){
          return "Required this $labelTxt";
        }
      },
      decoration: InputDecoration(labelText: labelTxt,hintText: hintTxt,border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
      ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:const BorderSide(width: 2.5)
          )
      ),
    );
  }
}
