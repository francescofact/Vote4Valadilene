import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:v4v/blockchain.dart';

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
      debugShowCheckedModeBanner: false,
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

  final text_souls = TextEditingController();
  final text_secret = TextEditingController();
  List<dynamic> candidates = [];
  int _selected = -1;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateCandidates());
  }

  Future<void> _updateCandidates() async {
    Alert(
        context: context,
        title:"Getting candidates...",
        buttons: [],
        style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
          isOverlayTapDismiss: false,
        )
    ).show();
    Future.delayed(Duration(milliseconds:500), () => {
      blockchain.queryView("get_candidates", []).then((value) => {
        Navigator.of(context).pop(),
        setState(() {
          candidates = value[0];
        })
      }).catchError((error){
        Navigator.of(context).pop();
        Alert(
            context: context,
            type: AlertType.error,
            title:"Error",
            desc: (error is NoSuchMethodError)
                ? error.toString()
                : blockchain.translateError(error)
        ).show();
      })
    });
  }

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

    List<dynamic> args = [BigInt.parse(text_secret.text), candidates[_selected], BigInt.parse(text_souls.text)];
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
            desc: (error is NoSuchMethodError)
                ? error.toString()
                : error.toString()//blockchain.translateError(error)
        ).show();
      })
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          child: AppBar(
            title: Text("Vote4Valadilene"),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF8b5be1),
                Color(0xFF675bd4),
              ],
            ),
          ),
        ),
        preferredSize: Size(MediaQuery.of(context).size.width, 45),
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
              Text("How many souls?"),
              SizedBox(
                height:90,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                    children: [
                      TextField(
                          decoration: new InputDecoration(hintText: "Souls in Wei"),
                          keyboardType: TextInputType.number,
                          controller: text_souls,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                      ),
                      SizedBox(
                        height:10,
                      ),
                      Wrap(
                        children:[
                          InputChip(
                              label: Text('5 ETH'),
                              onSelected: (bool) => {text_souls.text = "5000000000000000000"}
                          ),
                          SizedBox(width:8),
                          InputChip(
                              label: Text('1 ETH'),
                              onSelected: (bool) => {text_souls.text = "1000000000000000000"}
                          ),
                          SizedBox(width:8),
                          InputChip(
                              label: Text('0.5 ETH'),
                              onSelected: (bool) => {text_souls.text = "500000000000000000"}
                          ),
                          SizedBox(width:8),
                          InputChip(
                              label: Text('0.01 ETH'),
                              onSelected: (bool) => {text_souls.text = "10000000000000000"}
                          ),
                        ]
                      ),
                    ]
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text("Create your secret"),
              SizedBox(
                height:40,
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  decoration: new InputDecoration(hintText: "Secret in numbers"),
                  keyboardType: TextInputType.number,
                  controller: text_secret,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 30,
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
