// temporary global functions
// hopefully I will remove this in the final version


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:http/http.dart' as http;

class DevInfo{
  static String myURI = "http://97.97.187.69:9000/";
  static String URI = "http://127.0.0.1:5000/";
  static String getSpace = "getMessage";
  static String postSpace = "postMessage";
  static String token = "";
  static List<String> ids = ["", "", "", "", ""];
  static List<bool> unread = [false, false, false, false, false];
}
Future<int> connectToSocket(context) async{
  var imei = await ImeiPlugin.getImei();
  print(imei);
  var imeiNoDash = imei.replaceAll("-", "");
  print(imeiNoDash);

  print("trying to connect");
  SocketIOManager manager = SocketIOManager();
  SocketIO socket = await manager.createInstance(DevInfo.URI, query: {
    "devNum": imeiNoDash
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
  socket.on("wakeUp", (data) {
    //sample event
    print("wake up!");

    print(data); // JSON with "token" and token
    jsonDecode(data);
    DevInfo.token = data['token'];
    // "table" table ordering (list of tuples device_number, order)
    //toJSON(data);
  });
  socket.on("messagesExist", (data) async {
    //sample event
    print("messages exist");
    print(data); // JSON with number of messages waiting
    // todo: find the field that represents the sender
    var sender = "INSERT_SENDER";
    final snackBar = SnackBar(content: Text('Message received from $sender!'));
    Scaffold.of(context).showSnackBar(snackBar);
    // we're gonna need to change this
    var response;
    // todo: change max requests to a higher number when I can reliably get packets
    var maxGetRequest = 10;
    var i = 0;
    response = await http.get(DevInfo.URI + DevInfo.getSpace + "?token=${DevInfo.token}&devNum=$imeiNoDash", headers: {"Content-Type": "application/json"});
    while(response.statusCode != 204 && i < maxGetRequest) {
      response = await http.get(DevInfo.URI + DevInfo.getSpace + "?token=${DevInfo.token}&devNum=$imeiNoDash", headers: {"Content-Type": "application/json"});
      print('Response status:  ${response.statusCode}');
      print('Response body: ${response.body}');
      // todo: uncomment when able to get sender
      // unread[sender] = true;
      i++;

    }

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