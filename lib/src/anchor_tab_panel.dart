import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Widget to manage multiple tabs that scroll
class AnchorTabPanel extends StatefulWidget {
  /// Tabs that will move the scroll to the body widget
  final List<Widget> tabs;

  /// Widgets that will be inserted in a scrollable column
  final List<Widget> body;

  /// Duration of the animation that selects the tab
  final Duration animationDuration;

  /// Curve of the animation that selects the tab
  final Curve animationCurve;

  /// Controller for the body scroll
  final ScrollController? scrollController;

  /// Height of the tab bar buttons
  final double tabHeight;

  /// Height for the selected tab button
  final double selectedTabHeight;

  /// Flag that you can put to false to avoid build each time the selected tab changes
  final bool rebuildBody;

  const AnchorTabPanel(
      {required this.tabs,
      required this.body,
      this.animationDuration = const Duration(milliseconds: 1000),
      this.animationCurve = Curves.ease,
      this.scrollController,
      this.rebuildBody = true,
      this.tabHeight = 35,
      this.selectedTabHeight = 40,
      Key? key})
      : assert(tabs.length == body.length),
        super(key: key);

  @override
  _AnchorTabPanelState createState() => _AnchorTabPanelState();
}

class _AnchorTabPanelState extends State<AnchorTabPanel> {
  // Keys of the tab items
  late List<GlobalKey?> keysTabs;

  // Keys of the body items
  late List<GlobalKey?> keysBody;

  // Body widgets
  Widget? bodyWidget;

  // Identify how much percentage of each body widget is visible
  List<double>? visibility;

  // Selected tab
  int selectedTab = 0;

  DateTime ensureVisibleTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    keysTabs = List.generate(widget.tabs.length, (index) => null);

    double screenWidth = MediaQuery.of(context).size.width;

    Widget tabsWidget = createTabsWidget();

    List<Widget> blocks = [];

    // Create the body widgets just once
    // as the set state is just to to control the selected tab
    if (visibility == null ||
        visibility!.length != widget.tabs.length ||
        widget.rebuildBody) {
      visibility = List.generate(widget.tabs.length, (index) => 0);
      keysBody = List.generate(widget.body.length, (index) => null);
      for (int i = 0; i < widget.body.length; i++) {
        Widget widgetMapKey = widget.tabs[i];
        Widget targetWiget = widget.body[i];
        blocks.add(generateBlock(i, widgetMapKey, screenWidth, targetWiget));
      }

      bodyWidget = Expanded(
        child: SingleChildScrollView(
          controller: widget.scrollController ?? ScrollController(),
          child: Column(
            children: blocks,
          ),
        ),
      );
    }

    Column result = Column(
      children: [
        tabsWidget,
        bodyWidget!,
      ],
    );

    return result;
  }

  Widget createTabsWidget() {
    // Create the tabs widget
    List<Widget> tabsItems = [];

    for (int i = 0; i < widget.tabs.length; i++) {
      Widget widgetMapKey = widget.tabs[i];
      GlobalKey tabKey = GlobalKey(debugLabel: 'tab $i');
      keysTabs[i] = tabKey;

      tabsItems.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: [
              MaterialButton(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  key: tabKey,
                  height: selectedTab == i
                      ? widget.selectedTabHeight
                      : widget.tabHeight,
                  color: selectedTab == i
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).cardColor,
                  child: widgetMapKey,
                  onPressed: () {
                    scrollToWidgetWithKey(keysBody[i]!);
                    if (mounted) {
                      setState(() {
                        selectedTab = i;
                      });
                    }
                  }),
            ],
          ),
        ),
      );
    }

    Widget tabsWidget = Container(
      margin: const EdgeInsets.all(5),
      height: widget.selectedTabHeight + 10,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tabsItems,
      ),
    );

    return tabsWidget;
  }

  /// Generate block for the index
  Widget generateBlock(
      int index, Widget widgetMapKey, double screenWidth, Widget targetWidget) {
    final GlobalKey key = GlobalKey(debugLabel: 'block$index');
    keysBody[index] = key;

    return VisibilityDetector(
        key: key,
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          visibility![index] = visiblePercentage;
          int currentIndex = lastVisibleIndex(visibility!);

          bool validIndex = currentIndex >= 0;
          bool changedTab = selectedTab != currentIndex;
          bool isVisible = visiblePercentage > 0;
          if (validIndex && changedTab && isVisible) {
            if (mounted) {
              if (DateTime.now()
                  .isBefore(ensureVisibleTime.add(widget.animationDuration))) {
                return;
              }

              setState(
                () {
                  selectedTab = currentIndex;
                  scrollToWidgetWithKey(keysTabs[currentIndex]!);
                },
              );
            }
          }
        },
        child: targetWidget);
  }

  void scrollToWidgetWithKey(GlobalKey key) {
    if (key.currentContext != null) {
      ensureVisibleTime = DateTime.now();
      Scrollable.ensureVisible(key.currentContext!,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
  }

  static int lastVisibleIndex(List<double> visibility) {
    int lastIndex = -1;

    if (visibility[0] > 0) {
      return 0;
    } else if (visibility[visibility.length - 1] > 0) {
      return visibility.length - 1;
    }

    for (int i = 1; i < visibility.length - 1; i++) {
      if (visibility[i] > 0) {
        return i;
      }
    }

    return lastIndex;
  }
}
