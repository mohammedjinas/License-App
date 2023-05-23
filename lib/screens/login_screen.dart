import 'dart:convert';
import 'dart:io';

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

  String baseURL = "http://hadabaoffice.dyndns.tv:96";
  late String username = "",password = "";
  bool isChecked = false, isLogged = false, loginPressed = false;
  int userFlag = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
    getUserFlag();
    checkLoginStatus();
    });
  }
  @override
  Widget build(BuildContext context) 
  {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if(isLogged)
    {
      return HomePage(userFlag: userFlag);
    }
    return Container(
      decoration: const BoxDecoration(
      image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover)
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("RetailX License",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
        automaticallyImplyLeading: false,),
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
                        onPressed: () { 
                          setState(() {
                            loginPressed = true;
                            login();
                          });
                          
                          },style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        child: loginPressed ?  Row(crossAxisAlignment: CrossAxisAlignment.center,
                          children: [ 
                            const Text("Logging in..."),
                            CircularProgressIndicator(color: Colors.blue[150],),
                          ],
                        ) : const Text("Log In",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),)
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
      baseURL = "http://192.168.1.100:96";
      // baseURL = "http://192.168.1.127:1111";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("URL set to Office",style: TextStyle(color: Colors.black),),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[350],
    ));
    }
    else {
      baseURL = "http://hadabaoffice.dyndns.tv:96";
    }
  }

  void login() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

      if(checkLoginDetails() == true)      
      {
        final loginData = '$username,$password';
        final url = Uri.parse("$baseURL/Home/LoginData/$loginData");
        Response loginResponse = await get(url);
          if(loginResponse.statusCode == 200)
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

            setState(() {
              loginPressed = false;
            });

            Navigator.of(context).push(MaterialPageRoute(builder: (_) {return HomePage(userFlag: userFlag,);} ));
          }
          else
          {
            prefs.setBool("isLogged", false);

            showDialog(context: context,
            builder: (context) => AlertDialog(title: const Text("RetailX License"),
            content: Text(body['loginMesage']),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),);

            setState(() {
              loginPressed = false;
            });
          }
          }
          else 
          {
            prefs.setBool("isLogged", false);

            showDialog(context: context,
            builder: (context) => AlertDialog(title: const Text("RetailX License"),
            content: const Text("HTTP request Error!"),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),);

            setState(() {
              loginPressed = false;
            });
          }
      } 
    }
  }
    on SocketException catch(_)
    {
      showDialog(context: context,
            builder: (context) => AlertDialog(title: const Text("RetailX License"),
            content: const Text("Please check your internet connection before trying again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),);
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

  
void checkLoginStatus() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogged = prefs.getBool("isLogged")!;
    setState(() {});
  }

  void getUserFlag() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userFlag = prefs.getInt("userFlag")!;
  }

}