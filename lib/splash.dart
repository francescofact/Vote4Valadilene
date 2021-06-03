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
            MaterialPageRoute(builder: (context) => FlowScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
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
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image(
                      image: AssetImage('wallet.png')
                  ),
                ),
                SizedBox(height: 25.0),
                Text(
                  "Vote4Valadiene",
                  style: TextStyle(fontSize: 40),
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