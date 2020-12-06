import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:mastering_payments/provider/user_provider.dart';
import 'package:mastering_payments/screens/home.dart';
import 'package:mastering_payments/screens/payment_error.dart';
import 'package:mastering_payments/screens/purchase_successful.dart';
import 'package:mastering_payments/services/functions.dart';
import 'package:mastering_payments/services/stripe.dart';
import 'package:provider/provider.dart';

class CreditCard extends StatefulWidget {
  CreditCard({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  List productsList = [
    {"name": "Flutter", "image": "images/flutter.png", "price": 12},
    {"name": "Dart", "image": "images/flutter.png", "price": 12},
  ];
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView:
                    isCvvFocused, //true when you want to show cvv(back) view
              ),
              CreditCardForm(
                themeColor: Colors.red,
                onCreditCardModelChange: (CreditCardModel data) {
                  setState(() {
                    cardNumber = data.cardNumber;
                    expiryDate = data.expiryDate;
                    cardHolderName = data.cardHolderName;
                    cvvCode = data.cvvCode;
                    isCvvFocused = data.isCvvFocused;
                  });
                },
              ),
              RaisedButton(
                  child: Text(
                    "Pay",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.black,
                  onPressed: () {
                    StripeServices stripeServices = StripeServices();
//
                    stripeServices
                        .charge(
                            productName: productsList[0]["name"],
                            cardId: user.userModel.activeCard,
                            userId: user.user.uid,
                            customer: user.userModel.stripeId,
                            amount: productsList[0]["price"])
                        .then((value) {
                      user.loadCardsAndPurchase(userId: user.user.uid);
                      if (value) {
                        changeScreen(context, Success());
                      } else {
                        changeScreen(context, PaymentError());
                      }
                    });
                    stripeServices
                        .chargePayment(
                            cardId: user.userModel.activeCard,
                            userId: user.user.uid,
                            customer: user.userModel.stripeId,
                            amount: productsList[0]["price"])
                        .then((value) {
                      user.loadCardsAndPurchase(userId: user.user.uid);
                      if (value) {
                        changeScreen(context, Success());
                      } else {
                        changeScreen(context, PaymentError());
                      }
                    });
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          int cvc = int.tryParse(cvvCode);
          int carNo =
              int.tryParse(cardNumber.replaceAll(RegExp(r"\s+\b|\b\s"), ""));
          int exp_year = int.tryParse(expiryDate.substring(3, 5));
          int exp_month = int.tryParse(expiryDate.substring(0, 2));

          print("cvc num: ${cvc.toString()}");
          print("card num: ${carNo.toString()}");
          print("exp year: ${exp_year.toString()}");
          print("exp month: ${exp_month.toString()}");
          print(cardNumber.replaceAll(RegExp(r"\s+\b|\b\s"), ""));
//
          StripeServices stripeServices = StripeServices();
          if (user.userModel.stripeId == null) {
            String stripeID = await stripeServices.createStripeCustomer(
                email: user.userModel.email, userId: user.user.uid);
            print("stripe id: $stripeID");
            print("stripe id: $stripeID");
            print("stripe id: $stripeID");
            print("stripe id: $stripeID");

            stripeServices.addCard(
                stripeId: stripeID,
                month: exp_month,
                year: exp_year,
                cvc: cvc,
                cardNumber: carNo,
                userId: user.user.uid);
          } else {
            stripeServices.addCard(
                stripeId: user.userModel.stripeId,
                month: exp_month,
                year: exp_year,
                cvc: cvc,
                cardNumber: carNo,
                userId: user.user.uid);
          }
          user.hasCard();
          user.loadCardsAndPurchase(userId: user.user.uid);

          changeScreenReplacement(context, HomeScreen());
        },
        tooltip: 'Submit',
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
