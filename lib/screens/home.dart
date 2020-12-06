import 'package:flutter/material.dart';
import 'package:mastering_payments/provider/user_provider.dart';
import 'package:mastering_payments/screens/login1.dart';
import 'package:mastering_payments/screens/manage_cards.dart';
import 'package:mastering_payments/screens/payment_error.dart';
import 'package:mastering_payments/screens/purchase_successful.dart';
import 'package:mastering_payments/services/functions.dart';
import 'package:mastering_payments/services/stripe.dart';
import 'package:mastering_payments/services/styles.dart';
import 'package:mastering_payments/widgets/custom_text.dart';
import 'package:provider/provider.dart';

import 'credit_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StripeServices stripe = StripeServices();

  double itemPrice = 12.0;
  @override
  void initState() {
    super.initState();
  }

  List productsList = [
    {"name": "Flutter", "image": "images/flutter.png", "price": 12},
    {"name": "Dart", "image": "images/flutter.png", "price": 12},
  ];
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Payment App",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              height: 150,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Text(
                  "Welcome Here!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: CustomText(
                msg: "Add Credit Card",
              ),
              onTap: () {
                changeScreen(
                    context,
                    CreditCard(
                      title: "Add card",
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: CustomText(
                msg: "Saved Cards",
              ),
              onTap: () {
                changeScreen(context, ManagaCardsScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: CustomText(
                msg: "Log out",
              ),
              onTap: () {
                user.signOut();
                changeScreenReplacement(context, LoginOne());
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              color: white,
              child: ListView(
                children: <Widget>[
                  Visibility(
                    visible: !user.hasStripeId,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          changeScreen(
                              context,
                              CreditCard(
                                title: "Add card",
                              ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: red[400],
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.warning,
                                  color: white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                CustomText(
                                  msg: "Please add your card details",
                                  size: 14,
                                  color: white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 180,
                      child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productsList.length,
                              itemBuilder: (_, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 200,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: grey[800],
                                              offset: Offset(2, 1),
                                              blurRadius: 5)
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              CustomText(
                                                  msg: productsList[index]
                                                      ["name"]),
                                              CustomText(
                                                msg: "\$" +
                                                    productsList[index]["price"]
                                                        .toString(),
                                                weight: FontWeight.bold,
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                        ),
                                        RaisedButton(
                                          child: Text(
                                            "Pay",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          color: Colors.black,
                                          onPressed: () {
                                            showAlertDialog(context);
                                          },
                                        )
                                      ]),
                                    ),
                                  ),
                                );
                              })),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  Widget okButton = FlatButton(
    child: Text(
      "Done",
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[800]),
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  AlertDialog alert = AlertDialog(
    title: Text("Payment Options"),
    actions: [
      RaisedButton(
        child: Text("Pay via New Card"),
        color: Colors.blue[800],
        onPressed: () {
          changeScreen(
              context,
              CreditCard(
                title: "Add Card",
              ));
        },
      ),
      RaisedButton(
        child: Text("Pay via Saved Card"),
        color: Colors.blue[800],
        onPressed: () {
          changeScreen(context, ManagaCardsScreen());
        },
      ),
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
