import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:simple_permissions/simple_permissions.dart'; // get permissions

import 'package:audio_recorder/audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:imei_plugin/imei_plugin.dart';

import 'dart:convert';
import 'dart:core';
// import 'dart:utf';
import 'dart:io' show Platform;

import 'package:path/path.dart' as p;
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'temp_global.dart';

class RecordPage extends StatefulWidget {
  List<String> entries;
  int index;
  Color backgroundColor = Colors.white;
  RecordPage(this.entries, this.index);
  @override
  _RecordPageState createState() => _RecordPageState(this.entries, this.index);

}
class _RecordPageState extends State<RecordPage>{
  List<String> entries;
  int index;
  _RecordPageState(this.entries, this.index);

  @override
  Widget build(BuildContext context) {

    entries = this.entries;

    return Scaffold(
        appBar: AppBar(
          title: Text('Record Message for ${entries[index]}'),
        ),
        body: Column(

            children: [
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.red,
                ),
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 2,
                  // TODO: place button in futureBuilder
                  child: new RecordButton(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                height: MediaQuery.of(context).size.height / 9,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: new RawMaterialButton(
                  onPressed: () {},
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text("Send"),
                  ),
                  shape: new ContinuousRectangleBorder(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                height: MediaQuery.of(context).size.height / 9,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: new RawMaterialButton(
                  onPressed: () {},
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


class RecordButton extends StatefulWidget{
  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  Recording _recordFile;
  bool _isRecording = false;
  String tempFilename = "tempFilePlsIgnore";


  File defaultAudioFile;



  stopRecording() async {

    // Await return of Recording object
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;
    Directory docDir = await getApplicationDocumentsDirectory();
    // final storage = SharedAudioContext.of(context).storage;
    // Directory docDir = await storage.docDir;

    // file conversion
    /*String inputFile = p.join(docDir.path, this.tempFilename+'.m4a');
    String outputFile = p.join(docDir.path, this.tempFilename+'.mp3');
    await flutterSoundHelper.convertFile(inputFile, Codec.aacMP4, outputFile, Codec.mp3);*/

    //attempt 2

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    String inputFile = p.join(docDir.path, this.tempFilename);
    /*
    // _flutterFFmpeg.execute("-encoders").then((rc) => print("FFmpeg process exited with rc $rc"));
    if (Platform.isAndroid) {
      // Android-specific code
      // _flutterFFmpeg.execute("-i ${inputFile}.m4a filename.mp3").then((rc) => print("FFmpeg process exited with rc $rc"));
      // todo: check to see if this encoder will work
      _flutterFFmpeg.execute("-i ${inputFile}.mp4 -ab 128k -ac 2 -ar 44100 filename.mp3").then((rc) => print("FFmpeg process exited with rc $rc"));


    } else if (Platform.isIOS) {
      // iOS-specific code
      _flutterFFmpeg.execute("-i ${inputFile}.m4a -acodec lame filename.mp3").then((rc) => print("FFmpeg process exited with rc $rc"));
    }
    */




    // TODO: put network stuff here
    String url = "";
    String URI = DevInfo.URI;
    String nameSpace = "postMessage";
    // var req = http.MultipartRequest('POST', Uri.parse(url));
    String tempToken = DevInfo.token;
    String tempReceiver = "2C9737C04DF14814AEA5BFF7086EF99D";
    var imei = await ImeiPlugin.getImei();
    String devNum = await imei.replaceAll("-", "");
    /*var request = http.MultipartRequest('POST', Uri.parse(URI + nameSpace));
    request.files.add(
        await http.MultipartFile.fromPath(
            'data',
            inputFile + ".m4a"
        )
    );
    request.fields["token"] = tempToken;
    request.fields["devNum"] = devNum;
    request.fields["receiver"] = tempReceiver;
    request.fields["keys"] = "test1234566";
    request.fields["key2"] = "1234test";
    var res = await request.send();
    print("result: " + res.toString());*/
    var bdata = new ByteData(8);
    bdata.setFloat32(0, 3.04);
    var e = new Utf8Codec();
    var test1234 = File(inputFile + ".m4a").readAsBytesSync();
    print(test1234);
    var response = await http.post(URI + nameSpace, headers: {"Content-Type": "application/json"}, body: jsonEncode({'token': tempToken,'devNum': devNum,'receiver': tempReceiver,'data': e.encode('Lorem ipsum dolor sit amet, consetetur...')}));
    print('Response status:  ${response.statusCode}');
    print('Response body: ${response.body}');
    // print(awa)



    String newFilePath = p.join(docDir.path, this.tempFilename);

    //tempAudioFile.delete();

    setState(() {
      //Tells flutter to rerun the build method
      _isRecording = isRecording;
      // _doQuerySave = true;
      defaultAudioFile = File(p.join(docDir.path, this.tempFilename+'.m4a'));
    });
  }


  startRecording() async {
    try {
      //final storage = SharedAudioContext.of(context).storage;
      //Directory docDir = await storage.docDir;
      Directory docDir = await getApplicationDocumentsDirectory();
      String newFilePath = p.join(docDir.path, this.tempFilename);
      print("hi: " + newFilePath);
      File tempAudioFile = File(newFilePath+'.m4a');
      if (await tempAudioFile.exists()){
        print("file already found");
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        // request permissions to record

        requestPermissions();

        // Uncomment if you want to show an error message
        // Scaffold.of(context).showSnackBar(new SnackBar(
        //     content: new Text("Error! Audio recorder lacks permissions.")));
      }
      bool isRecording = await AudioRecorder.isRecording;
      setState(() {
        //Tells flutter to rerun the build method
        _recordFile = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });
    } catch (e) {
      print("lol");
      print(e);
    }
  }


  requestPermissions() async {
    bool audioRes =
        await SimplePermissions.requestPermission(Permission.RecordAudio) == PermissionStatus.authorized;
    bool readRes = await SimplePermissions
        .requestPermission(Permission.ReadExternalStorage) == PermissionStatus.authorized;
    bool writeRes = await SimplePermissions
        .requestPermission(Permission.WriteExternalStorage) == PermissionStatus.authorized;
    return (audioRes && readRes && writeRes);
  }
  @override
  Widget build(BuildContext context) {
    // Check if the AudioRecorder is currently recording before building the rest of the Page
    // If we do not check this,
    return FutureBuilder<bool>(
        future: AudioRecorder.isRecording,
        builder: recordButtonBuilder
    );
  }


  Widget recordButtonBuilder(BuildContext context, AsyncSnapshot snapshot) {
    return (
        new RawMaterialButton(
          onPressed: () {
            _isRecording
              ? stopRecording()
              : startRecording();
          },
          child: _isRecording ? new Icon(
            Icons.stop,
            color: Colors.white,
            size: 100.0,
          ) : new Text(
              "REC", style: TextStyle(color: Colors.white, fontSize: 50)),
          shape: new ContinuousRectangleBorder(),
          elevation: 2.0,
          padding: const EdgeInsets.all(70.0),
        )
    );
  }
}