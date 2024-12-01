import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myproject/drawerCllass.dart';
import 'package:myproject/utils/commonMethods.dart';
import 'package:wheel_slider/wheel_slider.dart';
import 'package:http/http.dart' as http;
class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  String currentWeightType = "Kg";
  String targetWeightType = "Kg";

  String heightType = "Ft";
  final int _totalCount = 100;
  final int _totalCount2 = 100;

  double _currentKgValue = 0.0;
  // int _currentKgValue = 0;

  // int _nCurrentLbValue = 0;
  double _nCurrentLbValue = 0.0;

  double _targetLbValue = 0.0;
  double _targetKgValue = 0.0;

  int valueDemo = 0;

  int currentValueView = 0;
  int targetValueView = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProducts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clorify Weight'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _whatCurrentWeight()
        ],
      ),
      drawer: const DrawerClass(screenName: "Clorify Weight"),
    );
  }

  _whatCurrentWeight() {
    return SingleChildScrollView(
      // width: screenWidth,
      // height: screenHeight,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
      child: Column(children: [
        _titleWidget('What’s your current weight?',
            topMargin: 0, bottomMargin: 10.0),
        Card(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                kgAndLbWidget(txt: 'Kg', type: "current"), // index: 1),
                kgAndLbWidget(txt: 'lb', type: "current"), // index: 2),
                /// update
              ],
            ),


          // currentWeightType == "Kg" ? _wheelViewWidget(type: "current", initialValue:  _currentKgValue.toInt()) : _wheelViewWidget(type: "current", initialValue:  _nCurrentLbValue.toInt()),
                Visibility(
                    visible: currentWeightType == "Kg" ,
                    child: _wheelViewWidget(type: "current", initialValue:  currentValueView)),
                    // child: _wheelViewWidget(type: "current", initialValue:  _currentKgValue.toInt())),

            Visibility(
                    visible: currentWeightType == "lb" ,
                    child:  _wheelViewWidget(type: "current", initialValue:  currentValueView)),
                    // child:  _wheelViewWidget(type: "current", initialValue:  _nCurrentLbValue.toInt())),

            // Text(currentWeightType == "Kg" ? "$_currentKgValue" : "$_nCurrentLbValue")
            Text("$currentValueView ${currentWeightType == "Kg" ? "kg" : "lb"}")
          ]),
        ),

        _titleWidget('What’s your target weight?',
            topMargin: 40, bottomMargin: 10.0),
        Card(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              kgAndLbWidget(txt: 'Kg', type: "target"), // index: 3),
              kgAndLbWidget(txt: 'lb', type: "target"), // index: 4),
            ],
          ),
              Visibility(
                  visible: targetWeightType == "Kg" ,
                  child: _wheelViewWidget(type: "target", initialValue:  targetValueView)),
                  // child: _wheelViewWidget(type: "target", initialValue:  _targetKgValue.toInt())),

              Visibility(
                  visible: targetWeightType == "lb" ,
                  child:  _wheelViewWidget(type: "target", initialValue:  targetValueView)),
                  // child:  _wheelViewWidget(type: "target", initialValue:  _targetLbValue.toInt())),
          Text("$targetValueView ${targetWeightType == "Kg" ? "kg" : "lb"}"),
          // Text(targetWeightType == "Kg" ? "$_targetKgValue" : "$_targetLbValue"),

        ])),
      ]),
    );

  }

  _wheelViewWidget({required String type, required int initialValue}) {
    return  WheelSlider(
            // interval: 0.5,
            interval:1,
            isVibrate: true,
            totalCount:  _totalCount,
            isInfinite: false,
            initValue: initialValue,
            // initValue: 10,
            // currentIndex: null,
            // animationType: Curves.bounceInOut,
            onValueChanged: (val) {
              setState(() {
                print("Value $val");
                if(type == "current") {
                  // valueDemo = int.parse(val.toString());
                  valueDemo = val;
                  // currentValueView = int.parse(val.toString());
                  currentValueView = val;
                }else{
                  targetValueView = val;
                }
                // if (type == "current") {
                //   if (currentWeightType == "Kg") {
                //     _currentKgValue = val;
                //   } else {
                //     _nCurrentLbValue = val;
                //   }
                // } else if (type == "target") {
                //   if (targetWeightType == "Kg") {
                //     _targetKgValue = val;
                //   } else {
                //     _targetLbValue = val;
                //   }
                // }
              });
            },
            // hapticFeedbackType: HapticFeedbackType.vibrate,
            // currentIndex: initialValue,
          );
  }

  _titleWidget(String title,
      {double topMargin = 0,
      double bottomMargin = 0,
      double size = 22,
      Color clr = Colors.black,
      FontWeight fontWeight = FontWeight.w700,
      TextAlign textAlign = TextAlign.center}) {
    return Container(
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
      child: Text(
        title,
        textAlign: textAlign,
        // overflow: TextOverflow.ellipsis,
      ),
    );
  }

  kgAndLbWidget({required String txt, String type = ""}) {
    return Card(
      margin: const EdgeInsets.all(20),
      color: Colors.white,
      // margin: const EdgeInsets.only(top: 40,),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            if (type == "current") {
              // if(currentWeightType == "Kg") {
              currentWeightType = txt;
              print("currentWeightType $currentWeightType");
              if(txt == "Kg"){
                // var kg =(valueDemo *  0.45359237);
                var kg =(currentValueView *  0.45359237);
                print("Kg = $kg");
                // _currentKgValue = double.tryParse(kg.toString())!;
                currentValueView = int.parse(CommonMethods.decimalPlaces(kg.toString(),decimals: 0));
              }else{
                // var lbs = (valueDemo / 0.45359237);
                var lbs = (currentValueView / 0.45359237);
                print("lbs : $lbs");
                // _nCurrentLbValue = double.tryParse(lbs.toString())!;
                currentValueView = int.parse(CommonMethods.decimalPlaces(lbs.toString(),decimals: 0));
              }
              // }
            } else {
              targetWeightType = txt;
              print("targetWeightType $targetWeightType");
              if(txt == "Kg"){
                // var kg =(valueDemo *  0.45359237);
                var kg =(targetValueView *  0.45359237);
                print("Kg = $kg");
                // _currentKgValue = double.tryParse(kg.toString())!;
                targetValueView = int.parse(CommonMethods.decimalPlaces(kg.toString(),decimals: 0));
              }else{
                // var lbs = (valueDemo / 0.45359237);
                var lbs = (targetValueView / 0.45359237);
                print("lbs : $lbs");
                // _nCurrentLbValue = double.tryParse(lbs.toString())!;
                targetValueView = int.parse(CommonMethods.decimalPlaces(lbs.toString(),decimals: 0));
              }
            }
          });
        },
        child: /*txt == "Kg" || txt == "Ft"*/ type == "current"
            ? Container(
                height: 40,
                width: 100,
                // margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color:
                        currentWeightType == txt ? Colors.green : Colors.white,
                    // color: weightCurrentIndex == index ? primaryColor1 : whiteColor,
                    borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.center,
                child: Text(txt),
              )
            : Container(
                height: 40,
                width: 100,
                // margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    // color: currentWeightType == txt || targetWeightType == txt ? Colors.green : Colors.white,
                    color:
                        targetWeightType == txt ? Colors.green : Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.center,
                child: Text(txt),
              ),
      ),
    );
  }

  Future<void> fetchProducts() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      // print("jsonData ${jsonEncode(jsonData)}");
      setState(() {
      List<Product>  products = jsonData.map((data) => Product.fromJson(data)).toList();
      print("products ${products.length}");
      });
    } else {
      // Handle error if needed
    }
  }

}
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: json['rating']['rate'].toDouble(),
    );
  }
}
