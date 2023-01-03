import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  ButtonWidget({super.key,required this.buttonText, required this.returnWidget});
  String buttonText = "";
  Widget returnWidget;

  @override
  Widget build(BuildContext context) {
    
  double width = MediaQuery.of(context).size.width;
  return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,), child: Container(alignment: Alignment.center, width: width * 0.6, 
          child: Text(buttonText,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500, fontSize: width * 0.04),)),
          onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) { return returnWidget;})
        );                
      }, 
    );
  }
}