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
  
  String? old_pass = "", new_pass,retype_pass; 
  @override
  Widget build(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
    return Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),),),
              child: Scaffold(backgroundColor: Colors.transparent,
              appBar: AppBar(title: const Text("RetailX License"),),
              body:  Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: EdgeInsets.all(10), child: 
                  TextField(decoration: InputDecoration(labelText: "Old Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
                  hintText: "Old Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => old_pass = value,
                  ),
                ),
                
                Container(padding: EdgeInsets.all(10), child: 
                  TextField(decoration: InputDecoration( labelText: "New Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                  hintText: "New Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => new_pass = value,
                  ),
                ),

                Container(padding: EdgeInsets.all(10), child: 
                  TextField(decoration: InputDecoration( labelText: "Re-type Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                  hintText: "Re-type Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  onChanged: (value) => retype_pass = value,
                  ),
                ),

                Container(width: width * 0.6,
                  child: 
                  ElevatedButton(
                    child: Text("Submit",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
                    onPressed: () {changepass();},style: ElevatedButton.styleFrom(backgroundColor: Colors.white)
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

      if(userPass != old_pass)
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Existing password you entered is wrong."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
      else if(userPass == new_pass)
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Cannot change password to existing password"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
      else if(new_pass != retype_pass)
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Password mismatch."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
      else {
       final change_pass_params = "$username,$new_pass";
       final url = Uri.parse("$baseURL/Home/PasswordChange/$change_pass_params");
       Response changepassResponse = await get(url);
       if(changepassResponse != null)
       {
          if(changepassResponse.statusCode == 200)
          {
            final response = jsonDecode(changepassResponse.body);

            if(response['loginStatus'] == "1")
            {
              prefs.setString("password",new_pass!);
              showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Password changed successfully."),
              actions: [TextButton(onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: ((context) => HomePage())));}, child: const Text("OK"))],)));
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