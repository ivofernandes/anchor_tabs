import 'package:anchor_tabs/anchor_tabs.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Anchor Tabs Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anchor tabs example'),
        actions: [
          IconButton(
            tooltip: 'Builder demo',
            icon: const Icon(Icons.build_rounded),
            onPressed: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<dynamic>(builder: (_) => const BuilderExamplePage()),
            ),
          ),
        ],
      ),
      body: const SimpleExample(),
    );
  }
}

class SimpleExample extends StatelessWidget {
  const SimpleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final List<String> tabsText = <String>['Today', 'Yesterday'];

    for (int i = 2; i < 10; i++) {
      final DateTime pastDate = today.subtract(Duration(days: i));
      tabsText.add('${pastDate.day}/${pastDate.month}');
    }

    final List<Widget> tabs = tabsText
        .map(
          (String text) => Text(
            text,
          ),
        )
        .toList();

    final List<Widget> body = tabsText.map((String dayLabel) => _DaySection(dayLabel: dayLabel)).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simple example with custom style',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnchorTabPanel(
                  tabs: tabs,
                  body: body,
                  selectedTabHeight: 42,
                  tabHeight: 28,
                  tabStyle: AnchorTabStyle(
                    selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                    unselectedBackgroundColor: Theme.of(context).colorScheme.surface,
                    selectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.dayLabel});

  final String dayLabel;

  @override
  Widget build(BuildContext context) => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 20,
      itemBuilder: (BuildContext context, int i) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text('$dayLabel item #$i'),
            subtitle: const Text('Dark mode UI demo entry'),
          ),
        ),
    );
}

class BuilderExamplePage extends StatelessWidget {
  const BuilderExamplePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Builder performance demo'),
        ),
        body: AnchorTabPanelBuilder(
          itemCount: 100,
          tabBuilder: (BuildContext context, int index) => Text('Tab ${index + 1}'),
          bodyBuilder: (BuildContext context, int index) {
            final Color color = index.isEven
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.tertiaryContainer;
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              color: color,
              child: Center(
                child: Text(
                  'Body ${index + 1}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            );
          },
          tabStyle: AnchorTabStyle(
            selectedBackgroundColor: Theme.of(context).colorScheme.secondary,
            selectedTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
            unselectedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            elevation: 0,
          ),
        ),
      );
}
