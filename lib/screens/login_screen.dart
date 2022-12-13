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
  bool isChecked = false;
  @override
  Widget build(BuildContext context) 
  {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
      image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover)
      ),
      child: Scaffold(
        appBar: AppBar(title: Text("RetailX License",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: height * 0.05),
                child: Row(
                  children: [Text("Office Wifi",style: TextStyle(fontSize: 15),),
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
              child: Text("SIGN IN",style: TextStyle(color: Colors.black,fontSize: 40,fontWeight: FontWeight.w700,fontStyle: FontStyle.italic),
              ),
            ),
//Container(height: height * 0.7,padding:EdgeInsets.only(top: height* 0.9) , decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/logo.png"))),),
            Container(height: height * 0.5,//decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/logo.png"))),
            padding: EdgeInsets.only(top : height * 0.2),
              child: Card(
                elevation: 5,margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: Column(
                  children: [
                    Container(padding: EdgeInsets.all(10), child: 
                      TextField(decoration: InputDecoration(labelText: "Username",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
                      hintText: "Username",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                      onChanged: (value) => username = value,
                      ),
                    ),
                    
                    Container(padding: EdgeInsets.all(10), child: 
                      TextField(obscureText: true, decoration: InputDecoration( labelText: "Password",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                      hintText: "Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                      onChanged: (value) => password = value,
                      ),
                    ),

                    Container(width: width * 0.6,
                      child: 
                      ElevatedButton(
                        child: Text("Log In",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
                        onPressed: () => login(),style: ElevatedButton.styleFrom(backgroundColor: Colors.white)
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
      content: Text("URL set to Office",style: TextStyle(color: Colors.black),),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
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
        prefs.setString("baseURL", baseURL);
        prefs.setString("username", username);
        prefs.setString("password", password);
        prefs.setBool("isLogged", true);

        Navigator.of(context).push(MaterialPageRoute(builder: (_) {return HomePage();} ));
       }
       else
       {
        prefs.setBool("isLogged", true);

        showDialog(context: context,
        builder: (context) => AlertDialog(title: Text("RetailX License"),
        content: Text(body['loginMesage']),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text("OK"))],),);
       }
      }
      else 
      {
        prefs.setBool("isLogged", true);

        showDialog(context: context,
        builder: (context) => AlertDialog(title: Text("RetailX License"),
        content: Text("API Error!"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text("OK"))],),);
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

      else if(username.length < 5) 
      {
        showDialog(context: context, builder: ((context) => AlertDialog(
          title: const Text("RetailX License"),
          content: const Text("Username too short"),
          actions: [TextButton(onPressed: () { Navigator.of(context).pop();},
          child: Text("OK"))],
        )));
      }

      else if(password.isEmpty || password == "") 
      {
        showDialog(context: context, builder: ((context) => AlertDialog(
          title: const Text("RetailX License"),
          content: const Text("Enter password"),
          actions: [TextButton(onPressed: () { Navigator.of(context).pop(); },
          child: Text("OK"))],
        )));
      }
      else retValue = true;

      return retValue;
  }
}