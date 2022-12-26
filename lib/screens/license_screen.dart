import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SetLicense extends StatefulWidget {
  final String? qrResult, companyName,licenseCode; 

  const SetLicense({super.key, this.qrResult = "",this.companyName = "",this.licenseCode = ""});

  @override
  State<SetLicense> createState() => _SetLicenseState();
}

class _SetLicenseState extends State<SetLicense> {
  TextEditingController txtTrialDays = TextEditingController();
  TextEditingController txtCustomerId = TextEditingController();
  TextEditingController txtRemarks = TextEditingController();
  TextEditingController txtLicenseName = TextEditingController();
  TextEditingController txtCompanyName = TextEditingController();
  TextEditingController txtLicenseType = TextEditingController();

  late Future salesMenList, pdfFile;
  String selectedValue = "",option = "Insert";
  double width = 0.0, height = 0.0;
  int trialDays = 30;

  @override
  void initState() {
    super.initState();
    salesMenList = getSalesMen();
    pdfFile = generatePdf();
    
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    pdfFile = generatePdf();
  }
  @override
  Widget build(BuildContext context) {
    
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    txtTrialDays.text = "$trialDays";

    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover)),
    width: width,
      child: Scaffold(
        appBar: AppBar(title:const Text("RetailX License",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),),
        floatingActionButton:  FloatingActionButton(
          onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return FutureBuilder(
              future: pdfFile,
              builder: ((context, snapshot) {
              if(txtLicenseName.text != "" && txtLicenseName.text.isNotEmpty)
              {
                return PdfPreview(build: (context) => snapshot.data);
              }
              else {return  Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"))),
                child: AlertDialog(title: const Text("RetailX License"),content: const Text("No license generated to share."),
                actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),
              );}
            }));
          }))); },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.picture_as_pdf),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column( children: [
            Container(padding: const EdgeInsets.all(10), alignment: Alignment.center, 
            child: Text(widget.companyName!, style: TextStyle(fontWeight: FontWeight.bold,fontSize: width * 0.05),)
            ),
            Container(padding: EdgeInsets.symmetric(vertical: height * 0.03, horizontal: width * 0.03),
            child: Row(children: [
              Container( width:width * 0.4,height: height * 0.05,alignment: Alignment.bottomCenter,
              child: TextField(textAlign: TextAlign.center, 
              keyboardType: TextInputType.number, 
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: "Customer ID",hintText: "Customer ID",hintStyle:const TextStyle(color: Colors.black87), focusColor: Colors.blue,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                  controller: txtCustomerId,
                  ),),
    
              Container(width:width * 0.4,height: height * 0.05, padding: EdgeInsets.only(left: width * 0.02),alignment: Alignment.center,
              child: 
              TextField(textAlign: TextAlign.center, 
              keyboardType: TextInputType.number, 
              decoration: InputDecoration(labelText: "Trial Days",hintText: "Trial Days",hintStyle:const TextStyle(color: Colors.black87), focusColor: Colors.blue,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),                  
                  inputFormatters: [LengthLimitingTextInputFormatter(2)],
                  onChanged: ((value) { if(value.isNotEmpty || value != "") trialDays = int.parse(value);}),
                  controller: txtTrialDays,
                  ),
              ),
    
              Container(width: width * 0.12, height:  width* 0.12,padding: EdgeInsets.only(left: width * 0.02),alignment: Alignment.center,
              child: Ink.image(image:const AssetImage("assets/images/remarks.png"),
              child: InkWell(onTap: () {
                showRemarksDialog();
              },),),) 
            ]),),
    
            Container(alignment: Alignment.center, 
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Text("Sales Man: ", style: TextStyle(fontWeight: FontWeight.w600,),),
                 
                 Container(height: height * 0.04,
                  decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.only(left : 10.0),
                  child: FutureBuilder(future: salesMenList, 
                  builder: ((context, snapshot) {
                  if(snapshot.hasData)
                  {
                    return DropdownButton(items: snapshot.data, onChanged: (value) {
                      setState(() {
                        selectedValue = value!;
                      });
                    },
                    value: selectedValue,
                    alignment: Alignment.center,
                    dropdownColor: Colors.blue[50]);
                  }
                  else {return DropdownButton(items: null, onChanged: (value) {},hint: const Text("Select sales man"),);}
                  })),
                 )                 
              ],
            )
            ),
    
            Container(padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.03),
            child: Column(children: [
              
              Container( width: width * 0.6, height: height * 0.05,padding: const EdgeInsets.only(bottom: 5),
                child: ElevatedButton(onPressed: () {isExisting(txtCustomerId.text, widget.companyName!,"T");}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 10, ),
                child: const Text("Trial License",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
              ),
              
              SizedBox(width: width * 0.6, height: height * 0.05,
                child: ElevatedButton(onPressed: () {isExisting(txtCustomerId.text, widget.companyName!,"F");},style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 10), 
                child: const Text("Full License",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
              ),
            ],),),
    
            SizedBox(height: height * 0.02,),
            
            Container(height: 2, width: width, color: Colors.grey[300],),
            
            SizedBox(height: height * 0.05,),
    
            Column(
              children: [
                
                Text(txtLicenseType.text,style: TextStyle(fontWeight: FontWeight.w500, fontSize: width * 0.05,color: Colors.blueGrey),),
                
                SizedBox(height: height * 0.03 ,),
    
                Text(txtCompanyName.text,style: TextStyle(fontWeight: FontWeight.w500, fontSize: width * 0.08,color: Colors.black87),),
                
                SizedBox(height: height * 0.03 ,),
    
                Text(txtLicenseName.text,style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * 0.05,color: Colors.red),),
              ],
            ),
    
          ],),
        ),),
    );
  }

  FutureBuilder pdfViewer()
  {
    return FutureBuilder(
      future: pdfFile,
      builder: ((context, snapshot) {
      if(txtLicenseName.text != "" && txtLicenseName.text.isNotEmpty)
      {
        return PdfPreview(build: snapshot.data,);
      }
      else {return AlertDialog(title: const Text("RetailX License"),content: const Text("No data available to share."),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],);}
    }));
  }

  void showRemarksDialog()
  {
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
                            onPressed: () {Navigator.of(context).pop();},),
              ),
            ],
          ) 
      
        ],),),),
      );
     });
  }
  
  Future<List<DropdownMenuItem<String>>> getSalesMen() async
  {
    List<DropdownMenuItem<String>> salesMenList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    final url = Uri.parse("$baseURL/Home/GetSalesMen");
    Response response = await get(url);

    if(response.statusCode == 200)
    {
      final responseJson = jsonDecode(response.body);
      if(responseJson['result'] == 1)
      {
        final List<dynamic> salesMenListFromJson = responseJson['salesMen'];
        if(salesMenListFromJson.isNotEmpty)
        {
          selectedValue = salesMenListFromJson[0] as String;
          for(int i = 0; i < salesMenListFromJson.length; i ++)
          {
            salesMenList.add(DropdownMenuItem<String>(value: salesMenListFromJson[i] as String,
            child: SizedBox(height: height * 0.016, 
            child: Text(salesMenListFromJson[i] as String,
            style: TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, fontSize: height * 0.015),),),),);
          }

        }
      }
    }
    else{
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("API error. Please try again."),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
    }
    return salesMenList;
  }


  void isExisting(String customerId, String compName,String licenseType) async
  {
    
    if(validateFields(licenseType))
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? baseURL = prefs.getString("baseURL");
      String customerId = txtCustomerId.text;


      int customerID = int.parse(customerId);
      final url = Uri.parse("$baseURL/Home/CheckCustomer/$customerID,$compName");
      Response response = await get(url);
      if(response.statusCode == 200)
      {
        if(response.body.isNotEmpty)
        {
          var jsonData = jsonDecode(response.body);
          if(jsonData['result'] == 1)
          {
            if(jsonData['message'] == "Exist with diff name")
            {
              showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),
              content: const Text("Client already exist with a different name.\nDo you wish to continue?"),
              actions: [

                TextButton(onPressed: () {Navigator.of(context).pop(); return; }, child: const Text("No")),

                TextButton(onPressed: () {Navigator.of(context).pop();
                  showDialog(context: context, builder: ((context) => AlertDialog(
                    title: const Text("RetailX License"),
                    content: const Text("Do you wish to update client name?"),
                    actions: [
                      TextButton(onPressed: () {option = "Update"; generateLicense(licenseType); Navigator.of(context).pop();}, child: const Text("Yes")),

                      TextButton(onPressed: () {
                        Navigator.of(context).pop(); return;
                      }, child: const Text("No"))
                    ],
                  )));
                }, child: const Text("Yes"))
                ],)));
            }
            else 
            {
              generateLicense(licenseType);
            }
          }
          else if(jsonData['result'] == 2)
          {
            generateLicense(licenseType);
          }
          else
          {
            showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Checking existing customer failed.\nPlease try again."),
            actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          }
        }
        else 
        {
          showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Could not fetch data. Please try again."),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        }
      }
      else 
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("HTTP request failed. Please try again."),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      }
    }
  }

  void generateLicense(String licenseType) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? message = prefs.getString("message"), username = prefs.getString("username"), remarks,
    baseURL = prefs.getString("baseURL");
    String customerId = txtCustomerId.text;

    if(message == "" || message!.isEmpty)
    {
      message = "Invalid QR Code";
    }
    else{

      if(licenseType == "T")
      {
        message = "$message;T$trialDays;$username;$customerId;$selectedValue";
      }
      else if(licenseType == "F")
      {
        message = "$message;F;$username;$customerId;$selectedValue";
      }

      remarks = txtRemarks.text;

      Map<String,String> mapPostData = {
      'postdata': message, 'Remarks': remarks, 'Option' : option
      };

      var jsonPostdata = jsonEncode(mapPostData);

      final url = Uri.parse("$baseURL/Home/GetLicence");
      http.Response response = await http.post(url,headers: {"Content-Type": "application/json"},body: jsonPostdata);
      if(response.statusCode == 200)
      {
        if(response.body.isNotEmpty)
        {
          var jsonData = jsonDecode(response.body);
          
          setState(() {
            txtLicenseName.text = jsonData['licenceName'];
            txtCompanyName.text = jsonData['companyName'];
            txtLicenseType.text = jsonData['licenceType'];

          });
        }
        else
        {
          showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License generation failed.\n\nPlease check before trying again"),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          return;
        }
      }
      else {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License generation failed due to API error.\n\nPlease check before trying again"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        return;
      }
    }
  }

  bool validateFields(String licenseType)
  {
    if(licenseType == "T")
    {
      if(trialDays > 60) 
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Trial days should not be more than 60 days"),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        return false;
      }
    }
    
    if(txtCustomerId.text.isEmpty || txtCustomerId.text == "")
    {
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Please enter a Customer ID"),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      return false;
    }

    if(selectedValue.isEmpty || selectedValue == "")
    {
      showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Please select a sales man"),
      actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
      return false;
    }
    return true;
  }

  Future<Uint8List> generatePdf() async
  {
    final pdfDoc = pw.Document(title: "TEST.pdf",);
    Uint8List pdfFile = Uint8List(1);

    pdfDoc.addPage(pw.Page(pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text(txtCompanyName.text,style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic,fontSize: width * 0.05)),
        pw.SizedBox(height: 20),
        
        pw.Text(txtLicenseName.text,style: pw.TextStyle(color: const PdfColor.fromInt(10), fontStyle: pw.FontStyle.italic,fontSize: width * 0.05)),
        pw.SizedBox(height: 20),
      ]),),
    ));

    pdfFile = await pdfDoc.save();
    return pdfFile;
  }
}