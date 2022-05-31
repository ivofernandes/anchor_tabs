import 'package:anchor_tabs/anchor_tabs.dart';
import 'package:flutter/material.dart';

class MultiScrollExample extends StatelessWidget {
  const MultiScrollExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int columnNumber = 6;
    List<String> tabsText = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];

    List<Widget> tabs = [];
    List<Widget> body = [];

    tabsText.forEach((element) {
      // Create a tab item
      tabs.add(Text(element));

      // Create a target item
      body.add(SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              controller: ScrollController(),
              itemCount: 40,
              itemBuilder: (BuildContext ctxt, int i) {
                List<Widget> columns = [];
                for (int c = 0; c < columnNumber; c++) {
                  columns.add(Text('$element column: $c item: $i ',
                      style: Theme.of(ctxt).textTheme.headline6));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: columns,
                  ),
                );
              })));
    });

    return Scaffold(
        appBar: AppBar(title: Text('Multiple scrolls')),
        body: AnchorTabPanel(tabs: tabs, body: body));
  }
}
