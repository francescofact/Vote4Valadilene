import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v4v/splash.dart';
import 'package:v4v/utils.dart';


class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white);
  final keyController = TextEditingController();
  bool canMove = true;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller){
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (canMove == false)
        return;
      try {
        controller.pauseCamera();
      } catch(error) {
        canMove = false;
      }
      setState(() {
        if (scanData.code.length == 42){
          SharedPreferences.getInstance().then((sp) => {
            sp.setString("contract", scanData.code),
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRoute(
                  page: SplashScreen()
              ),
              (Route<dynamic> route) => false,
            )

          });
        } else {
          Alert(
              context: context,
              type: AlertType.error,
              title:"Scan a Vote QR Code",
              content: Text("The QR Code scanned is not a valid Vote4Valadilene QR Code"),
              style: AlertStyle(
                  animationType: AnimationType.grow
              )
          ).show().then((value) => {
            controller.resumeCamera(),
            canMove = true
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFFd75dfd),
                Color(0xFF675bd4),
              ],
            )
        ),
        child:Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: (result != null)
                    ? Text(
                    'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                    : Text('Scan a code',
                    style: TextStyle(fontSize: 40, color:Colors.white)),
              ),
            )
          ],
        ),
      )
    );
  }
}