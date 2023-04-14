import 'package:anchor_tabs/anchor_tabs.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.build),
              onPressed: () => Navigator.of(context).push<dynamic>(
                MaterialPageRoute<dynamic>(
                  builder: (context) => TestAnchorTabPanelBuilder(),
                ),
              ),
            ),
            title: const Text('Anchor tabs example'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add,
                ),
                onPressed: () => Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (context) => const MultiScrollExample()),
                ),
              )
            ],
          ),
          body: const SimpleExample(),
        ),
      ));
}

class SimpleExample extends StatelessWidget {
  const SimpleExample({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    final List<String> tabsText = [
      'Today',
      'Yesterday',
    ];

    for (int i = 2; i < 10; i++) {
      final DateTime pastDate = today.subtract(Duration(days: i));
      tabsText.add('${pastDate.day}/${pastDate.month}');
    }

    final List<Widget> tabs = [];
    final List<Widget> body = [];

    for (final element in tabsText) {
      // Create a tab item
      tabs.add(Text(element));

      // Create a target item
      body.add(
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          controller: ScrollController(),
          itemCount: 40,
          itemBuilder: (BuildContext ctxt, int i) => Text(
            '$element  $i',
            style: Theme.of(ctxt).textTheme.headlineSmall,
          ),
        ),
      );
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
  const MultiScrollExample({super.key});

  @override
  Widget build(BuildContext context) {
    const int columnNumber = 6;
    final List<String> tabsTextList = [
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

    final List<Widget> tabs = [];
    final List<Widget> body = [];

    for (final String tabText in tabsTextList) {
      // Create a tab item
      tabs.add(
        Text(tabText),
      );

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
              final List<Widget> columns = [];
              for (int c = 0; c < columnNumber; c++) {
                columns.add(
                  Text(
                    '$tabText column: $c item: $i ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                );
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
      appBar: AppBar(
        title: const Text('Multiple scrolls'),
      ),
      body: AnchorTabPanel(tabs: tabs, body: body),
    );
  }
}

class TestAnchorTabPanelBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Anchor Tab Panel Test'),
        ),
        body: AnchorTabPanelBuilder(
          tabBuilder: (BuildContext context, int index) {
            debugPrint('Tab builder called for index: $index');
            return Text('Tab ${index + 1}');
          },
          bodyBuilder: (BuildContext context, int index) {
            debugPrint('Body builder called for index: $index');
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: index % 2 == 0 ? Colors.orange : Colors.green,
              child: Center(
                child: Text(
                  'Body ${index + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
          itemCount: 100,
          animationDuration: const Duration(milliseconds: 1000),
          animationCurve: Curves.ease,
          tabHeight: 35,
          selectedTabHeight: 40,
        ),
      );
}
