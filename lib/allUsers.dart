import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myproject/api/apiCallBack.dart';
import 'package:myproject/api/apiPresenter.dart';
import 'package:myproject/api/requestCode.dart';
import 'package:myproject/drawerCllass.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:myproject/utils/heartAnimation.dart';
import 'package:myproject/utils/imageFullScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> implements ApiCallBacks {
  List<userModel> userList = [];
  bool isLoading = false;

  double screenWidth = 0.0;

  bool isHeartAnimation = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    ApiPresenter(this).getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promptia Users"),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        return listUI(item: userList[index]);
                      },
                    ),
                  )
          ],
        ),
      ),
      drawer: const DrawerClass(screenName: "Promptia Users"),
    );
  }

  Future<void> fetchUsers(dynamic event) async {
    // userList = await CommonMethods.fetchUsers();
    // var response = Supabase.instance.client
    //     .from("users")
    //     .stream(primaryKey: ['id'])
    //     .order("id", ascending: false)
    //     .listen((event) async {

    List<dynamic> response2 = event;
    // print("response2 : ${jsonEncode(response2)}");
    List<userModel> usersList =
        response2.map((e) => userModel.fromJson(e)).toList();
    print("usersList : ${usersList.length}");

    List<String> _fileNames = [];
    final responseStorage =
        await Supabase.instance.client.storage.from('flutterflowbucket').list();

    // Extract file names from the response
    _fileNames = responseStorage.map((file) => file.name).toList();

    for (var element in usersList) {
      final imagePath = '/${element.id}/flutterflowbucket';

      for (var file in _fileNames) {
        if (file == element.id) {
          // print("Id is Matched--------");
          element.imageUrl = Supabase.instance.client.storage
              .from('flutterflowbucket')
              .getPublicUrl(imagePath);
        }
      }
      // print("ImageUrl = ${element.imageUrl}");
    }

    userList = usersList;
    print("userList => ${userList.length}");
    isLoading = false;
    setState(() {});
    // });
  }

  listUI({required userModel item}) {
    String demoImg =
        "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg=";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.bottomRight,
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black),
                        image: item.imageUrl == null
                            ? DecorationImage(
                                image: NetworkImage(demoImg.toString()))
                            : DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover)),
                  ),
                  if (item.metadata!.name != null)
                    Text(
                      item.metadata!.name![0].toUpperCase() +
                          item.metadata!.name!.substring(1).toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    )
                ],
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
            ],
          ),
          GestureDetector(
            onDoubleTap: (){
              setState(() {
                item.isHeartAnimation = true;
                item.isLike = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Card(
                  // margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Imageview(imgUrl: item.imageUrl!)));
                        },
                        child: Container(
                          alignment: Alignment.bottomRight,
                          height: screenWidth - 150,
                          width: screenWidth - 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // border: Border.all(color: Colors.black),
                              image: item.imageUrl == null
                                  ? const DecorationImage(
                                      image: NetworkImage(
                                          "https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg="))
                                  : DecorationImage(
                                      image: NetworkImage(item.imageUrl!),
                                      fit: BoxFit.cover)),
                        ),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: item.isHeartAnimation ? 1 : 0,
                  child: HeartAnimationWidget(
                      isAnimation: item.isHeartAnimation,
                      duration: const Duration(milliseconds: 700),
                    onEnd: (){
                        setState(() {
                          item.isHeartAnimation = false;
                        });
                    },
                      child: const Icon(
                        Icons.favorite,
                        size: 50,color: Colors.white,
                      ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  HeartAnimationWidget(child: tempIcon(
                      icon:
                      item.isLike ? Icons.favorite : Icons.favorite_border,
                      clr: item.isLike ? Colors.red : Colors.black,
                      ontap: (){

                        setState(() {
                          isHeartAnimation = true;
                          item.isLike = !item.isLike;
                        });
                        if (item.isLike) {
                          likeMethod(item);
                          //   print("ID : ${item.id}");
                          //   int likes = int.parse(item.metadata!.imgLike!)+1;
                          //       ApiPresenter(this).updateUserDataForLike(
                          //           name: item.metadata!.name.toString(),
                          //           phone: item.metadata!.phone.toString(),
                          //           imgLike: likes.toString(),
                          //           id: item.id);
                        }
                      }), isAnimation: item.isLike),

                  const SizedBox(width: 10),
                  tempIcon(icon: Icons.circle_outlined),
                  const SizedBox(width: 10),
                  tempIcon(icon: Icons.telegram),
                ],
              ),
              tempIcon(icon: Icons.mode_comment_outlined)
              // IconButton(
              //     onPressed: () {}, icon: const Icon(Icons.mode_comment_outlined))
            ],
          ),
          Text(item.email.toString()),
          Text(item.metadata!.phone.toString()),
          // txtWidget(title: "Name",value: item.metadata!.name.toString()),
          // txtWidget(title: "Email",value: item.email.toString()),
          // txtWidget(title: "Phone no.",value: item.metadata!.phone.toString()),
        ],
      ),
    );
  }

  txtWidget({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: Text(title)),
          Expanded(
              flex: 2,
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Agdasima"),
              )),
        ],
      ),
    );
  }

  tempIcon({required IconData icon, Function? ontap,Color clr = Colors.black}) {
    return InkWell(
        onTap: () {
          if (ontap != null) {
            ontap();
          }
        },
        child: Icon(icon,color: clr,));
  }

  @override
  void onConnectionError(String error, String requestCode) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Please check Internet")));
  }

  @override
  void onError(String errorMsg, String requestCode, String statusCode) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMsg)));
  }

  @override
  void onSuccess(object, String strMsg, String requestCode) {
    if (mounted) {
      if (requestCode.contains(RequestCode.GET_ALL_USERS)) {
        fetchUsers(object);
      } else if (requestCode.contains(RequestCode.UPDATE_USER_INFO_LIKE)) {
        // ApiPresenter(this).getAllUsers();
        print("Update user api call $object");
      }
    }
  }

  Future<void> likeMethod(userModel item) async {
    try{
      await Supabase.instance.client
          .from('mylike')
          .upsert({"id":item.id,"likes": 9})
          // .eq("id", item.id!)
          .then((value) {
            print("Updated---------------------");
      });
    }catch(e){
      print("Exception => $e");
    }
  }

}
