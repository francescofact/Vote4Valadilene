
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:steps/steps.dart';
import 'package:v4v/blockchain.dart';
import 'package:v4v/vote.dart';
import 'package:v4v/splash.dart';
import 'package:v4v/winner.dart';

class FlowScreen extends StatefulWidget {
  @override
  _FlowScreenState createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  Blockchain blockchain = Blockchain();
  AlertStyle animation = AlertStyle(animationType: AnimationType.grow);
  String quorum_text = "Loading Quorum...";
  double quorum_circle = 0.0;
  double step = -1;
  bool isMayor;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateQuorum());
  }

  Future<void> _mayorOrSayonara() async {
    Alert(
        context: context,
        title:"Asking the winner...",
        buttons: [],
        style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
          isOverlayTapDismiss: false,
        )
    ).show();
    Future.delayed(Duration(milliseconds:500), () async =>
    {
      blockchain.query("mayor_or_sayonara", []).then((value) =>
      {
        Navigator.of(context).pop(),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Winner()),
        )
      }).catchError((error) {
        Navigator.of(context).pop();
        if (error.toString().contains("has already been")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Winner()),
          );
          return null;
        }
        Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: blockchain.translateError(error),
            style: animation
        ).show();
      })
    });
  }

  Future<void> _deposit() async {
    TextEditingController text_deposit = TextEditingController();
    Alert(
      context: context,
      type: AlertType.info,
      title: "Deposit some funds",
      style: animation,
      content: Column(
        children: [
          TextField(
            controller: text_deposit,
            decoration: InputDecoration(
              labelText: 'Souls Amount',
            ),
            keyboardType: TextInputType.number,
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
                  onSelected: (bool) => {text_deposit.text = "5000000000000000000"}
              ),
              SizedBox(width:8),
              InputChip(
                  label: Text('1 ETH'),
                  onSelected: (bool) => {text_deposit.text = "1000000000000000000"}
              ),
              SizedBox(width:8),
              InputChip(
                  label: Text('0.5 ETH'),
                  onSelected: (bool) => {text_deposit.text = "500000000000000000"}
              ),
              SizedBox(width:8),
              InputChip(
                  label: Text('0.01 ETH'),
                  onSelected: (bool) => {text_deposit.text = "10000000000000000"}
              ),
            ]
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () => {
            Navigator.pop(context),
            Alert(
              context: context,
              title: "Sending funds...",
              buttons: [],
              style: AlertStyle(
                animationType: AnimationType.grow,
                isCloseButton: false,
                isOverlayTapDismiss: false,
              )
            ).show(),
            Future.delayed(Duration(milliseconds: 500), () => {
              blockchain.query("deposit", [], wei:BigInt.parse(text_deposit.text)).then((value) => {
                Navigator.pop(context),
                Alert(
                  context: context,
                  type: AlertType.success,
                  title: "Funds deposited!",
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
            })
          },
          child: Text(
            "Deposit",
            style: TextStyle(color: Colors.white, fontSize: 20)
          )
        )
      ]
    ).show();
  }

  Future<void> _updateQuorum() async {
    Alert(
        context: context,
        title:"Getting election status...",
        buttons: [],
        style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
          isOverlayTapDismiss: false,
        )
    ).show();
    Future.delayed(Duration(milliseconds:500), () async => {
      blockchain.queryView("get_status", [await blockchain.myAddr()]).then((value) => {
        Navigator.of(context).pop(),
        if (value[3] == false){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Winner()),
          )
        },
        setState(() {
          quorum_text = (value[0] != value[1])
              ? (value[0]-value[1]).toString() + " votes to quorum (" + value[1].toString() + "/" + value[0].toString() + ")"
              : "Quorum reached! (Total voters: "+value[0].toString()+")";
          quorum_circle = (value[1]/value[0]);
          print(value);
          if (value[4]){ //addr is a candidate
            step = 3;
            if (!value[3]) { //elections closed
              step = 4;
            }
          } else if (value[3]){ //elections open
            step = 2;
          } else if (value[1] == value[0]) { //quorum reached
            if (value[2]) { //envelope not open
              step = 1;
            } else { //envelope opened
              step = 2;
            }
          } else { //start
            step = 0;
          }
        })
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

  Color getColor4Step(int _step) {
    if (step == _step) 
      return Colors.purpleAccent;
    return Colors.purple.shade100;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (step > 2){
      body = Steps(
        direction: Axis.vertical,
        size: 20.0,
        path: {'color': Colors.purple.shade100, 'width': 3.0},
        steps: [
          {
            'color': Colors.white,
            'background': getColor4Step(3),
            'label': '1',
            'content': Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Deposit some funds',
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  'You can deposit some souls to encourage people to vote you',
                  style: TextStyle(fontSize: 12.0),
                ),
                SizedBox(height:20.0),
                ElevatedButton(
                  onPressed:
                  (step==3)
                      ? _deposit
                      : null,
                  child: Text("Deposit"),
                )
              ],
            )
          },
          {
            'color': Colors.white,
            'background': getColor4Step(4),
            'label': '2',
            'content': Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Declare the winner',
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  'Once everyone has confirmed their vote you can ask to declare the winner',
                  style: TextStyle(fontSize: 12.0),
                ),
                SizedBox(height:20.0),
                ElevatedButton(
                  onPressed:
                  (step==4)
                      ? _mayorOrSayonara
                      : null,
                  child: Text("Ask to declare"),
                )
              ],
            )
          }
        ],
      );
    } else if (step == -1){
      body = Text("Loading...");
    } else {
      body = Steps(
        direction: Axis.vertical,
        size: 20.0,
        path: {'color': Colors.purple.shade100, 'width': 3.0},
        steps: [
          {
            'color': Colors.white,
            'background': getColor4Step(0),
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
                    onPressed:
                    (step==0)
                        ? () => (
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Vote(isConfirming: false)),
                        )
                    )
                        : null,
                    child: Text("Vote")
                ),
              ],
            ),
          },
          {
            'color': Colors.white,
            'background': getColor4Step(1),
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
                  onPressed:
                  (step==1)
                      ? () => (
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Vote(isConfirming: true)),
                      )
                  )
                      : null,
                  child: Text("Confirm"),
                )
              ],
            )
          },
          {
            'color': Colors.white,
            'background': getColor4Step(2),
            'label': '3',
            'content': Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Declare the winner',
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  'Once everyone has confirmed their vote you can ask to declare the winner',
                  style: TextStyle(fontSize: 12.0),
                ),
                SizedBox(height:20.0),
                ElevatedButton(
                  onPressed:
                  (step==2)
                      ? _mayorOrSayonara
                      : null,
                  child: Text("Ask to declare"),
                )
              ],
            )
          }
        ],
      );
    }
    return Scaffold(
        appBar: PreferredSize(
          child: Container(
            child: AppBar(
              title: Text("Vote4Valadilene"),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        blockchain.logout();
                        setState(() {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SplashScreen()),
                                (Route<dynamic> route) => false,
                          );
                        });
                      },
                      child: Icon(
                        Icons.logout,
                        size: 26.0,
                      ),
                    )
                ),
              ],
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
          preferredSize:  Size(MediaQuery.of(context).size.width, 45),
        ),
        body: Container(
            alignment: Alignment.topCenter,
            child: Column(
              children:[
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: CircularProgressIndicator(
                          value: quorum_circle,
                        ),
                        trailing: ElevatedButton(
                            onPressed: _updateQuorum,
                            child: Text("Update")
                        ),
                        title: Text('$quorum_text'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: body
                )
              ]
            )
          )
        );
  }
}