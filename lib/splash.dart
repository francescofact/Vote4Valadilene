import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v4v/main.dart';

import 'login.dart';
import 'flow.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkKey(context));
  }

  void _checkKey(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('key');
    Future.delayed(Duration(seconds: 2), () {
      if (key == null){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => FlowScreen()),
                (Route<dynamic> route) => false,
          );
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
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
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    'assets/vote.png'
                  ),
                ),
                SizedBox(height: 25.0),
                Text(
                  "Vote4Valadiene",
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
                SizedBox(height: 25.0),
              ],
            ),
         ),
        ),
      ),
    );
  }
}