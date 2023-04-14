import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef TabBuilder = Widget Function(BuildContext context, int index);
typedef BodyBuilder = Widget Function(BuildContext context, int index);

/// Widget to manage multiple tabs that scroll
class AnchorTabPanelBuilder extends StatefulWidget {
  /// Number of tabs
  final int itemCount;

  /// Tab builder function
  final TabBuilder tabBuilder;

  /// Body builder function
  final BodyBuilder bodyBuilder;

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

  /// Cache extent to control how many widgets to build off-screen
  final double cacheExtent;

  const AnchorTabPanelBuilder({
    required this.itemCount,
    required this.tabBuilder,
    required this.bodyBuilder,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.ease,
    this.scrollController,
    this.rebuildBody = true,
    this.tabHeight = 35,
    this.selectedTabHeight = 40,
    this.cacheExtent = 50.0,
    super.key,
  });

  @override
  _AnchorTabPanelBuilderState createState() => _AnchorTabPanelBuilderState();
}

class _AnchorTabPanelBuilderState extends State<AnchorTabPanelBuilder> {
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
    keysTabs = List.generate(
        widget.itemCount, (index) => GlobalKey(debugLabel: 'tab $index'));

    final double screenWidth = MediaQuery.of(context).size.width;

    final Widget tabsWidget = createTabsWidget();

    final bool visibilityNotInitialized =
        visibility == null || visibility!.length != widget.itemCount;
    final bool rebuildBodyRequested = widget.rebuildBody;

    if (visibilityNotInitialized || rebuildBodyRequested) {
      visibility = List.generate(widget.itemCount, (index) => 0);
      keysBody = List.generate(
          widget.itemCount, (index) => GlobalKey(debugLabel: 'block$index'));

      bodyWidget = Expanded(
        child: ListView.builder(
          itemCount: widget.itemCount,
          itemBuilder: (BuildContext context, int index) {
            final Widget body = widget.bodyBuilder(context, index);
            return generateBlock(index, screenWidth, body);
          },
          controller: widget.scrollController ?? ScrollController(),
          cacheExtent: widget.cacheExtent,
        ),
      );
    }

    final Column result = Column(
      children: [
        tabsWidget,
        bodyWidget!,
      ],
    );

    return result;
  }

  Widget createTabsWidget() {
    // Create the tabs widget
    final List<Widget> tabsItems = [];

    for (int i = 0; i < widget.itemCount; i++) {
      final GlobalKey tabKey = keysTabs[i]!;

      tabsItems.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              MaterialButton(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                key: tabKey,
                height: selectedTab == i
                    ? widget.selectedTabHeight
                    : widget.tabHeight,
                color: selectedTab == i
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).cardColor,
                child: widget.tabBuilder(context, i),
                onPressed: () {
                  scrollToWidgetWithKey(keysBody[i]!);
                  if (mounted) {
                    setState(() {
                      selectedTab = i;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    final Widget tabsWidget = Container(
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
  Widget generateBlock(int index, double screenWidth, Widget targetWidget) {
    final GlobalKey key = GlobalKey(debugLabel: 'block$index');
    keysBody[index] = key;

    return VisibilityDetector(
        key: key,
        onVisibilityChanged: (visibilityInfo) {
          final visiblePercentage = visibilityInfo.visibleFraction * 100;
          visibility![index] = visiblePercentage;
          final int currentIndex = lastVisibleIndex(visibility!);

          final bool validIndex = currentIndex >= 0;
          final bool changedTab = selectedTab != currentIndex;
          final bool isVisible = visiblePercentage > 0;
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
    const int lastIndex = -1;

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
