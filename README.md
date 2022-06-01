This project is a way to implement a anchor tabs panel like the one of the rhymit.

The idea is that sometimes you have a big list where you can scroll, 
but you still want buttons to help the user to navigate to different scroll positions, and also want that the selected button keeps updated as you scroll

![Anchor tabs demo](https://raw.githubusercontent.com/ivofernandes/anchor_tabs/master/doc/usage_example.gif?raw=true)

## Features
Tab button scroll to the block
Scrolling will update the tab button selected

## Getting started


Add the dependency to your `pubspec.yaml`:
```
anchor_tabs: ^0.0.1
```

## Usage
```dart
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
          Expanded(child: AnchorTabPanel(tabs: tabs, body: body)),
        ],
      ),
    );
  }
}

```

## Additional information
This AnchorTabPanel widget have more fields like the one to configure the size of the tab buttons

## Like us on pub.dev
Package url:
https://pub.dev/packages/anchor_tabs


## Contribute on github
If you have some problem that this package doesn't solve feel free to contribute on github
https://github.com/ivofernandes/anchor_tabs

## Instruction to publish the package to pub.dev
dart pub publish