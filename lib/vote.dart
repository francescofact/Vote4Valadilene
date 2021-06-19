import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:v4v/blockchain.dart';
import 'package:web3dart/json_rpc.dart';

class Vote extends StatefulWidget {
  final bool isConfirming;

  Vote({Key key, @required this.isConfirming}) : super(key: key);

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  Blockchain blockchain = Blockchain();
  AlertStyle animation = AlertStyle(animationType: AnimationType.grow);

  final text_souls = TextEditingController();
  final text_secret = TextEditingController();

  List<dynamic> candidates = [];
  List<dynamic> candidates_locked = [];
  List<dynamic> deposited = [];
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
          value[0].removeWhere((item) => item.toString() == "0x0000000000000000000000000000000000000000");
          value[1].removeWhere((item) => item.toString() == "0x0000000000000000000000000000000000000000");
          value[2].removeWhere((item) => item == BigInt.zero);
          candidates = value[0];
          candidates_locked = value[1];
          deposited = value[2];
        })
      }).catchError((error){
        Navigator.of(context).pop();
        Alert(
            context: context,
            type: AlertType.error,
            title:"Error",
            desc: (error is RPCError)
                ? blockchain.translateError(error)
                : "?"+error.toString()
        ).show();
      })
    });
  }

  bool checkSelection(){
    if (_selected == -1){
      Alert(
          context: context,
          type: AlertType.error,
          title:"Error",
          desc: (widget.isConfirming)
            ? "Please select the major you voted"
            : "Please select the major you want to vote",
          style: animation
      ).show();
      return false;
    }
    return true;
  }

  Future<void> _openVote() async {
    if (!checkSelection())
      return;

    List<dynamic> args = [BigInt.parse(text_secret.text), candidates[_selected]];
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
      blockchain.query("open_envelope", args, wei: BigInt.parse(text_souls.text)).then((value) => {
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

  Future<void> _sendVote() async {
    if (!checkSelection())
      return;

    List<dynamic> args = [blockchain.encodeVote(BigInt.parse(text_secret.text), candidates[_selected], BigInt.parse(text_souls.text))];
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  (widget.isConfirming)
                      ? 'Confirm Previous Vote'
                      : 'Vote The New Major',
                  style: TextStyle(fontSize: 40),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0, bottom: 0.0),
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
                            subtitle: Text(
                                'Deposited: ' + blockchain.soulsUnit(deposited[index])
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 0.0, bottom: 15.0),
                  child: ListView.builder(
                    itemCount: candidates_locked.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey.shade200,
                        child: ListTile(
                          leading: ExcludeSemantics(
                            child: SvgPicture.string(
                              Jdenticon.toSvg("${candidates_locked[index]}"),
                              fit: BoxFit.fill,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          title: Text(
                              "${candidates_locked[index]}",
                              style: TextStyle(color: Colors.black)
                          ),
                          subtitle: Text(
                              'The candidate has not deposited yet'
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(
                    "How many souls?"
                ),
                SizedBox(
                  height:140,
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
                Text(
                    (widget.isConfirming)
                        ? "Enter your secret"
                        : "Create your secret"
                ),
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
                    onPressed:
                    (widget.isConfirming)
                        ? _openVote
                        : _sendVote
                    ,
                    child: Text(
                        (widget.isConfirming)
                            ? "Confirm Vote"
                            : "Send Vote"
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
