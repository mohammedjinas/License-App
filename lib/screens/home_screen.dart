import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:license/screens/changepass_screen.dart';
import 'package:license/screens/client_details.dart';
import 'package:license/screens/login_screen.dart';
import 'package:license/screens/report_license_screen.dart';
import 'package:license/screens/scan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover),),
  //   );
  // }

  @override
  Widget build(BuildContext context)
  {
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;
      return WillPopScope(onWillPop: () async
      {
        
        final value = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
          title: Text("RetailX License"),
          content: Text("Do you want to exit?"),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop(false);}, child: Text("No")),
          TextButton(onPressed: () {SystemNavigator.pop();}, child: Text("Exit"))],));
          if (value != null) 
          {
            return Future.value(value);
          }
          else return Future.value(false);
      },child: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),),),
      child: Scaffold(appBar: AppBar(title: Text("RetailX License")),resizeToAvoidBottomInset: false,backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
              child: Text("QR Code Scan",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) { return ScanScreen();}));},),
        
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
              child: Text("Client Details",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) { return ClientDetials();}));},),
        
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
              child: Text("My License",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) { return ChangePassword();}));},),
              
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
              child: Text("My Clients",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) { return ChangePassword();}));},),
        
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white), child: Container(alignment: Alignment.center, width: width *0.6, 
              child: Text("RetailX Reports License",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) { return ReportLicense();}));},),
        
              ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
              child: Text("Change Password",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) { return ChangePassword();}));},),
        
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white), child: Container(alignment: Alignment.center,width: width *0.6, 
              child: Text("Exit",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {SystemNavigator.pop();},),
        
            ],
          ),
        )
      ),),
      )
      );

      
  }
}
