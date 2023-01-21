import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/client_search_model.dart';

class ClientDetials extends StatefulWidget {
  const ClientDetials({super.key});

  @override
  State<ClientDetials> createState() => _ClientDetialsState();
}

class _ClientDetialsState extends State<ClientDetials> {
  // String? customerId = "";
  TextEditingController customerId = TextEditingController();

  double width = 0.0, height = 0.0; 

  TextEditingController resultText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    width = w; height = h; 

    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover),),
      child: Scaffold(appBar: AppBar(title: const Text("RetailX License"),
      actions: [
          IconButton(onPressed: () async {
            ClientSearchModel selectedItem = await showSearch(context: context, delegate: MySearchDelegate());
            setState(() {
              // clientName = selectedItem.name.toUpperCase();
              customerId.text = selectedItem.customerId.toString();
              // noOfLicense.text = selectedItem.noOfLicense.toLowerCase();
            });
          }, icon: Icon(Icons.search))
        ],
      ),
      resizeToAvoidBottomInset: false,backgroundColor: Colors.transparent,
      body: Column(children: [
                Container(padding: const EdgeInsets.all(10),width: width * 0.9,height: height * 0.09, child: 
                  TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Customer ID",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue,
                  hintText: "Customer ID",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  controller: customerId,
                  ),
                ),
                
                Container(padding: const EdgeInsets.only(top: 10,),
                child: ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, child: const Text("Get Client Details",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
              onPressed: () {
                  if(customerId.text == "" || customerId.text.isEmpty)
                  {
                    showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Enter a client's customer ID to getch details."),
                    actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
                  }
                  else {
                  getClientDetails();
                  }
                },),),


                Container(padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),height: height *0.5,width: width,
                child: TextField(controller: resultText,readOnly: true,decoration: const InputDecoration(border: InputBorder.none,),style: TextStyle(fontSize: height * 0.015),),),
      ],),),);
  }

  void getClientDetails() async
  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? baseURL = prefs.getString("baseURL"), customerID = customerId.text;

      final url = Uri.parse("$baseURL/Home/GetClientdata/$customerID");
      Response response = await get(url);
      if(response != null)
      {
        if(response.statusCode == 200)
        {
          final responseBody = jsonDecode(response.body);

          if(responseBody['loginStatus'] == "1")
          {
            setState(() {
               resultText.text = responseBody['loginMesage'];
            });
          }
          else {
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Fetching client details failed.\nPlease try again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
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
  }
}

class MySearchDelegate extends SearchDelegate
{
  List<ClientSearchModel> customerList = [];  
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(onPressed: () {
      if(query.isEmpty)
      {
        close(context, null);
      }
      else
      {
        query = "";
      }
    }, icon: Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(onPressed: (){
      close(context, null);
    }, icon: Icon(Icons.arrow_back));
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    
        return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(future: searchCustomer(query,context),
      builder: ((context, snapshot) {
      if(snapshot.connectionState == ConnectionState.done)
      {
        if(snapshot.hasData)
        return buildList(snapshot.data);
        else return Container();
      }
      else
      {
        return Container();
      }
    }));
  }

  Future<List<ClientSearchModel>?> searchCustomer(String searchText,BuildContext ctx) async
  {
    if(searchText == "")
    {
      return null;
    }
    List<ClientSearchModel> customerList = []; 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    final url = Uri.parse("$baseURL/Home/SearchCustomer/$searchText");
    Response response = await get(url);

    if(response.statusCode == 200)
    {
      final searchResult = jsonDecode(response.body);
      if(searchResult["result"] == 1)
      {
        if(searchResult["clientList"] != null)
        {
          final List<dynamic> responseList = searchResult["clientList"];
          for(int i = 0; i < responseList.length; i++)
          {
            ClientSearchModel obj = ClientSearchModel(name: responseList[i]["name"], customerId: responseList[i]["customerId"], noOfLicense: responseList[i]["noOfLicense"]);
            customerList.add(obj);
          }
        }
        else
        {
          showDialog(context: ctx, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content:  Text("No customer found"),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        }
      }
      else
      {
        showDialog(context: ctx, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content:  Text(searchResult["message"]),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
    }
    else{
        showDialog(context: ctx, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed."),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }

    return customerList;
  }

  Widget buildList(List<ClientSearchModel>? clientList)
  {
   if(clientList!.isNotEmpty) return ListView.builder(itemBuilder: ((context, index) {
      
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
      return InkWell(
        child: Container(
          height: height * 0.05,
          width: width * 0.9,
          decoration: BoxDecoration(color: Colors.blue[50]),
          alignment: Alignment.center,
          child:  FittedBox(
            fit: BoxFit.fitWidth, 
            child: Text(clientList[index].name, 
            style: TextStyle(
              color: Colors.black, 
              fontSize: height * 0.015),
              )
            ),
          ),
          onTap: () {
            ClientSearchModel selectedItem = ClientSearchModel(name: clientList[index].name, customerId: clientList[index].customerId, noOfLicense: clientList[index].noOfLicense);
            close(context, selectedItem);
          },
      );
    }),
    itemCount: clientList.length,);
    else
    {return Container();}
  }

}