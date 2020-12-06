import 'package:flutter/material.dart';

class PaymentError extends StatefulWidget {
  @override
  _PaymentErrorState createState() => _PaymentErrorState();
}

class _PaymentErrorState extends State<PaymentError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Payment error",
        style: TextStyle(fontSize: 30,fontWeight: FontWeight.w600),),
      ),
    );
  }
}