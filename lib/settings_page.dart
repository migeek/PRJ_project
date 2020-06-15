import 'package:flutter/material.dart';
import 'global.dart';

class settings_page extends StatefulWidget {

  settings_page();

  @override
  _settings_pageState createState() => _settings_pageState();
}

class _settings_pageState extends State<settings_page> {
  List<String> entries;

  @override
  Widget build(BuildContext context) {

    entries = DevInfo.ids;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              child: ListTile(
                title: Text("Users' Names:"),

              )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(labelText: "User 1"),
                    onSubmitted: (text){
                      DevInfo.ids[0] = text;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "User 2"),
                    onSubmitted: (text){
                      DevInfo.ids[1] = text;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "User 3"),
                    onSubmitted: (text){
                      DevInfo.ids[2] = text;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "User 4"),
                    onSubmitted: (text){
                      DevInfo.ids[3] = text;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "User 5"),
                    onSubmitted: (text){
                      DevInfo.ids[4] = text;
                    },

                  ),

                ],
              ),

            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: DevInfo.notificationsEnabled,
                  onChanged: (bool value){
                    setState( () {
                      DevInfo.notificationsEnabled = value;
                    });
                  }
                ),
                Text("Notifications"),
              ],
            ),
            Card(
                child: ListTile(
                  title: Text("Device ID: \n\n${DevInfo.devNo}"),

                )
            ),
          ]
        )
      ),
    );

  }
}
