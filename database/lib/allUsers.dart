import 'package:flutter/material.dart';
import 'package:myproject/drawerCllass.dart';
import 'package:myproject/utils/commonMethods.dart';
class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  List<userModel> userList = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    fetchUsers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promptia Users"),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            isLoading ? const Center(child: CircularProgressIndicator()) :  ListView.builder(shrinkWrap: true,itemCount: userList.length,itemBuilder: (context, index) {
              return  listUI(item: userList[index]);
            },)
          ],
        ),
      ),
      drawer: const DrawerClass(screenName: "Promptia Users"),
    );
  }

  Future<void> fetchUsers() async {
    userList = await CommonMethods.fetchUsers();
    print("userList => ${userList.length}");
    isLoading = false;
    setState(() {});
  }

   listUI({required userModel item}) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          leading: Container(
            alignment: Alignment.bottomRight,
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.black),
                image: item.imageUrl == null
                    ? const DecorationImage(
                    image: NetworkImage(
                        "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg="))
                    : DecorationImage(
                    image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)),
          ),
          title: Text("${item.metadata!.name}"),
        ),
      ),
    );
   }
}
