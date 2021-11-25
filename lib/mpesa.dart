import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

class Mpesa extends StatefulWidget {
  const Mpesa({Key? key}) : super(key: key);

  @override
  _MpesaState createState() => _MpesaState();
}

class _MpesaState extends State<Mpesa> {
  Future<void> lipaNaMpesa() async {
    dynamic transactionInitialisation;
    try {
      transactionInitialisation =
          await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: "174379",
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: 1.0,
        partyA: "254706733999",
        partyB: "174379",
//Lipa na Mpesa Online ShortCode
        callBackURL: Uri(
          scheme: "https",
          host: "mpesa-requestbin.herokuapp.com",
          path: "/1hhy6391",
        ),
//This url has been generated from http://mpesa-requestbin.herokuapp.com/?ref=hackernoon.com for test purposes
        accountReference: "Hydro App",
        phoneNumber: "254706733999",
        baseUri: Uri(
          scheme: "https",
          host: "sandbox.safaricom.co.ke",
        ),
        transactionDesc: "purchase",
        passKey:
            "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
      );
//This passkey has been generated from Test Credentials from Safaricom Portal

      return transactionInitialisation;
    } catch (e) {
      print("CAUGHT EXCEPTION: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            lipaNaMpesa();
          },
          child: Text("send"),
        ),
      ),
    );
  }
}
