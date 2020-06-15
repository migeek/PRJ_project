import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'inbox_list.dart';
import 'record_list.dart';
import 'package:flutter/cupertino.dart';
import 'settings_page.dart';

class Home_Bar extends StatefulWidget {
  Home_Bar();
  @override
  State<StatefulWidget> createState() {
    return _Home_Bar_State();
  }
}

// _ in front of a class name indicates that it is private
class _Home_Bar_State extends State<Home_Bar> {

  // static List<String> entries = <String>['A', 'B', 'C','D','E'];

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,

        child: CupertinoTabScaffold(

          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.mail_solid),
                title: Text('Inbox'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.mic),
                title: Text('Record'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings_solid),
                title: Text('Settings'),
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            assert(index >= 0 && index <= 2);
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return InboxList();
                  },
                  defaultTitle: 'Colors',
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return record_page();
                  },
                  defaultTitle: 'Support Chat',
                );
                break;
              case 2:
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    return settings_page();
                  },
                  defaultTitle: 'Account',
                );
                break;
            }
            return null;
          },
      ),
    );
  }


}