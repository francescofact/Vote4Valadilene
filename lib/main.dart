import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v4v/blockchain.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import 'splash.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote4Valadilène',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Blockchain blockchain = Blockchain();

  final candidates = ["0x19226bC2662a4Bb77e9C920cE27D3a3016c9a910", "0x2F11fe2AfEa033Bc56e80e18321ea16F6D65cA02", "0xe39606920F4892D99a3C34E602baF56EaEDCE824"];
  int _selected = -1;

  Future<void> _sendVote() async {
    AlertStyle animation = AlertStyle(animationType: AnimationType.grow);
    if (_selected == -1){
      Alert(
          context: context,
          type: AlertType.error,
          title:"Error",
          desc: "Please select the major you want to vote",
          style: animation
      ).show();
      return;
    }


    List<dynamic> args = [BigInt.from(1234), true, BigInt.from(1000000000000000000)];
    Alert(
      context: context,
      title:"Sending your vote...",
      buttons: [],
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
      )
    ).show();
    Future.delayed(Duration(milliseconds:500), () => {
      blockchain.query("cast_envelope", args).then((value) => {
        Navigator.of(context).pop(),
        Alert(
            context: context,
            type: AlertType.success,
            title:"OK",
            desc: "Your vote has been casted!"
        ).show()
      }).catchError((error){
        Navigator.of(context).pop();
        Alert(
            context: context,
            type: AlertType.error,
            title:"Error",
            desc: blockchain.translateError(error)
        ).show();
      })
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vote4Valadilène"),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: <Widget>[
              Text(
                'Vote The New Major',
                style: TextStyle(fontSize: 40),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: ListView.builder(
                  itemCount: candidates.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          _selected = index;
                        });
                      },
                      child: Card(
                        color: (_selected == index)
                            ? Colors.indigoAccent
                            : Colors.white,
                        child: ListTile(
                          leading: ExcludeSemantics(
                            child: SvgPicture.string(
                              Jdenticon.toSvg("${candidates[index]}"),
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          title: Text(
                              "${candidates[index]}",
                              style: TextStyle(color: (_selected == index)
                                  ? Colors.white
                                  : Colors.black,
                              )
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: _sendVote,
                  child: Text(
                      "Send Vote"
                  )
              ),
            ],
          ),
        ),
      ),
    );

  }
}
