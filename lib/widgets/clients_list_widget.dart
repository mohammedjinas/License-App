import 'package:flutter/material.dart';
import 'package:license/models/license_list_model.dart';
import 'package:license/screens/license_det_screen.dart';

class ClientsList extends StatelessWidget {
  
  const ClientsList(this.licenseList, {super.key});
  
  final List<LicenseListModel> licenseList;

  @override
  Widget build(BuildContext context) {
    
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListView.builder(itemBuilder: ((context, index) {
      return InkWell(
        child: Row(children: [
            
            Container(height: height * 0.05,width: width * 0.1,decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
            child:  FittedBox(fit: BoxFit.fitWidth, child: Text(licenseList[index].id,style: TextStyle(color: Colors.black, fontSize: height * 0.015),)),),
            
            Container(height: height * 0.05,width: width * 0.005, decoration: const BoxDecoration(color: Colors.grey)),
      
            Container(height: height * 0.05,width: width * 0.48, decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
            child: Text(licenseList[index].clientName,style: TextStyle(color: Colors.black, fontSize: height * 0.015),),),
            
            Container(height: height * 0.05,width: width * 0.005, decoration: const BoxDecoration(color: Colors.grey)),
      
            Container(height: height * 0.05,width: width * 0.2,decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
            child: Text(licenseList[index].systemName, style: TextStyle(color: Colors.black, fontSize: height * 0.015),),),
            
            Container(height: height * 0.05,width: width * 0.005, decoration: const BoxDecoration(color: Colors.grey)),
            
            Container(height: height * 0.05,width: width * 0.2,decoration: BoxDecoration(color: Colors.blue[50]),alignment: Alignment.center,
            child: Text(licenseList[index].systemId,style: TextStyle(color: Colors.black, fontSize: height * 0.015),),),
        ],),
        onTap: () {
          LicenseListModel selectedItem = LicenseListModel(id: licenseList[index].id, clientName: licenseList[index].clientName, systemName: licenseList[index].systemName, systemId: licenseList[index].systemId);
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return LicenseDetail(licenseListModel: selectedItem,);
          })));
        },
      );
    }),itemCount: licenseList.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    );
  }
}