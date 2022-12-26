import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license/screens/license_screen.dart';
import 'package:scan/scan.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? imagePath, companyName = "",licenseCode = "";
  double width = 0.0, height = 0.0;

  @override
  Widget build(BuildContext context) {

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    width = w; height = h;
    
    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover ),),
      child: Scaffold(appBar: AppBar(title:const Text("RetailX License"),),backgroundColor: Colors.transparent,resizeToAvoidBottomInset: false,
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, 
          children: [ 
            ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, child: const Text("QR SCAN",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                    onPressed: () {scanQR(context);},),
        
            ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, child: const Text("IMAGE",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                    onPressed: () {imageQR(context);},),
                    
            ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, child: const Text("LICENSE BY TEXT",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                    onPressed: () {licenseByTextDialog(context);},),
        ],
        ),
      ),
  ),
    );

  
  }

  Widget scanQR(BuildContext context) 
  { 
    return SizedBox(height: height * 0.5,width: width * 1,
    child: ScanView(onCapture: ((data) => {Navigator.of(context).push(MaterialPageRoute(builder: ((context) => SetLicense(qrResult: data,))))}),scanLineColor: Colors.red,));
  }

  void imageQR(BuildContext context) async
  {
    String? imagePath = await  getFromGallery();
    String? qrResult = await Scan.parse(imagePath!);
    Navigator.of(context).push(MaterialPageRoute(builder: ((context) => SetLicense(qrResult: qrResult,))));
  }

  void licenseByTextDialog(BuildContext context)
  {
    showDialog(barrierDismissible: true, context: context, builder: (context) {
    return SingleChildScrollView(
      child: Dialog(insetPadding: EdgeInsets.symmetric(vertical: height * 0.25, horizontal: width * 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(10),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.only(bottom: 20), child: TextField(decoration: InputDecoration(labelText: "Company Name",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
          hintText: "Company Name",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
          onChanged: (value) => companyName = value,
          ),),
    
        Container(padding: const EdgeInsets.only(bottom: 20), child: TextField(decoration: InputDecoration(labelText: "License Code",labelStyle: TextStyle(color: Colors.grey[600]), focusColor: Colors.blue, 
          hintText: "License Code",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
          onChanged: (value) => licenseCode = value,
          ),),
    
        Row(
          children: [ ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.28, 
              child: const Text("Cancel",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                        onPressed: () {Navigator.of(context).pop();},),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ElevatedButton( style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100],elevation: 20), child: Container(alignment: Alignment.center, width: width * 0.28, 
                child: const Text("Continue",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
                          onPressed: () {licenseByText(context);},),
            ),
          ],
        ) 
    
      ],),),),
    );
    });
  }

  void licenseByText(BuildContext context) async
  {
    if(companyName == "" || companyName!.isEmpty)
    {
       showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Company name cannot be empty."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    else if(licenseCode == "" || licenseCode!.isEmpty)
    {
       showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License code cannot be empty."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    else {
      String message = "$companyName;Hadaba;$licenseCode;2;;";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("message", message);
      Navigator.of(context).pop(); 
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) => SetLicense(companyName: companyName, licenseCode: licenseCode,))));
    }
  }

  Future<String?> getFromGallery() async {
    String? imagePath = "" ;
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: width,
      maxHeight: height,
    );
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
     return imagePath;
  }
}
