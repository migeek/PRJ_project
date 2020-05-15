import 'package:flutter/material.dart';

import 'package:simple_permissions/simple_permissions.dart'; // get permissions

import 'package:audio_recorder/audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

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
                  child: new RawMaterialButton(
                    onPressed: () {
                      setState(() async {
                        bool hasPermissions = await AudioRecorder.hasPermissions;
                        bool isRecording = await AudioRecorder.isRecording;
                        // await AudioRecorder.start(path: _controller.text, audioOutputFormat: AudioOutputFormat.mp4);

                        _isRecording = !_isRecording;
                      });
                    },
                    child: _isRecording ? new Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 100.0,
                    ): new Text("REC", style: TextStyle(color: Colors.white, fontSize: 50)),
                    shape: new ContinuousRectangleBorder(),
                    elevation: 2.0,
                    padding: const EdgeInsets.all(70.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                height: MediaQuery.of(context).size.height / 8,
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
                height: MediaQuery.of(context).size.height / 8,
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

class _RecordButtonState extends State<RecordPage> {
  Recording _recordFile;
  bool _isRecording = false;
  String tempFilename = "testFilePlsIgnore";


  File defaultAudioFile;



  stopRecording() async {

    // Await return of Recording object
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;

    // final storage = SharedAudioContext.of(context).storage;
    // Directory docDir = await storage.docDir;
    Directory docDir = await getApplicationDocumentsDirectory();
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
      File tempAudioFile = File(newFilePath+'.m4a');
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Recording."),
        duration: Duration(milliseconds: 1400), ));
      if (await tempAudioFile.exists()){
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        // request permissions to record
        // TODO: find a better place to put this
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
    return (
        new RawMaterialButton(
          onPressed: () {
            setState(() async {
              bool hasPermissions = await AudioRecorder.hasPermissions;
              bool isRecording = await AudioRecorder.isRecording;
              await AudioRecorder.start(path: _controller.text, audioOutputFormat: AudioOutputFormat.mp4);

              _isRecording = !_isRecording;
            });
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
        ))
  }
}