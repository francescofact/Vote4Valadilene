
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/src/utils/length_tracking_byte_sink.dart';
import 'package:convert/convert.dart';

class Blockchain {

  String contractAddr;
  Client httpClient;
  Web3Client ethClient;
  Credentials creds;
  DeployedContract contract;

  Blockchain(){
    SharedPreferences.getInstance().then((prefs) => {
      creds = EthPrivateKey.fromHex(prefs.getString('key')),
      contractAddr = prefs.getString("contract")
    });
    httpClient = new Client();
    String apiUrl = "http://www.francescofattori.it:7545";
    ethClient = new Web3Client(apiUrl, httpClient);
    rootBundle.loadString("assets/abi.json").then((value) => {
      contract = loadContract(value),
      print("Contract: " + contractAddr)
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
      params: args,
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
      prefs.remove('key'),
      prefs.remove('contract')
    });
  }

  Future<EthereumAddress> myAddr() async{
    return creds.extractAddress();
  }

  Uint8List encodeVote(BigInt secret, EthereumAddress addr, BigInt wei) {
    List<dynamic> parameters = [secret,addr, wei];
    AbiType type = TupleType(
      [UintType(),AddressType(), UintType()],
    );
    print(type);
    final sink = LengthTrackingByteSink();

    type.encode(parameters, sink);
    return keccak256(sink.asBytes());

  }
}