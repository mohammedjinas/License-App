import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:license/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  
  String? oldPass = "", newPass,retypePass; 
  @override
  Widget build(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover),),
              child: Scaffold(backgroundColor: Colors.transparent,
              appBar: AppBar(title: const Text("RetailX License"),),
              body:  Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding:const EdgeInsets.all(10),height: height * 0.09, child: 
                  TextField(decoration: InputDecoration(labelText: "Old Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
                  hintText: "Old Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => oldPass = value,
                  ),
                ),
                
                Container(padding:const EdgeInsets.all(10),height: height * 0.09, child: 
                  TextField(decoration: InputDecoration( labelText: "New Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                  hintText: "New Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => newPass = value,
                  ),
                ),

                Container(padding:const EdgeInsets.all(10),height: height * 0.09, child: 
                  TextField(decoration: InputDecoration( labelText: "Re-type Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                  hintText: "Re-type Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => retypePass = value,
                  ),
                ),

                SizedBox(width: width * 0.6,height: height * 0.05,
                  child: 
                  ElevatedButton(
                    onPressed: () {changepass();},style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text("Submit",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),)
                  ),
                ),
      ],),
              )),
    );
  }

  void changepass() async
  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? baseURL = prefs.getString("baseURL");
      String? userPass = prefs.getString("password");
      String? username = prefs.getString("username");
      int? userFlag = prefs.getInt("userFlag");

      if(userPass != oldPass)
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Existing password you entered is wrong."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
      else if(userPass == newPass)
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Cannot change password to existing password"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
      else if(newPass != retypePass)
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Password mismatch."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
      else {
       final changePassParams = "$username,$newPass";
       final url = Uri.parse("$baseURL/Home/PasswordChange/$changePassParams");
       Response changepassResponse = await get(url);
       if(changepassResponse != null)
       {
          if(changepassResponse.statusCode == 200)
          {
            final response = jsonDecode(changepassResponse.body);

            if(response['loginStatus'] == "1")
            {
              prefs.setString("password",newPass!);
              showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Password changed successfully."),
              actions: [TextButton(onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: ((context) => HomePage(userFlag: userFlag!,))));}, child: const Text("OK"))],)));
            }else {
                showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Password change failed. Please try again."),
                actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
              }
          }
          else 
          {
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("API Error"),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          }
        }
        else{
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed. Please check before trying again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        }
    
      }
  }
}