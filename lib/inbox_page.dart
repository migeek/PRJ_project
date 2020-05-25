import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/services.dart';
import "package:serial_number/serial_number.dart";
import 'package:imei_plugin/imei_plugin.dart';
// import 'package:flutter_socket_io/flutter_socket_io.dart';
// import 'package:flutter_socket_io/socket_io_manager.dart';


class inbox_page extends StatefulWidget {
  List<String> entries;
  int index;
  Color backgroundColor = Colors.white;
  inbox_page(this.entries, this.index);
  @override
  _inbox_pageState createState() => _inbox_pageState(this.entries, this.index);

}
class _inbox_pageState extends State<inbox_page>{
  String URI = "http://97.97.187.69:9000/";
  String myURI = "http://127.0.0.1:5000/";
  List<String> entries;
  int index;
  bool playing = false;
  _inbox_pageState(this.entries, this.index);
  SocketIO socket;
  /*void _onSocketStatus(dynamic data){
    if (data == 'connect'){
      String jsondata = '{"content": "test"}';
      socket.sendMessage('chat', jsondata);
      socket.subscribe("chat", _onReceiveChatEvent);
    }
  }*/
  /*void _onReceiveChatEvent(dynamic data){
    debugPrint(data);
  }*/
  @override
  Widget build(BuildContext context) {

    entries = this.entries;

    return Scaffold(
        appBar: AppBar(
          title: Text('Listen to Message from ${entries[index]}'),
        ),
        body: Column(

            children: [
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.green,
                ),
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 2,
                  child: new RawMaterialButton(
                    onPressed: () {

                      setState(() {playing = !playing;});
                    },
                    child: playing ? new Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 100.0,
                    ): new Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                    shape: new ContinuousRectangleBorder(),
                    elevation: 2.0,
                    padding: const EdgeInsets.all(70.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                height: MediaQuery.of(context).size.height / 7,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: new RawMaterialButton(
                  onPressed: () async {
                    var imei = await ImeiPlugin.getImei();
                    print(imei);


                    print("trying to connect");
                    SocketIOManager manager = SocketIOManager();
                    SocketIO socket = await manager.createInstance(URI, query: {
                      "devNum": imei
                    }) ;       //TODO change the URI accordingly
                    socket.onConnect((data){
                      print("connected...");
                      print(data);
                      socket.emit("message", ["Hello world!"]);
                    });
                    socket.on("news", (data){   //sample event
                      print("news");
                      print(data);
                    });
                    socket.onConnectError((data) {
                      print(data);
                    });
                    socket.onConnecting((data) {
                      print(data);
                    });
                    socket.onError((data) {print(data);});
                    socket.onConnectTimeout((data) {
                      print("timeout");
                      print(data);
                    });
                    print("hi");
                    socket.connect();

                  },
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text("Delete"),
                  ),
                  shape: new ContinuousRectangleBorder(),
                ),
              )

            ]
        )
    );
  }
}

