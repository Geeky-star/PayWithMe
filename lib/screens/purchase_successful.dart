import 'package:flutter/material.dart';
import 'package:mastering_payments/widgets/custom_text.dart';

class Success extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.done,
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              CustomText(
                msg: "Purchase successful",
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          CustomText(
            msg: "Balance Deducted from Account",
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.home),
                  label: CustomText(msg: "Go back home")),
            ],
          )
        ],
      ),
    );
  }
}
