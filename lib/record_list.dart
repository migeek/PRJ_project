import 'package:flutter/material.dart';
import 'record_page.dart';
class record_page extends StatelessWidget {
  List<String> entries;
  Color backgroundColor = Colors.white;
  record_page(this.entries);
  @override
  Widget build(BuildContext context) {

    entries = this.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      RecordPage(entries, index)),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black)
                ),
                height: 50,
                //color: Colors.black,
                alignment: Alignment(-0.90, 0.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.contain,
                          child: Text('${entries[index]}', textAlign: TextAlign.left,style: TextStyle(
                              color: Colors.black.withOpacity(1.0)),
                          ),
                        )
                    ),
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.contain, // otherwise the logo will be tiny
                        child: Container(
                          color: Colors.red,
                          child: Text(
                            'REC', style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          );
        }
      )
    );
  }
}
