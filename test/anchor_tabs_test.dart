import 'package:anchor_tabs/anchor_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    List<String> tabsText = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];

    List<Widget> tabs = [];
    List<Widget> body = [];

    for (var element in tabsText) {
      // Create a tab item
      tabs.add(Text(element));

      // Create a target item
      body.add(ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          controller: ScrollController(),
          itemCount: 40,
          itemBuilder: (BuildContext ctxt, int i) {
            return Text('$element  $i',
                style: Theme.of(ctxt).textTheme.headline6);
          }));
    }

    final anchorTabPanel = AnchorTabPanel(
      tabs: tabs,
      body: body,
      rebuildBody: true,
    );
  });
}
