import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:license/models/system_list_model.dart';
import 'package:license/widgets/system_list_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientGeneration extends StatefulWidget {
  const ClientGeneration({super.key});

  @override
  State<ClientGeneration> createState() => _ClientGenerationState();
}

class _ClientGenerationState extends State<ClientGeneration> {
  double width = 0.0, height = 0.0;
  String? clientName = "";//noOfLicense;
  late Future? systemNames;
  TextEditingController noOfLicense = TextEditingController();
  TextEditingController clientId = TextEditingController();
  bool flagHasLicense = false;
  

  @override
  void initState() {    
    super.initState();
    systemNames = getSystemList();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title:const Text("RetailX License",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(padding:  EdgeInsets.only(top: height * 0.05),
      height: height,
        decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/login_bg.jpg"),
          fit: BoxFit.cover
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if(clientName!.isNotEmpty && clientName != "" )
            Container(alignment: Alignment.center,  width: width * 0.9, padding: const EdgeInsets.only(bottom: 10),
              child: Text(clientName!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: width * 0.05),),),
              
          Row(
            children: [
              Container(width: width * 0.88, padding: const EdgeInsets.only(left: 10, right: 5, bottom: 5), child: TextField(decoration: InputDecoration(labelText: "Customer ID",labelStyle: const TextStyle(color: Colors.black87), focusColor: Colors.blue, 
                hintText: "Customer ID",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),counterText: ""),keyboardType: TextInputType.number,
                controller: clientId,maxLength: 5,
                ),),
              
                SizedBox(height: width * 0.1, width: width * 0.1,
                  child: IconButton(
                    onPressed: () {
                      if(clientId.text.isNotEmpty && clientId.text != "")
                      {
                        if(int.parse(clientId.text) < 0)
                        {
                          showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Invalid Client ID"),
                          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
                          return;
                        }
                        else{
                          setState(() {
                            systemNames = getSystemList();                        
                          });
                        }
                      }
                      else{
                        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Invalid Client ID"),
                          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
                          return;
                      }
                    },
                    icon: const Icon(Icons.search_rounded),),
                )
            ],
          ),
          
          Container(padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10), child: TextField(decoration: InputDecoration(labelText: "No of license(s)",labelStyle: const TextStyle(color: Colors.black87), focusColor: Colors.blue, 
            hintText: "No of license(s)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),counterText: ""),keyboardType: TextInputType.number,
            controller: noOfLicense, maxLength: 3,
            ),),
          
          flagHasLicense ? 
          ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100],elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.28, 
            child: const Text("Update",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
            onPressed: () {
              if(validateFields())
              {
                updateClient();
              }
              // setState(() {
              //   clientId.text = "";
              //   noOfLicense.text = "";
              // });
            },
          ) 
          :
          ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100],elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.28, 
            child: const Text("Generate",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
            onPressed: () {
              if(validateFields())
              {
                insertClient();
              }
              // setState(() {
              //   clientId.text = "";
              //   noOfLicense.text = "";
              // });
            },
          ),
              
          const SizedBox(height: 2,),
          
          FutureBuilder(future: systemNames!,builder: ((context, snapshot) {
              Widget clientsList =  Container();
            if(snapshot.hasData)
            {
              if(snapshot.connectionState == ConnectionState.done)
              {
                if(clientId.text != "") {
                  clientsList = SystemList( snapshot.data, int.parse(clientId.text));
                }
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

  bool validateFields()
  {
    if(clientId.text  == "" || int.parse(clientId.text) < 0 || clientId.text.isEmpty)
    {
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Invalid Client ID"),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      return false;
    }

    if(noOfLicense.text == "" || int.parse(noOfLicense.text) < 0 || noOfLicense.text.isEmpty)
    {
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Invalid no of license(s)"),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      return false;
    }

    return true;
  }

  getSystemList() async
  {
    List<SystemListModel> systemList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL"),clientID = clientId.text;
    
    if(clientID != "") {
    final url = Uri.parse("$baseURL/Home/GetSystemList/Generation,$clientID");
    Response response = await get(url);
    if(response.statusCode == 200)
    {
      final systemListResponse = jsonDecode(response.body);
      if(systemListResponse["result"] == 1)
      {
        clientName = systemListResponse["clientName"];
        noOfLicense.text = systemListResponse["noOfLicense"].toString() ;
        if(systemListResponse["systemNames"] != null) {
          final List<dynamic> responseList = systemListResponse["systemNames"];
        
          if(responseList.isNotEmpty)
          {
            for(int i = 0; i < responseList.length; i++)
            {
              SystemListModel obj = SystemListModel(sysName: responseList[i]["systemName"],id: responseList[i]["id"]);
              systemList.add(obj);
            }
           
            setState(() {
              flagHasLicense = true;
            });
          }
        }
        else{
          setState(() {
          flagHasLicense = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text(systemListResponse["message"],style: const  TextStyle(color: Colors.black),),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[350],
        ));
        }
      }
      else
      {
        setState(() {
          clientName = "";
          flagHasLicense = false;
          // noOfLicense.text = "";
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text("No client exist with Client ID $clientID",style: const  TextStyle(color: Colors.black),),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[350],
        ));
      }
    }
    else{
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed."),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    }
    return systemList;
  }

  void insertClient() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    String licenseNo = noOfLicense.text, clientID = clientId.text;
    final url = Uri.parse("$baseURL/Home/InsertClient/$clientID,$licenseNo");
    Response response = await get(url);
    final retString = response.body.toString();

    
    // String retString = resultObj["message"].toString();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:   Text(retString,style:  const TextStyle(color: Colors.black),),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[350],
    ));

    setState(() {
      clientId.text = "";
      noOfLicense.text = "";
    });
  }

  void updateClient() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    String licenseNo = noOfLicense.text, clientID = clientId.text;
    final url = Uri.parse("$baseURL/Home/UpdateClient/$clientID,$licenseNo");
    await get(url);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:  const Text("Client updated successfully",style:  TextStyle(color: Colors.black),),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[350],
    ));

    setState(() {
      clientId.text = "";
      noOfLicense.text = "";
    });
  }
}