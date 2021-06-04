import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Client httpClient;
  Web3Client ethClient;
  Credentials creds;
  DeployedContract contract;

  String contractAddr = "0x18Bca6d0e0755B4575fe4F6746F540bd9De867B5";
  final candidates = ["0x19226bC2662a4Bb77e9C920cE27D3a3016c9a910", "0x2F11fe2AfEa033Bc56e80e18321ea16F6D65cA02", "0xe39606920F4892D99a3C34E602baF56EaEDCE824"];
  int _selected = -1;

  @override
  void initState(){
    super.initState();
    httpClient = new Client();
    String apiUrl = "http://localhost:7545"; //Replace with your APIvar httpClient = new Client();
    ethClient = new Web3Client(apiUrl, httpClient);

    rootBundle.loadString("assets/abi.json").then((value) => {
      contract = loadContract(value)
    });

    SharedPreferences.getInstance().then((prefs) => {
      creds = EthPrivateKey.fromHex(prefs.getString('key'))
    });
  }

  DeployedContract loadContract(String abi){
    final contract = DeployedContract(ContractAbi.fromJson(abi, "Mayor"), EthereumAddress.fromHex(contractAddr));
    return contract;
  }

  Future<void> query(String fun, List<dynamic> args, {int wei=0}) async {
    return ethClient.sendTransaction(creds, Transaction.callContract(
      contract: contract,
      function: contract.function(fun),
      parameters: args,
      value: EtherAmount.inWei(BigInt.from(wei)),
      maxGas: 999999,
    ));
  }

  Future<List<int>> _openVote() async{
    List<dynamic> args = [BigInt.from(1234),true];

    try {
      await query("open_envelope", args, wei:1000000000000000000);
      Alert(
          context: context,
          type: AlertType.success,
          title:"Voted",
          desc: "Your Vote has been "
      ).show();
    } catch (error) {
      Alert(
          context: context,
          type: AlertType.error,
          title:"Error",
          desc: error.toString()
      ).show();
    }

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

    List<dynamic> args = [BigInt.from(1234), true, BigInt.from(1000000000000000000)];
    try {
      await query("cast_envelope", args);
      Alert(
          context: context,
          type: AlertType.success,
          title:"OK",
          desc: "Your vote has been casted!"
      ).show();
    } catch(error) {
      Alert(
          context: context,
          type: AlertType.error,
          title:"Error",
          desc: error.toString()
      ).show();
    }

  }

  void loader(AnimationController controller, Function f) async{
    controller.forward();
    await f();
    controller.reset();
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
              ElevatedButton(
                  onPressed: _openVote,
                  child: Text(
                      "Open"
                  )
              ),
              ProgressButton(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                strokeWidth: 2,
                child: Text(
                  "Vote",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                onPressed: (AnimationController controller) async {
                  await loader(controller, _sendVote);
                }
              )
            ],
          ),
        ),
      ),
    );

  }
}
