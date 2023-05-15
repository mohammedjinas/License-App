import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:license/models/clientdet_search_model.dart';
import 'package:license/widgets/license_expiry_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/client_search_model.dart';
import '../models/license_expiry_list_model.dart';
import '../models/system_list_model.dart';
import '../widgets/system_list_widget.dart';

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
  late Future? systemNames;

  @override
  void initState() {    
    super.initState();
    systemNames = getSystemList();
  }


  @override
  Widget build(BuildContext context) {
    
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    width = w; height = h; 

    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover),),
      child: Scaffold(appBar: AppBar(title: const Text("RetailX License"),
      actions: [
          IconButton(onPressed: () async {
            ClientDetSearchModel selectedItem = await showSearch(context: context, delegate: MySearchDelegate());
            setState(() {
              customerId.text = selectedItem.customerId.toString();
              resultText.text = "";
            });
          }, icon: Icon(Icons.search))
        ],
      ),
      resizeToAvoidBottomInset: false,backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(children: [
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
                  },
                ),
              ),
      
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                height: height *0.27, width: width,
                child: TextField(controller: resultText,maxLines: null,
                readOnly: true,
                decoration: const InputDecoration(border: InputBorder.none,),style: TextStyle(fontSize: height * 0.015),
                ),
              ),
      
              const SizedBox(height: 2,),
            
            FutureBuilder(future: systemNames!,builder: ((context, snapshot) {
                Widget clientsList =  Container();
              if(snapshot.hasData)
              {
                if(snapshot.connectionState == ConnectionState.done)
                {
                  if(customerId.text != "") {
                    clientsList = LicenseExpiryList( snapshot.data);
                  }
                }
                else 
                {
                  clientsList = const CircularProgressIndicator();
                }
              }
              return clientsList;
              }),),
            ],
          ),
      ),
      ),
    );
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
              systemNames = getSystemList();
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

  
  getSystemList() async
  {
    List<LicenseExpiryListModel> systemList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL"),clientID = customerId.text;
    
    if(clientID != "") {
    final url = Uri.parse("$baseURL/Home/GetLicenseExpiry/$clientID");
    Response response = await get(url);
    if(response.statusCode == 200)
    {
      final systemListResponse = jsonDecode(response.body);

      if(systemListResponse["result"] == 1)
      {
        if(systemListResponse["licenseList"] != null) {
          final List<dynamic> responseList = systemListResponse["licenseList"];
        
          if(responseList.isNotEmpty)
          {
            for(int i = 0; i < responseList.length; i++)
            {
              LicenseExpiryListModel obj = LicenseExpiryListModel(id: responseList[i]["id"], SysName: responseList[i]["systemName"],ExpiryDate: responseList[i]["expiryDate"],Remarks: responseList[i]["remarks"],delFlag: responseList[i]["delFlag"]);
              systemList.add(obj);
            }
           
            // setState(() {
            //   flagHasLicense = true;
            // });
          }
        }
        else{
          // setState(() {
          // flagHasLicense = false;
          // });
          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text(systemListResponse["message"],style: const  TextStyle(color: Colors.black),),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[350],
        ));
        }
      }
      // else
      // {
      //   // ignore: use_build_context_synchronously
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content:  Text("No client exist with Client ID $clientID",style: const  TextStyle(color: Colors.black),),
      //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: Colors.grey[350],
      //   ));
      // }
    }
    else{
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed."),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    }
    return systemList;
  }
}

class MySearchDelegate extends SearchDelegate
{
  List<ClientDetSearchModel> customerList = [];  
  TextEditingController txtRemarks = TextEditingController();
  
  double width = 0.0, height = 0.0; 
  @override
  List<Widget> buildActions(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
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
<<<<<<< HEAD
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
=======
    // return FutureBuilder(future: searchCustomer(query,context),
    //   builder: ((context, snapshot) {
    //   if(snapshot.connectionState == ConnectionState.done)
    //   {
    //     if(snapshot.hasData)
    //     return buildList(snapshot.data);
    //     else return Container();
    //   }
    //   else
    //   {
    //     return Container();
    //   }
    // }));
>>>>>>> 3d350c2b8c18f4f8538ff9efcfe655ee826f4f90
  }

  Future<List<ClientDetSearchModel>?> searchCustomer(String searchText,BuildContext ctx) async
  {
    if(searchText == "")
    {
      return null;
    }
    // List<ClientDetSearchModel> customerList = []; 
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
            ClientDetSearchModel obj = ClientDetSearchModel(name: responseList[i]["name"], customerId: responseList[i]["customerId"], noOfLicense: responseList[i]["noOfLicense"],remarks: responseList[i]["remarks"]);
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

  Widget buildList(List<ClientDetSearchModel>? clientList)
  {
   if(clientList!.isNotEmpty) return ListView.builder(itemBuilder: ((context, index) {
      
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
      return InkWell(
        child: Container(
          height: height * 0.05,
          width: width * 0.5,
          // decoration: BoxDecoration(color: Colors.blue[50]),
          alignment: Alignment.center,
          child:  FittedBox(
            fit: BoxFit.fitWidth, 
            child: Row(
              children: [
                SizedBox(width: width * 0.7,
                  child: 
                  Text(clientList[index].name, 
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.015,),
                    ),
                ),
                  SizedBox(height: height * 0.05,width: width * 0.2 ,
                child: 
                Ink.image(image:const AssetImage("assets/images/remarks.png"),
              child: InkWell(onTap: () {
                showRemarksDialog(index,clientList[index].customerId,clientList[index].remarks,context);
              },),),
                // IconButton(onPressed: () {
                //   deleteClient(widget.systemsList[index].id);
                //   setState(() {widget.systemsList.removeAt(index);});
                // }, 
                // icon: const Icon(Icons.delete_forever,color: Colors.red,),),
                ),
              ],
            )
            ),
          ),
          onTap: () {
            ClientDetSearchModel selectedItem = ClientDetSearchModel(name: clientList[index].name, customerId: clientList[index].customerId, noOfLicense: clientList[index].noOfLicense,remarks: clientList[index].remarks);
            close(context, selectedItem);
          },
      );
    }),
    itemCount: clientList.length,);
    else
    {return Container();}
  }

  void showRemarksDialog(int index,String id,String remarks,BuildContext context)
  {
    txtRemarks.text = remarks;
    showDialog(barrierDismissible: true, context: context, builder: (context) {
      return SingleChildScrollView(
        child: Dialog(insetPadding: EdgeInsets.symmetric(vertical: height * 0.25, horizontal: width * 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(padding: const EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.only(bottom: 20), 
          child: Text("REMARKS", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: width * 0.05),
            ),),
      
          Container(padding: const EdgeInsets.only(bottom: 20), 
          child: TextField(decoration: InputDecoration(labelText: "Remarks",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),            
            controller: txtRemarks,
            minLines: 1,
            maxLines: 5,
          ),),

          Row(
            children: [ ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.28, 
                child: const Text("Cancel",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                          onPressed: () {Navigator.of(context).pop();},),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100],elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.28, 
                  child: const Text("Save",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                  onPressed: () {
                        saveRemarks(id);
                        customerList[index].remarks = txtRemarks.text;
                        Navigator.of(context).pop();
                    // }
                  },),
              ),
            ],
          ) 
      
        ],),),),
      );
     });
  }


  void saveRemarks(String id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    final remarks = txtRemarks.text;
    
    final url = Uri.parse("$baseURL/Home/UpdateClientRemarks/$remarks,$id");
    await get(url);

    // setState(() {});
  }
}