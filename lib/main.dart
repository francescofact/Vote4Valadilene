import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import 'login.dart';
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
  final candidates = ["0x19226bC2662a4Bb77e9C920cE27D3a3016c9a910", "0x2F11fe2AfEa033Bc56e80e18321ea16F6D65cA02", "0xe39606920F4892D99a3C34E602baF56EaEDCE824"];
  int _selected = -1;

  @override
  void initState(){
    super.initState();
    httpClient = new Client();
    String apiUrl = "http://localhost:7545"; //Replace with your APIvar httpClient = new Client();
    ethClient = new Web3Client(apiUrl, httpClient);
  }

  Future<DeployedContract> loadContract() async{
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddr = "0x82d048c0D39E5e5F33238030920317677Cb60A2e";
    debugPrint("creating deployed");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "Mayor"), EthereumAddress.fromHex(contractAddr));
    debugPrint("created dc");
    return contract;
  }

  Future<List<dynamic>> query(String fun, List<dynamic> args) async {
    debugPrint("Preparing for query");
    final contract = await loadContract();
    debugPrint("creating fun");
    final ethFun = contract.function(fun);

    debugPrint("Querying...");
    final result = await ethClient.call(contract: contract, function: ethFun, params: args);
    return result;
  }

  Future<List<int>> _publishVote() async{
    List<dynamic> args = [BigInt.from(1234),true, BigInt.from(1000000000000000000)];
    print(args);
    List<dynamic> result = await query("cast_envelope", args);
    print(result);
  }

  void _sendVote() async {
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

    _publishVote();
    /*
    ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(candidates[_selected]),
        gasPrice: EtherAmount.inWei(BigInt.one),
        maxGas: 100000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
      ),
    ).then((value) => {
      Alert(
        context: context,
        type: AlertType.success,
        title:"Sent",
        desc: "The vote has been casted!",
        style: animation
      ).show()
    });
    */
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                      "Login"
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
