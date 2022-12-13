import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SetLicense extends StatelessWidget {
  String? qrResult;
  String? companyName,licenseCode;

  SetLicense({super.key, this.qrResult = "",this.companyName = "",this.licenseCode = ""});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title:const Text("RetailX License"),),
    body: Center(child: Column(children: [Text(qrResult!),Text(companyName!),Text(licenseCode!)],)),);
  }
}