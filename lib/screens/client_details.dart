import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDetials extends StatefulWidget {
  const ClientDetials({super.key});

  @override
  State<ClientDetials> createState() => _ClientDetialsState();
}

class _ClientDetialsState extends State<ClientDetials> {
  String? customerId = "";
  double width = 0.0, height = 0.0; 

  TextEditingController resultText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    width = w; height = h; 

    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover),),
      child: Scaffold(appBar: AppBar(title: const Text("RetailX License")),resizeToAvoidBottomInset: false,backgroundColor: Colors.transparent,
      body: Column(children: [
                Container(padding: const EdgeInsets.all(10),width: width * 0.9,height: height * 0.09, child: 
                  TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Customer ID",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                  hintText: "Customer ID",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => customerId = value,
                  ),
                ),
                
                Container(padding: const EdgeInsets.only(top: 10,),
                child: ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, child: const Text("Get Client Details",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {
                  if(customerId == "" || customerId!.isEmpty)
                  {
                    showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Enter a client's customer ID to getch details."),
                    actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
                  }
                  else {
                  getClientDetails();
                  }
                },),),


                Container(padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),height: height *0.5,width: width,
                child: TextField(controller: resultText,readOnly: true,decoration: const InputDecoration(border: InputBorder.none,),style: TextStyle(fontSize: height * 0.015),),),
      ],),),);
  }

  void getClientDetails() async
  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? baseURL = prefs.getString("baseURL");

      final url = Uri.parse("$baseURL/Home/GetClientdata/$customerId");
      Response response = await get(url);
      if(response != null)
      {
        if(response.statusCode == 200)
        {
          final responseBody = jsonDecode(response.body);

          if(responseBody['loginStatus'] == "1")
          {
            setState(() {
               resultText.text = responseBody['loginMesage'];
            });
          }
          else {
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Fetching client details failed.\nPlease try again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          }
        }
        else {
          showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("API error. Please check before trying again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        }
      }
      else{
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed. Please check before trying again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
            }
  }
}