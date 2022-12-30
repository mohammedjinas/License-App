import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:license/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String baseURL = "http://hadabaoffice.dyndns.tv:99";
  late String username = "",password = "";
  bool isChecked = false, isLogged = false;
  @override
  Widget build(BuildContext context) 
  {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
      image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover)
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("RetailX License",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: height * 0.05),
                child: Row(
                  children: [const Text("Office Wifi",style: TextStyle(fontSize: 15),),
                    Checkbox(
                      value: isChecked,activeColor: Colors.black, onChanged: (bool? checkValue) { setState(() {
                      isChecked = checkValue!;
                      setUrl();
                    }); },
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: height * 0.15),
              child: const Text("SIGN IN",style: TextStyle(color: Colors.black,fontSize: 40,fontWeight: FontWeight.w700,fontStyle: FontStyle.italic),
              ),
            ),

            Container(height: height * 0.5,
            padding: EdgeInsets.only(top : height * 0.2),
              child: Card(
                elevation: 5,margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: Column(
                  children: [
                    Container(padding: const EdgeInsets.all(10),height: height * 0.1, child: 
                      TextField(decoration: InputDecoration(labelText: "Username",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
                      hintText: "Username",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                      onChanged: (value) => username = value,
                      ),
                    ),
                    
                    Container(padding: const EdgeInsets.all(10),height: height * 0.1,  child: 
                      TextField(obscureText: true, decoration: InputDecoration( labelText: "Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                      hintText: "Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                      onChanged: (value) => password = value,
                      ),
                    ),

                    SizedBox(width: width * 0.6, height: height * 0.05, 
                      child: 
                      ElevatedButton(
                        onPressed: () { const CircularProgressIndicator(); login();},style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        child: const Text("Log In",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  void setUrl()
  {
    if(isChecked)
    {
      baseURL = "http://192.168.1.127:1111";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("URL set to Office",style: TextStyle(color: Colors.black),),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[350],
    ));
    }
    else {
      baseURL = "http://hadabaoffice.dyndns.tv:99";
    }
  }

  void login() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(checkLoginDetails() == true)
    {
    final loginData = '$username,$password';
    final url = Uri.parse(baseURL + "/Home/LoginData/" + loginData);
    Response loginResponse = await get(url);
      if(loginResponse.body != null)
      {
       final body = jsonDecode(loginResponse.body);
       if(body['loginStatus'] == "1") 
       {
        int userFlag = body['userFlag'];
        prefs.setString("baseURL", baseURL);
        prefs.setString("username", username);
        prefs.setString("password", password);
        prefs.setBool("isLogged", true);
        prefs.setInt("userFlag", userFlag);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Logged In Successfully.",style: TextStyle(color: Colors.black),),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[350],
        ));

        Navigator.of(context).push(MaterialPageRoute(builder: (_) {return HomePage(userFlag: userFlag,);} ));
       }
       else
       {
        prefs.setBool("isLogged", false);

        showDialog(context: context,
        builder: (context) => AlertDialog(title: const Text("RetailX License"),
        content: Text(body['loginMesage']),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),);
       }
      }
      else 
      {
        prefs.setBool("isLogged", false);

        showDialog(context: context,
        builder: (context) => AlertDialog(title: const Text("RetailX License"),
        content: const Text("API Error!"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),);
      }
    }
  }

  bool checkLoginDetails()
  {
    bool retValue = false;
    if(username.isEmpty ||  username == "")
      {
        showDialog(context: context, builder: ((context) => AlertDialog(
          title: const Text("RetailX License"),
          content: const Text("Enter username"),
          actions: [TextButton(onPressed: () { Navigator.of(context).pop();},
          child: const Text("OK"))],
        )));
      }

      // else if(username.length < 5) 
      // {
      //   showDialog(context: context, builder: ((context) => AlertDialog(
      //     title: const Text("RetailX License"),
      //     content: const Text("Username too short"),
      //     actions: [TextButton(onPressed: () { Navigator.of(context).pop();},
      //     child: const Text("OK"))],
      //   )));
      // }

      else if(password.isEmpty || password == "") 
      {
        showDialog(context: context, builder: ((context) => AlertDialog(
          title: const Text("RetailX License"),
          content: const Text("Enter password"),
          actions: [TextButton(onPressed: () { Navigator.of(context).pop(); },
          child: const Text("OK"))],
        )));
      }
      else retValue = true;

      return retValue;
  }
}