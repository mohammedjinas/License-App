import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:license/screens/changepass_screen.dart';
import 'package:license/screens/client_details.dart';
import 'package:license/screens/client_generation_screen.dart';
import 'package:license/screens/mylicense_screen.dart';
import 'package:license/screens/report_license_screen.dart';
import 'package:license/screens/scan_screen.dart';
import 'package:license/widgets/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key,required this.userFlag});

  final int userFlag;
  @override
  Widget build(BuildContext context)
  {
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async
      {
        final value = await showDialog<bool>(
          context: context, 
          builder: (context) => AlertDialog(
            title: const Text("RetailX License"),
            content: const Text("Do you want to exit?"),
            actions: [
              TextButton(
                onPressed: () 
                {
                  Navigator.of(context).pop(false);
                }, 
                child: const Text("No")
              ),

              TextButton(
                onPressed: () 
                {
                  SystemNavigator.pop();
                }, 
                child: const Text("Exit")
              )
            ],
          )
        );
        
        if (value != null) 
        {
          return Future.value(value);
        }
        else {
          return Future.value(false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_bg.jpg"),
            fit: BoxFit.cover),),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("RetailX License"),
            leading: AlertDialog(
              title: const Text("RetailX License"),
              content: const Text("Do you want to exit?"),
              actions: [
                TextButton(
                  onPressed: () {Navigator.of(context).pop(false);}, 
                  child: const Text("No")
                ),
                TextButton(
                  onPressed: () { SystemNavigator.pop();}, 
                  child: const Text("Exit")
                )
              ],
            ),
          ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ButtonWidget(
                  buttonText: "QR Code Scan", 
                  returnWidget: const ScanScreen()
                ),
                
                ButtonWidget(
                  buttonText: "Client Details", 
                  returnWidget: const ClientDetials()
                ),
                
                ButtonWidget(
                  buttonText: "My License", 
                  returnWidget: const MyLicense(callingFrom: "Clients",)
                ),
                
                if(userFlag == 1 || userFlag == 3)
                ButtonWidget(
                  buttonText: "My Clients", 
                  returnWidget: const MyLicense(callingFrom: "SalesMan")
                ),
                
                ButtonWidget(
                  buttonText: "RetailX Reports License", 
                  returnWidget: const ReportLicense()
                ),
                
                ButtonWidget(
                  buttonText: "Change Password", 
                  returnWidget: const ChangePassword()
                ),

                if(userFlag == 1)
                ButtonWidget(
                  buttonText: "Client Geneartion", 
                  returnWidget: const ClientGeneration()
                ),
          
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white), 
                  child: Container(
                    alignment: Alignment.center,
                    width: width *0.6, 
                    child: Text(
                      "Exit",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500, 
                        fontSize: width * 0.04)
                      ,)
                    ),
                  onPressed: () {
                    showDialog<bool>(
                      context: context, 
                      builder: (context) => AlertDialog(
                        title: const Text("RetailX License"),
                        content: const Text("Do you want to logout and exit?"),
                        actions: [
                          TextButton(
                            onPressed: () 
                            {
                              Navigator.of(context).pop(false);
                            }, 
                            child: const Text("No")
                          ),
                          TextButton(
                            onPressed: () 
                            {
                              logOut(); SystemNavigator.pop();
                            }, 
                            child: const Text("Exit")
                          )
                        ],
                      )
                    );
                  }
                  ),
          
                ],
              ),
            )
          ),
      ),
    ),
  );    
  }

  void logOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogged",false);
  }
}
