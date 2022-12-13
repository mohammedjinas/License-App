

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:license/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportLicense extends StatefulWidget {
  const ReportLicense({super.key});

  @override
  State<ReportLicense> createState() => _ReportLicenseState();
}

class _ReportLicenseState extends State<ReportLicense> {
  String? cust_name = "", cust_url = ""; 
  TextEditingController date = TextEditingController(); 
  DateTime? pickedDate = DateTime.now();
   @override
  void initState() {
    date.text = DateFormat("dd-MM-yyyy").format(DateTime.now()); 
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),),),
          child: Scaffold(backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("RetailX License"),),
          body:  Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(10), child: 
                TextField(decoration: InputDecoration(labelText: "Customer name",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
                hintText: "Customer name",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                onChanged: (value) => cust_name = value,
                ),
              ),
          
            Container(padding: const EdgeInsets.all(10), child: 
              TextField(decoration: InputDecoration( labelText: "URL",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
              hintText: "URL",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
              onChanged: (value) => cust_url = value,
              ),
            ),

            Container(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
              controller: date, 
              decoration: const InputDecoration( 
                  icon: Icon(Icons.calendar_today),),
              readOnly: true,  
              onTap: () async {
                    pickedDate = await showDatePicker(
                    context: context, initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101)
                );
                
                if(pickedDate != null ){
                    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate!); 
                    setState(() {
                        date.text = formattedDate;  
                    });
                  }
                },
          ),
            ),

          const SizedBox(height: 20,),

          Container(width: width * 0.6,
            child: ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
            child: const Text("Submit",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {setLicense();},),
          ),
      ],)),
    );
  }

  void setLicense() async
  {
    if(cust_name == "" || cust_name!.isEmpty)
    {
       showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Enter customer name"),
        actions: [TextButton(onPressed: () 
        {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    else if(cust_name!.length < 5)
    {
       showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Customer name too short"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop(); }, child: const Text("OK"))],)));
    }
    else if(cust_url == "" || cust_url!.isEmpty)
    {
       showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Enter customer URL."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    else if(cust_url!.length < 5)
    {
       showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Customer URL too short."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    else if(pickedDate!.isBefore(DateTime.now()))
    {
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Cannot choose a date older than today"),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop(); return;}, child: const Text("OK"))],)));
    }
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? baseURL = prefs.getString("baseURL");

      Map<String,dynamic> map = {
        'cust_name':cust_name,'cust_url':cust_url,'date':date.text
      };

      var postData = jsonEncode(map);

      final url = Uri.parse("$baseURL/Home/SetReportLicense");
      http.Response response = await http.post(url,headers: {"Content-Type": "application/json"},body: postData);
      if(response != null)
      {
        if(response.statusCode == 200)
        {
          final body = jsonDecode(response.body);
          if(body["result"] == 1)
          {
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License set successfully."),
            actions: [TextButton(onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: ((context) => HomePage())));}, child: const Text("OK"))],)));
          }
          else {
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License setting failed. Please try again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          }
        }
        else{
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("API request not reachable. Please try again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));}
      }
      else{
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed. Please check before trying again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));}
    }


  }

}