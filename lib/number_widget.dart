import 'package:flutter/material.dart';

class NumberWidget extends StatefulWidget {

   final int number;

  const NumberWidget({super.key, required this.number});

  // @override
  // State<NumberWidget> createState() => _NumberWidgetState();

  @override
  _NumberWidgetState createState( ){

    print("Number:$number Create State called");
    
 return _NumberWidgetState();    
  }
}

class _NumberWidgetState extends State<NumberWidget> {
   late int number;
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
     
    number = widget.number;
    print("Nu");



  }



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}