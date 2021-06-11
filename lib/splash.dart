import 'package:flutter/material.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v4v/qr.dart';

import 'blockchain.dart';
import 'login.dart';
import 'flow.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class NoBlockChainScreen extends StatefulWidget {
  @override
  _NoBlockChainScreenState createState() => _NoBlockChainScreenState();
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
    String contract = prefs.getString('contract');
    Future.delayed(Duration(seconds: 2), () async {
      if (contract == null){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => QRScreen()),
                (Route<dynamic> route) => false,
          );
        });
      }
      if (key == null){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else if (await Blockchain().check() == false) {
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NoBlockChainScreen()),
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

class _NoBlockChainScreenState extends State<NoBlockChainScreen> {

  Blockchain blockchain = Blockchain();

  void _checkConnection(AnimationController anim) async{
    anim.forward();
    Future.delayed(Duration(seconds: 3), () async {
      if (await blockchain.check() == true){
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => FlowScreen()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        print("No Connection");
        anim.reset();
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
                      'assets/no-signal.png'
                  ),
                ),
                SizedBox(height: 25.0),
                Text(
                  "No Blockchain connection",
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
                SizedBox(height: 25.0),
                Container(
                  width: 200,
                  child: ProgressButton(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    strokeWidth: 2,
                    child: Text(
                      "Retry",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    onPressed: (AnimationController controller) async {
                      _checkConnection(controller);
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}