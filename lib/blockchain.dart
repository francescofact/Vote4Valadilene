
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

class Blockchain {

  final String contractAddr = "0x4d92A54A0023A44D9909EF3AE7ad3cA74c983371";
  Client httpClient;
  Web3Client ethClient;
  Credentials creds;
  DeployedContract contract;

  Blockchain(){
    httpClient = new Client();
    String apiUrl = "http://www.francescofattori.it:7545";
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

  Future<List<dynamic>> queryView(String fun, List<dynamic> args) async {
    print("Calling blockchain function: " + fun);
    return ethClient.call(
      sender: await creds.extractAddress(),
      contract: contract,
      function: contract.function(fun),
      params: const [],
    );
  }

  Future<void> query(String fun, List<dynamic> args, {BigInt wei}) async {
    if (wei == null)
      wei = BigInt.zero;
    return ethClient.sendTransaction(creds, Transaction.callContract(
      contract: contract,
      function: contract.function(fun),
      parameters: args,
      value: EtherAmount.inWei(wei),
      maxGas: 999999,
    ));
  }

  String translateError(RPCError error){
    String err = error.toString();
    if (err.contains(": revert"))
      return err.split(": revert")[1].replaceAll('".', "");
    if (err.contains("with msg \""))
      return err.split("msg \"")[1].replaceAll('".', "");
    return err;
  }

  Future<bool> check() async{
    //check if connection is available
    try {
      await ethClient.getBlockNumber();
      return true;
    } catch (error){
      return false;
    }
  }

  void logout(){
    SharedPreferences.getInstance().then((prefs) => {
      prefs.remove('key')
    });
  }
}