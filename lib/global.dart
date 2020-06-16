// temporary global functions
// hopefully I will remove this in the final version


import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DevInfo{
  static String URI = "http://97.97.187.69:9000/";
  static String myURI = "http://127.0.0.1:5000/";
  static String getSpace = "message";
  static String postSpace = "message";
  static String token = "";
  static List<String> ids = ["change name in settings",
    "change name in settings",
    "change name in settings",
    "change name in settings",
    "change name in settings"];
  static List<String> recvDevNum = ["","","","",""];
  static List<bool> unread = [false, false, false, false, false];
  static String devNo;
  static bool notificationsEnabled = true;
}
Future<int> connectToSocket(context) async{
  var imei = await ImeiPlugin.getImei();
  print(imei);
  var imeiNoDash = imei.replaceAll("-", "");
  DevInfo.devNo = imeiNoDash;
  print(imeiNoDash);

  print("trying to connect");
  SocketIOManager manager = SocketIOManager();
  // SocketOption a = SocketOptions(DevInfo.URI, a);
  SocketIO socket = await manager.createInstance(DevInfo.URI, query: {
    "devNum": DevInfo.devNo
  });
  socket.onConnect((data) {
    print("connected...");
    final snackBar = SnackBar(content: Text('Connected to the server!'));
    Scaffold.of(context).showSnackBar(snackBar);
    print(data);
    // socket.emit("message", ["Hello world!"]);
  });
  socket.on("news", (data) {
    //sample event
    print("news");
    print(data);
  });
  socket.on("wakeUp", (data) async {
    //sample event
    print("wake up!");

    print(data); // JSON with "token" and token
    //jsonDecode(data);
    DevInfo.token = data['token'];

    print("this is our token!: " + DevInfo.token);
    // "table" table ordering (list of tuples device_number, order)
    //toJSON(data);
    var table = data['table'];
    var tableLength = table.length;

    print("table length = " + tableLength.toString());
    for (int i = 0; i < tableLength; i++){
      print("table i:");
      print(table[i]);
      var index = table[i][1];
      print("index: " + index.toString());
      print("devNum: " + table[i][0].toString());
      DevInfo.recvDevNum[index-1] = table[i][0];

    }
    print(DevInfo.recvDevNum);
  });
  socket.on("updateTable", (data) async{
    //sample event
    print("Table has changed!");

    print(data); // JSON with "token" and token
    //jsonDecode(data);
    var tableRoute = "/table";
    var response = await http.get(DevInfo.URI + tableRoute + "?token=${DevInfo.token}&devNum=${DevInfo.devNo}", headers: {"Content-Type": "application/json"});
    print('Response status:  ${response.statusCode}');
    print('Response body: ${response.body}');
    Map<String, dynamic> tableJSON = jsonDecode(response.body);
    print("this is our table!: " + tableJSON["table"]);
    print([0, 1, 2].length);
    var table = tableJSON["table"];
    var tableLength = table.length;

    for (int i = 0; i < tableLength; i++){
      print("table i:");
      print(table[i]);
      var index = table[i][1];
      print("index: " + index.toString());
      print("devNum: " + table[i][0].toString());
      DevInfo.recvDevNum[index-1] = table[i][0];

    }

    // "table" table ordering (list of tuples device_number, order)
    //toJSON(data);
  });
  socket.on("messagesExist", (data) async {

    //sample event
    print("messages exist");
    print(data); // JSON with number of messages waiting
    // todo: find the field that represents the sender


    // we're gonna need to change this
    var response;
    // todo: change max requests to a higher number when I can reliably get packets
    var maxGetRequest = 10;
    var i = 0;
    print("trying to get");


    do {
      response = await http.get(DevInfo.URI + DevInfo.getSpace + "?token=${DevInfo.token}&devNum=${DevInfo.devNo}", headers: {"Content-Type": "application/json"});
      print('Response status:  ${response.statusCode}');
      print('Response body: ${response.body}');
      // todo: uncomment when able to get sender
      if (response.statusCode != 204){
        print("this is clearly a JSON" + response.body);
        Map<String, dynamic> dataJSON = jsonDecode(response.body);
        print("JSONified: " + dataJSON["data"]);
        var bytes = base64.decode(dataJSON["data"]);
        String dir = (await getApplicationDocumentsDirectory()).path;
        print("directory: " + dir);
        File file = File("${dir}/" + "tempFileNameWhileITryToFindAWorkingEncoder.m4a");
        print("the file path: " + "${dir}/" + "tempFileNameWhileITryToFindAWorkingEncoder.m4a");
        await file.writeAsBytes(bytes);

        print("sender: " + dataJSON["sender"]);
        for (int i = 0; i < DevInfo.recvDevNum.length; i++){
          if (DevInfo.recvDevNum[i] == dataJSON["sender"]){
            DevInfo.unread[i] = true;
            var sender = DevInfo.ids[i];
            final snackBar = SnackBar(content: Text('Message received from $sender!'));
            Scaffold.of(context).showSnackBar(snackBar);
            break;
          }
        }

      }
      //print(base64Decode(response.body["data"]));
      //print(jsonDecode(response.body));
      // unread[sender] = true;
      //

      i++;

    } while(response.statusCode != 204 && i < maxGetRequest);

    return 0; // change to the person received from
  });
  socket.onConnectError((data) {
    print(data);
  });
  socket.onConnecting((data) {
    print(data);
  });
  socket.onError((data) {
    print(data);
  });
  socket.onConnectTimeout((data) {
    print("timeout");
    print(data);
  });
  print("hi");
  socket.connect();
}