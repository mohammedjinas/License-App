import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:license/models/system_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemList extends StatefulWidget {
  const SystemList(this.systemsList,this.clientId,{super.key});
  
  final List<SystemListModel> systemsList;
  final int clientId;

  @override
  State<SystemList> createState() => _SystemListState();
}
 

class _SystemListState extends State<SystemList> {
 
  bool isVisible = true;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if(widget.systemsList.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Container(height: height * 0.05,width: width * 0.8,decoration: BoxDecoration(color: Colors.blue[100]),alignment: Alignment.center,
              child: const Text("System Name",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),

        ListView.builder(itemBuilder: (context, index) {
          return Row(
            children: [
              
              SizedBox(width: width * 0.1),
              Container(height: height * 0.05,width: width * 0.65,decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
                child:  FittedBox(fit: BoxFit.fitWidth, child: Text(widget.systemsList[index].sysName, style: TextStyle(color: Colors.black, fontSize: height * 0.015),)),),
                
              SizedBox(height: height * 0.05,width: width * 0.15,
                child: IconButton(onPressed: () {
                  deleteClient(widget.systemsList[index].id);
                  setState(() {widget.systemsList.removeAt(index);});
                }, 
                icon: const Icon(Icons.delete_forever,color: Colors.red,),),
                ),
            ],
          );
          },
          itemCount: widget.systemsList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),),
      ],
    );
    }
    else 
    {
      return Container(
      );
    }
  }

  void deleteClient(int id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    final url = Uri.parse("$baseURL/Home/SetAdminDelFlag/${widget.clientId},$id");
    await get(url);
  }
}