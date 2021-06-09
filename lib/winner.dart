import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:v4v/blockchain.dart';

class Winner extends StatefulWidget {
  @override
  _WinnerState createState() => _WinnerState();
}

class _WinnerState extends State<Winner> {
  Blockchain blockchain = Blockchain();

  ConfettiController _controllerCenter;
  List<dynamic> candidates = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateCandidates());
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
  }

  Future<void> _updateCandidates() async {
    Alert(
        context: context,
        title:"Getting results...",
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
        }),
        _controllerCenter.play(),
        Future.delayed(Duration(seconds:5),() => {
          _controllerCenter.stop()
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
      body: Stack(
        children: [
          Center(
            child: Container(
            margin: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: <Widget>[
                Card(
                  color: Colors.yellow,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Text(
                            "👑",
                            style: TextStyle(fontSize: 25)
                        ),
                        trailing: SvgPicture.string(
                          Jdenticon.toSvg("1234"),
                          fit: BoxFit.fill,
                          height: 50,
                          width: 50,
                        ),
                        title: Text('0xeAD2a43342D0198563931F90E9762A8A43F14fc4'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height:15
                ),
                Text(
                    "Ranked List",
                    style: TextStyle(fontSize: 40)
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: ListView.builder(
                    itemCount: candidates.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
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
                              style: TextStyle(color: Colors.black)
                          ),
                          subtitle: Text('🪙 Souls: 3,5ETH  •  🗳 Votes: 12'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop:
              true, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      )
    );

  }
}
