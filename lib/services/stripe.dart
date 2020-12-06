import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:mastering_payments/services/cards.dart';
import 'package:mastering_payments/services/purchases.dart';
import 'package:mastering_payments/services/user.dart';
import 'package:uuid/uuid.dart';

class StripeServices {
  static const PUBLISHABLE_KEY =
      "pk_test_51HuY9ILpNAvy9SzKhiBHkqvjWujk7jQGWqzh9qoBmagbaPAGfxoL1FeP3Qxn6eCCQshIhQo2vHODYmYnjfireTsn00ka6e9ymz";
  static const SECRET_KEY =
      "sk_test_51HuY9ILpNAvy9SzKsMp8U4LElRDgM34qQKhIycqiMImWSjE0cIeFGPDtnAtkmnalaBvfkSoA5kVmCCHvQucM6gzl00e0NuFaT4";
  static const PAYMENT_METHOD_URL = "https://api.stripe.com/v1/payment_methods";
  static const CUSTOMERS_URL = "https://api.stripe.com/v1/customers";
  static const CHARGE_URL = "https://api.stripe.com/v1/charges";
  Map<String, String> headers = {
    'Authorization': "Bearer  $SECRET_KEY",
    "Content-Type": "application/x-www-form-urlencoded"
  };
  static const PAYMENT_INTENT = " https://api.stripe.com/v1/payment_intents";

  Future<String> createStripeCustomer({String email, String userId}) async {
    Map<String, String> body = {
      'email': email,
    };

    String stripeId = await http
        .post(CUSTOMERS_URL, body: body, headers: headers)
        .then((response) {
      String stripeId = jsonDecode(response.body)["id"];
      print("The stripe id is: $stripeId");
      UserService userService = UserService();
      userService.updateDetails({"id": userId, "stripeId": stripeId});
      return stripeId;
    }).catchError((err) {
      print("==== THERE WAS AN ERROR ====: ${err.toString()}");
      return null;
    });

    return stripeId;
  }

  Future<void> addCard(
      {int cardNumber,
      int month,
      int year,
      int cvc,
      String stripeId,
      String userId}) async {
    Map body = {
      "type": "card",
      "card[number]": cardNumber,
      "card[exp_month]": month,
      "card[exp_year]": year,
      "card[cvc]": cvc
    };
    Dio()
        .post(PAYMENT_METHOD_URL,
            data: body,
            options: Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: headers))
        .then((response) {
      String paymentMethod = response.data["id"];
      print("=== The payment mathod id id ===: $paymentMethod");
      http
          .post(
              "https://api.stripe.com/v1/payment_methods/$paymentMethod/attach",
              body: {"customer": stripeId},
              headers: headers)
          .catchError((err) {
        print("ERROR ATTACHING CARD TO CUSTOMER");
        print("ERROR: ${err.toString()}");
      });

      CardServices cardServices = CardServices();
      cardServices.createCard(
          id: paymentMethod,
          last4: int.parse(cardNumber.toString().substring(11)),
          exp_month: month,
          exp_year: year,
          userId: userId);
      UserService userService = UserService();
      userService.updateDetails({"id": userId, "activeCard": paymentMethod});
    });
  }

  Future<bool> chargePayment({
    String customer,
    int amount,
    String userId,
    String cardId,
    String payment_method_types,
  }) async {
    Map<String, dynamic> data = {
      "amount": amount,
      "currency": "inr",
      "source": cardId,
      "customer": customer,
      "payment_method_types": ["card"],
    };
    try {
      await Dio()
          .post("https://api.stripe.com/v1/checkout/sessions",
              data: data, options: Options(headers: headers))
          .then((response) {
        print(response.toString());
      });
    } catch (e) {
      print("there was an error charging the customer: ${e.toString()}");
    }
  }

  Future<bool> charge(
      {String customer,
      int amount,
      String userId,
      String cardId,
      String productName}) async {
    Map<String, dynamic> data = {
      "amount": amount,
      "currency": "USD",
      "source": cardId,
      "customer": customer
    };
    try {
      Dio()
          .post(CHARGE_URL,
              data: data,
              options: Options(
                  contentType: Headers.formUrlEncodedContentType,
                  headers: headers))
          .then((response) {
        print(response.toString());
      });
      PurchaseServices purchaseServices = PurchaseServices();
      var uuid = Uuid();
      var purchaseId = uuid.v1();
      purchaseServices.createPurchase(
          id: purchaseId,
          amount: amount,
          cardId: cardId,
          userId: userId,
          productName: productName);
      return true;
    } catch (e) {
      print("there was an error charging the customer: ${e.toString()}");
      return false;
    }
  }
}
