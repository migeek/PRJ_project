import 'dart:async';
import 'package:flutter/material.dart';
import 'inbox_page.dart';
class InboxList extends StatelessWidget {
  List<String> entries;
  List<bool> unread;
  Color backgroundColor = Colors.white;
  InboxList(this.entries, this.unread);
  @override
  Widget build(BuildContext context) {

    entries = this.entries;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return inbox_container(entries, unread, index);
            }
        )
    );
  }
}


class inbox_container extends StatefulWidget{
  List<String> entries;
  int index;
  List<bool> unread;
  inbox_container(this.entries, this.unread, this.index);
  @override
  _inbox_containerState createState() => _inbox_containerState(this.entries, this.unread, this.index);
}

class _inbox_containerState extends State<inbox_container> with SingleTickerProviderStateMixin{
  final _animationDuration = Duration(seconds: 1);
  Timer _timer;
  Color _color;
  List<String> entries;
  int index;
  List<bool> unread;
  _inbox_containerState(this.entries, this.unread, this.index);
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_animationDuration, (timer) => _changeColor());
    _color = Colors.red;
  }

  void _changeColor() {
    final newColor = _color == Colors.red ? Colors.green : Colors.red;
    setState(() {
      _color = newColor;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                inbox_page(entries, index)),
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
                  child: AnimatedContainer(
                    duration: _animationDuration,
                    color: unread[index] ? _color : Colors.green,
                    child: Text('PLAY', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
      )

    );
  }

}