import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:license/models/license_list_model.dart';
import 'package:license/widgets/clients_list_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLicense extends StatefulWidget {

  final String? callingFrom;

  const MyLicense({super.key,required this.callingFrom});

  @override
  State<MyLicense> createState() => _MyLicenseState();
}

class _MyLicenseState extends State<MyLicense> {  

  double width = 0.0, height = 0.0;

  late Future licenseModel;
  String searchText = '-';
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    licenseModel = getLicenses(searchText);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    width = w; height = h; 

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(appBar: AppBar(
        actions: [
          Center(
            child: const Text("Expired",style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold
              ),
            ),
          ),
          Checkbox(value: isChecked, onChanged: (value) {
            setState(() {
              isChecked = value!;
              licenseModel = getLicenses(searchText);
            });
          },
          activeColor: Colors.white,
          checkColor: Colors.black,)
        ],
        title: const Text("RetailX License"),),
        body: SingleChildScrollView(
          child: Column(children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,left: 10),
                child: SizedBox(height: height *0.05, width: width * 0.8, //padding: const EdgeInsets.only(left: 10, right: 10,bottom: 10), 
                child: TextField(decoration: InputDecoration(hintText: "Search...",border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                style: TextStyle(fontSize: height * 0.015,), onChanged: (value) {
                  searchText = value;
                },)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10,left : 10),
                child: InkWell(child: const Icon(Icons.search_rounded,color: Colors.blueAccent),
                onTap: () {
                  if(searchText != "-" && searchText != "") {
                    setState(() {
                      licenseModel = getLicenses(searchText);
                    });
                  }
                },),
              )
        
            ],),
    
            const SizedBox(height: 10,),
    
            Row(
              children: [
                Container(height: height * 0.05,width: width * 0.1,decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
                child: const Text("ID",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),
                
                Container(height: height * 0.05,width: width * 0.005, decoration: const BoxDecoration(color: Colors.grey)),
    
                Container(height: height * 0.05,width: width * 0.48, decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
                child: const Text("Name",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),
                
                Container(height: height * 0.05,width: width * 0.005, decoration: const BoxDecoration(color: Colors.grey)),
    
                Container(height: height * 0.05,width: width * 0.2,decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
                child: const Text("Sys. Name",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),
                
                Container(height: height * 0.05,width: width * 0.005, decoration: const BoxDecoration(color: Colors.grey)),
                
                Container(height: height * 0.05,width: width * 0.2,decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
                child: const Text("Expiry",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),
              ],
            ),
            const SizedBox(height: 2,),
    
            FutureBuilder(future: licenseModel,builder: ((context, snapshot) {
              Widget clientsList =  Padding(padding: EdgeInsets.only(top: height * 0.4), child: const CircularProgressIndicator());
            if(snapshot.hasData)
            {
              if(snapshot.connectionState == ConnectionState.done)
              {
                clientsList = ClientsList(snapshot.data);
              }
              else 
              {
                clientsList = const CircularProgressIndicator();
              }
            }
            return clientsList;
            }),),
          ],),
        ),
      ),
    );
  }

  getLicenses(String searchText) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    String? username = prefs.getString("username");
    int? userFlag = prefs.getInt("userFlag");
    String isExpired = "";
    isChecked ? isExpired = "1" : isExpired = "0";
    

    String callingFrom = widget.callingFrom!;
    if(userFlag == 1)
    {
      callingFrom = "Admin";
    }
    List<LicenseListModel> clientsList = [];
    final url = Uri.parse("$baseURL/Home/GetClients/$callingFrom/$username/$isExpired/$searchText");
    Response response = await get(url);
    if(response != null)
      {
        if(response.statusCode == 200)
        {
          final List<dynamic> responseList = jsonDecode(response.body);
          
          // licenseList = responseList.cast<LicenseListModel>();
          for(int i = 0; i < responseList.length; i++)
          {
            LicenseListModel clientObj = LicenseListModel(
              id: responseList[i]["id"] ?? "", 
              clientName: responseList[i]["clientname"] ?? "", 
              systemName: responseList[i]["systemname"] ?? "", 
              expiryDate: responseList[i]["expiryDate"] ?? ""
              );
            clientsList.add(clientObj);
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
    return clientsList;
  }
}