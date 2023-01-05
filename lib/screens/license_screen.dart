import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:license/screens/scan_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SetLicense extends StatefulWidget {
  final String? qrResult;

  const SetLicense({super.key, this.qrResult = "",});

  @override
  State<SetLicense> createState() => _SetLicenseState();
}

class _SetLicenseState extends State<SetLicense> {
  TextEditingController txtTrialDays = TextEditingController();
  TextEditingController txtCustomerId = TextEditingController();
  TextEditingController txtRemarks = TextEditingController();

  String?   txtLicenseName = "", txtCompanyName = "", txtLicenseType = "", txtComputerName = "", licenseCode = "";

  late Future salesMenList, pdfFile;
  String selectedValue = "",option = "Update",licenseId = "",splitter = "";
  double width = 0.0, height = 0.0;
  int trialDays = 30;
  bool licenseExist = false;
  FocusNode customerIdFocus = FocusNode();
  FocusNode trialDaysFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    salesMenList = getSalesMen();
    pdfFile = generatePdf();

    customerIdFocus.addListener (() {
      licenseExist = false;
      if (!customerIdFocus.hasFocus && txtCustomerId.text.isNotEmpty && txtCustomerId.text != "") {

      checkLicenseStatus();
      }
    });

    trialDaysFocus.addListener(() {
      if(!trialDaysFocus.hasFocus && txtTrialDays.text.isNotEmpty && txtTrialDays.text != "")
      {
        if(int.parse(txtTrialDays.text) > 60)
        {
          showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("Trial days cannot be more than 60 days"),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          trialDaysFocus.requestFocus();
          return;
        }
      }
    });
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

    if(widget.qrResult! != "" && widget.qrResult!.isNotEmpty)
    {
      
      if(widget.qrResult!.contains("+"))
      {
        splitter = "+";
      }
      
      if(widget.qrResult!.contains(";"))
      {
        splitter = ";";
      }
      var split = widget.qrResult!.split(splitter);
      txtCompanyName = split[0];
      txtComputerName = split[1];
      licenseCode = split[2];
    }

    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover)),
      child: Scaffold(
        appBar: AppBar(title:const Text("RetailX License",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const ScanScreen();
            },));
          },
          ),),
        floatingActionButton:  FloatingActionButton(
          onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return FutureBuilder(
              future: pdfFile,
              builder: ((context, snapshot) {
              if(txtLicenseName != "" && txtLicenseName!.isNotEmpty)
              {
                return PdfPreview(build: (context) => snapshot.data);
              }
              else {return  Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/login_bg.jpg"),fit: BoxFit.cover)),
                child: AlertDialog(title: const Text("RetailX License"),content: const Text("No license generated to share."),
                actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],),
              );}
            }));
          }))); },
          backgroundColor: Colors.black,
          child: const Icon(Icons.picture_as_pdf),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column( children: [

            Container(padding: const EdgeInsets.all(10), alignment: Alignment.center, 
            child: Text(txtCompanyName!, style: TextStyle(fontWeight: FontWeight.bold,fontSize: width * 0.04),)
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
                  focusNode: customerIdFocus,
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
                  focusNode: trialDaysFocus,
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
                 
                 Container(height: height * 0.045,
                  decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal : 5.0),
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
                 ),       
              ],
            )
            ),
    
            Container(padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.03),
            child: Column(children: [
              
              Container( width: width * 0.6, height: height * 0.05,padding: const EdgeInsets.only(bottom: 5),
                child: ElevatedButton(onPressed: () {isExisting(txtCustomerId.text, txtCompanyName!,"T");}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 10, ),
                child: const Text("Trial License",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
              ),
              
              SizedBox(width: width * 0.6, height: height * 0.05,
                child: ElevatedButton(onPressed: () {isExisting(txtCustomerId.text, txtCompanyName!,"F");},style: ElevatedButton.styleFrom(backgroundColor: Colors.white,elevation: 10), 
                child: const Text("Full License",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
              ),
            ],),),
    
            SizedBox(height: height * 0.02,),
            
            Container(height: 2, width: width, color: Colors.grey[300],),
            
            SizedBox(height: height * 0.05,),

            if(txtLicenseName != "" && txtLicenseName!.isNotEmpty)
            Column(
              children: [
                
                Text(txtLicenseType!,style: TextStyle(fontWeight: FontWeight.w500, fontSize: width * 0.05,color: Colors.blueGrey),),
                
                SizedBox(height: height * 0.03 ,),
    
                Text(txtComputerName!,style: TextStyle(fontWeight: FontWeight.w500, fontSize: width * 0.08,color: Colors.black87),),
                
                SizedBox(height: height * 0.03 ,),
    
                Text(txtLicenseName!,style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * 0.05,color: Colors.red),),

                SizedBox(height: height * 0.03 ,),
    
                Text(txtCompanyName!,style: TextStyle(fontWeight: FontWeight.w500, fontSize: width * 0.05,color: Colors.black87),),
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
      if(txtLicenseName! != "" && txtLicenseName!.isNotEmpty)
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
                  onPressed: () {
                    if(txtLicenseName == "") {
                      Navigator.of(context).pop();
                    }
                    else{
                      if(txtRemarks.text.isNotEmpty && txtRemarks.text != "" && licenseId != "") {
                        saveRemarks();
                        Navigator.of(context).pop();
                      }
                    }
                  },),
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
          
          for(int i = 0; i < salesMenListFromJson.length; i ++)
          {
            salesMenList.add(DropdownMenuItem<String>(value: salesMenListFromJson[i] as String,
            child: SizedBox(height: height * 0.016, 
            child: Text(salesMenListFromJson[i] as String,
            style: TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, fontSize: height * 0.015),),),),);
          }

          salesMenList.add(DropdownMenuItem<String>(value: "",
            child: SizedBox(height: height * 0.016, 
            child: Text("",
            style: TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, fontSize: height * 0.015),),),));       

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
      if(licenseExist)
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
      else{
        if(await checkLicenseCount())
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
    }
  }

  void generateLicense(String licenseType) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? message = widget.qrResult, username = prefs.getString("username"), remarks,
    baseURL = prefs.getString("baseURL");
    String customerId = txtCustomerId.text;

    if(message == "" || message!.isEmpty)
    {
      message = "Invalid QR Code";
    }
    else{

      if(licenseType == "T")
      {
        message = "$message$splitter$licenseType$trialDays$splitter$username$splitter$customerId$splitter$selectedValue";
      }
      else if(licenseType == "F")
      {
        message = "$message$splitter$licenseType$splitter$username$splitter$customerId$splitter$selectedValue";
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
        try{
        if(response.body.isNotEmpty)
        {
          var jsonData = jsonDecode(response.body);
          
          setState(() {
            txtLicenseName = jsonData['licenceName'];
            txtLicenseType = jsonData['licenceType'];
            licenseId = jsonData["licenseId"];
            licenseExist = false;
          });
        }
        else
        {
          showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License generation failed.\n\nPlease check before trying again"),
          actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
          return;
        }
        }on Exception catch(_)
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
    final pdfDoc = pw.Document();
    Uint8List pdfFile = Uint8List(1);
    
    var imageProvider = pw.MemoryImage((await rootBundle.load('assets/images/login_bg.jpg')).buffer.asUint8List());

    pdfDoc.addPage(pw.Page(pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(decoration: pw.BoxDecoration(image: pw.DecorationImage(image: imageProvider,fit: pw.BoxFit.contain)),
        child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text(txtCompanyName!.toUpperCase(),style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic,fontSize: width * 0.05)),
        pw.SizedBox(height: 20),
        
        pw.Text(txtComputerName!,style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic,fontSize: width * 0.05)),
        pw.SizedBox(height: 20),
        
        pw.Text(txtLicenseName!,style: pw.TextStyle(fontStyle: pw.FontStyle.italic,fontSize: width * 0.06)),
        pw.SizedBox(height: 20),
      ]),),
    ));

    pdfFile = await pdfDoc.save();
    return pdfFile;
  }
  
  void saveRemarks() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    final remarks = txtRemarks.text, id = int.parse(licenseId);
    
    final url = Uri.parse("$baseURL/Home/UpdateRemarks/$remarks,$id");
    await get(url);
  }

  Future<bool> checkLicenseCount() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerId = txtCustomerId.text;
    String? baseURL = prefs.getString("baseURL");
    
    final url = Uri.parse("$baseURL/Home/CheckNoOfLicense/$customerId");
    Response response = await get(url);
    if(response.statusCode == 200)
    {
      if(response.body.toString() == "Limit not reached") {
        // if(await checkLicenseStatus()) {
        //   return true;
        // }
        // else{
        //   return false;
        // }
        return true;
      }
      else
      {
        showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content:  Text(response.body.toString()),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("OK"))],)));
        return false;
      }
    }
    else{
      return false;
    }
  }

  
  Future<bool> checkLicenseStatus() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseURL = prefs.getString("baseURL");
    String customerId = txtCustomerId.text;
    final url = Uri.parse("$baseURL/Home/CheckLicenseStatus/$txtComputerName,$licenseCode,$customerId");
    Response response = await get(url); 
    if(response.statusCode == 200)
    {
      if(response.body.toString() != "Expired")
      {
        licenseExist = true;
        return await showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content:  Text(response.body.toString()),
        actions: [TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: const Text("OK"))],)));
      }
      else{
        licenseExist = false;
        return true;
      }
    }
    else
    {
      return await showDialog(context: context, builder: ((context) => AlertDialog(title: const Text("RetailX License"),content: const Text("License status check failed. Do you want to proceed?"),
        actions: [
          TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: const Text("Yes")),
          TextButton(onPressed: () {Navigator.of(context).pop(false); }, child: const Text("No"))
        ],)));
    }
  }
}