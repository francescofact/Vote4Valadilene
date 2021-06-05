
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:steps/steps.dart';
import 'package:v4v/blockchain.dart';
import 'package:v4v/main.dart';

class FlowScreen extends StatefulWidget {
  @override
  _FlowScreenState createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  Blockchain blockchain = Blockchain();
  AlertStyle animation = AlertStyle(animationType: AnimationType.grow);



  Future<void> _openVote() async {
    List<dynamic> args = [BigInt.from(1234), true];
    Alert(
        context: context,
        title:"Confirming your vote...",
        buttons: [],
        style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
          isOverlayTapDismiss: false,
        )
    ).show();
    Future.delayed(Duration(milliseconds:500), () => {
      blockchain.query("open_envelope", args, wei:1000000000000000000).then((value) => {
        Navigator.of(context).pop(),
        Alert(
            context: context,
            type: AlertType.success,
            title:"OK",
            desc: "Your vote has been casted!",
            style: animation
        ).show()
      }).catchError((error){
        Navigator.of(context).pop();
        Alert(
            context: context,
            type: AlertType.error,
            title:"Error",
            desc: blockchain.translateError(error),
          style: animation
        ).show();
      })
    });
  }

  void _freezeVote(){
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once you confirm your vote you cannot change it",
      style: animation,
      buttons: [
        DialogButton(
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => {
            Navigator.pop(context),
            _openVote(),
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Vote4Valiene"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Steps(
            direction: Axis.vertical,
            size: 20.0,
            path: {'color': Colors.lightBlue.shade200, 'width': 3.0},
            steps: [
              {
                'color': Colors.white,
                'background': Colors.lightBlue.shade700,
                'label': '1',
                'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Send your vote',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      'Every vote you cast overwrites the previous one',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height:20.0),
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        ),
                        child: Text("Vote")
                    )
                  ],
                ),
              },
              {
                'color': Colors.white,
                'background': Colors.lightBlue.shade700,
                'label': '2',
                'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Confirm your vote',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      'When the quorum is reached you can confirm your vote',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height:20.0),
                    ElevatedButton(
                        onPressed: _freezeVote,
                        child: Text("Confirm")
                    )
                  ],
                )
              },
              {
                'color': Colors.white,
                'background': Colors.lightBlue.shade200,
                'label': '3',
                'content': Image.asset(
                  'assets/wallet.png',
                  width: 250,
                  height: 120,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              }
            ],
          ),
        ));
  }
}