import 'package:anchor_tabs/anchor_tabs.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Anchor tabs example'),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MultiScrollExample();
                    }),
                  ),
                )
              ],
            ),
            body: const SimpleExample(),
          ),
        ));
  }
}

class SimpleExample extends StatelessWidget {
  const SimpleExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text('Simple example of anchor tabs'),
          Expanded(
              child: AnchorTabPanel(
            tabs: tabs,
            body: body,
          )),
        ],
      ),
    );
  }
}

class MultiScrollExample extends StatelessWidget {
  const MultiScrollExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int columnNumber = 6;
    List<String> tabsTextList = [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j'
    ];

    List<Widget> tabs = [];
    List<Widget> body = [];

    for (String tabText in tabsTextList) {
      // Create a tab item
      tabs.add(Text(tabText));

      // Create a target item
      body.add(
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            controller: ScrollController(),
            itemCount: 40,
            itemBuilder: (_, int i) {
              List<Widget> columns = [];
              for (int c = 0; c < columnNumber; c++) {
                columns.add(Text('$tabText column: $c item: $i ',
                    style: Theme.of(context).textTheme.headline6));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: columns,
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(title: Text('Multiple scrolls')),
        body: AnchorTabPanel(tabs: tabs, body: body));
  }
}
