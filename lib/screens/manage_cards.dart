import 'package:flutter/material.dart';
import 'package:mastering_payments/provider/user_provider.dart';
import 'package:mastering_payments/screens/purchase_successful.dart';
import 'package:mastering_payments/services/functions.dart';
import 'package:mastering_payments/services/stripe.dart';
import 'package:mastering_payments/services/styles.dart';
import 'package:provider/provider.dart';

class ManagaCardsScreen extends StatefulWidget {
  @override
  _ManagaCardsScreenState createState() => _ManagaCardsScreenState();
}

class _ManagaCardsScreenState extends State<ManagaCardsScreen> {
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
            "Cards",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView.builder(
            itemCount: user.cards.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: grey[200],
                            offset: Offset(2, 1),
                            blurRadius: 5)
                      ]),
                  child: ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text("**** **** **** ${user.cards[index].last4}"),
                      subtitle: Text(
                          "${user.cards[index].month} / ${user.cards[index].year}"),
                      trailing: Icon(Icons.more_horiz),
                      onTap: () {
                        StripeServices stripeServices = StripeServices();
                        stripeServices
                            .charge(
                                productName: productsList[index]["name"],
                                cardId: user.userModel.activeCard,
                                userId: user.user.uid,
                                customer: user.userModel.stripeId,
                                amount: productsList[index]["price"])
                            .then((value) {
                          user.loadCardsAndPurchase(userId: user.user.uid);
                          if (value) {
                            changeScreen(context, Success());
                          } else {
                            print("we have a payment error");
                          }
                        });
                      }),
                ),
              );
            }));
  }
}
