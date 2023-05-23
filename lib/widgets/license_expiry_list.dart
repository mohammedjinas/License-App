import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/license_expiry_list_model.dart';
import 'package:http/http.dart' as http;

class LicenseExpiryList extends StatefulWidget {
  const LicenseExpiryList(this.systemsList,{super.key});
  
  final List<LicenseExpiryListModel> systemsList;
  // final int clientId;

  @override
  State<LicenseExpiryList> createState() => _LicenseExpiryListState();
}
 

class _LicenseExpiryListState extends State<LicenseExpiryList> {
 
  bool isVisible = true;
  double width = 0, height = 0;
  TextEditingController txtRemarks = new TextEditingController();
  TextEditingController txtReason = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if(widget.systemsList.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Row(
          children: [
              SizedBox(width: width * 0.02),
              Container(height: height * 0.05,width: width * 0.35,decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
                    child: const Text("System Name",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),

              Container(height: height * 0.05,width: width * 0.35,decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
                    child: const Text("Expiry",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),

              Container(height: height * 0.05,width: width * 0.12,decoration: BoxDecoration(color: Colors.blue[100]),
                    child: const Text("",),),
              Container(height: height * 0.05,width: width * 0.12,decoration: BoxDecoration(color: Colors.blue[100]),
                    child: const Text("",),),
          ],
        ),

        ListView.builder(itemBuilder: (context, index) {
          return Row(
            children: [
              
              SizedBox(width: width * 0.02),
              Container(height: height * 0.05,width: width * 0.35,decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
                child:  FittedBox(fit: BoxFit.fitWidth, child: Text(widget.systemsList[index].SysName, style: TextStyle(color: Colors.black, fontSize: height * 0.015),)),),
                
              Container(height: height * 0.05,width: width * 0.35,decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
                child:  FittedBox(fit: BoxFit.fitWidth, child: Text(widget.systemsList[index].ExpiryDate, style: TextStyle(color: Colors.black, fontSize: height * 0.015),)),),
                
              SizedBox(height: height * 0.05,width: width * 0.1,
                child: 
                Ink.image(image:const AssetImage("assets/images/remarks.png"),
              child: InkWell(onTap: () {
                showRemarksDialog(index,widget.systemsList[index].id,widget.systemsList[index].Remarks);
              },
              ),
              ),
              ),

              SizedBox(
                height: height * 0.05,
                // width: width * 0.5,
                child: IconButton(
                  icon: Icon(Icons.delete_forever,),
                  onPressed:() {
                    if(widget.systemsList[index].delFlag == "False")
                      showDeleteDialog(index, widget.systemsList[index].id);
                  },
                  color: widget.systemsList[index].delFlag == "False"? Colors.red : Colors.grey,
                  iconSize: width * 0.05,
                  )
              //   Ink.image(image:const AssetImage("assets/images/remarks.png"),
              // child: InkWell(onTap: () {
              //   showRemarksDialog(index,widget.systemsList[index].id,widget.systemsList[index].Remarks);
              // },
              // ),
              // ),
              ),
            ],
          );
          },
          itemCount: widget.systemsList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          ),
      ],
    );
    }
    else 
    {
      return Container(
      );
    }
  }
  
  void showRemarksDialog(int index,String id,String remarks)
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
            children: [ ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.26, 
                child: const Text("Cancel",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                          onPressed: () {Navigator.of(context).pop();},),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100],elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.26, 
                  child: const Text("Save",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                  onPressed: () {
                        saveRemarks(id);
                        widget.systemsList[index].Remarks = txtRemarks.text;
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

  
  void showDeleteDialog(int index,String id)
  {
    showDialog(barrierDismissible: true, context: context, builder: (context) {
      return SingleChildScrollView(
        child: Dialog(insetPadding: EdgeInsets.symmetric(vertical: height * 0.25, horizontal: width * 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(padding: const EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.only(bottom: 20), 
          child: Text("REASON", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: width * 0.05),
            ),),
      
          Container(padding: const EdgeInsets.only(bottom: 20), 
          child: TextField(decoration: InputDecoration(labelText: "Reason",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),            
            controller: txtReason,
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
                  child: const Text("Request",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                  onPressed: () {
                        delRequest(id);
                        // widget.systemsList[index].Remarks = txtRemarks.text;
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
    
    final url = Uri.parse("$baseURL/Home/UpdateRemarks/$remarks,$id");
    await get(url);

    setState(() {});
  }

  void delRequest(String id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String? baseURL = prefs.getString("baseURL"), username = prefs.getString("username");
    final reason = txtReason.text;
    Map<String,String> mapPostData = {
      'UserName': username!, 'ID': id, 'RequestedDate' : "",'RequestedReason' : reason,'Systemorcompany' : "System"
    };

    var jsonPostdata = jsonEncode(mapPostData);
      final url = Uri.parse("$baseURL/Home/DeleteReq");
      http.Response response = await http.post(url,headers: {"Content-Type": "application/json"},body: jsonPostdata);
      if(response.statusCode == 200)
      {
        if(response.body.isNotEmpty)
        {
          var jsonData = jsonDecode(response.body);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text(jsonData["loginMesage"],style: const  TextStyle(color: Colors.black),),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[350],
          ));
        }
      }
  }
}