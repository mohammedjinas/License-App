import 'package:flutter/material.dart';
import 'package:license/models/license_list_model.dart';

class LicenseDetail extends StatefulWidget {
  const LicenseDetail({super.key, required this.licenseListModel});

  final LicenseListModel licenseListModel;

  @override
  State<LicenseDetail> createState() => _LicenseDetailState();
}

class _LicenseDetailState extends State<LicenseDetail> {
  double width = 0;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"), fit: BoxFit.cover),),
      child: Scaffold(appBar: AppBar(title:const Text("RetailX License"),),backgroundColor: Colors.transparent,resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              Container(padding: const EdgeInsets.only(top: 10), alignment: Alignment.topCenter, child: Text(widget.licenseListModel.clientName,style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.05),)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.licenseListModel.id),
              Text(widget.licenseListModel.expiryDate),
              Text(widget.licenseListModel.systemName),],)
            ],
          ),
        ),
      ),
    );
  }
}