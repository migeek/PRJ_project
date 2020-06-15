import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import "package:serial_number/serial_number.dart";
import 'package:http/http.dart' as http;
import 'global.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';


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

class _inbox_pageState extends State<inbox_page> {


  List<String> entries;
  int index;
  bool playing = false;
  AudioPlayer audioPlayer = AudioPlayer();
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
  void _playAudio() async{

    Directory docDir = await getApplicationDocumentsDirectory();
    String pathName = p.join(docDir.path, "inbox_audio" + index.toString() + ".mp3");
    print(pathName);
    audioPlayer.play(pathName, isLocal: true);
  }
  void _pauseAudio() async{

    audioPlayer.pause();
  }
  @override
  Widget build(BuildContext context) {
    entries = this.entries;

    return Scaffold(
        appBar: AppBar(
          title: Text('Listen to Message from ${entries[index]}'),
        ),
        body: Column(children: [
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
                  setState((){
                    playing = !playing;
                    // this is where I would put my audio player if I could find
                    // an audio decoder/encoder
                    // todo: get an audio player that works converting mp3 to native AND works for all platforms

                    /*
                    DOES NOT WORK ON IOS ANYMORE!!!!!!
                    _assetsAudioPlayer = AssetsAudioPlayer();
                    _assetsAudioPlayer.open(
                      AssetsAudio(
                        asset: "test_audio.mp3",
                        folder: "/",
                      ),
                    );
                    _assetsAudioPlayer.playOrPause();*/

                    /*
                    has not been updated for flutter 1.12
                    Future loadMusic() async {
                      advancedPlayer = await AudioCache().loop("test_audio.mp3");
                    }*/
                    if (playing){
                      _playAudio();
                    }
                    else{
                      _pauseAudio();
                    }
                  });
                },
                child: playing
                    ? new Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 100.0,
                      )
                    : new Icon(
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

              },
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text("Delete"),
              ),
              shape: new ContinuousRectangleBorder(),
            ),
          )
        ]));
  }
}
