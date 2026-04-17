import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Styling options for the tab bar buttons.
class AnchorTabStyle {
  const AnchorTabStyle({
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.elevation = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.tabMargin = const EdgeInsets.symmetric(horizontal: 5),
    this.tabBarMargin = const EdgeInsets.all(5),
  });

  /// Background color for selected tab. Falls back to theme secondary.
  final Color? selectedBackgroundColor;

  /// Background color for non selected tab. Falls back to card color.
  final Color? unselectedBackgroundColor;

  /// Text style for selected tab labels.
  ///
  /// Defaults to `onSecondary` color with semi-bold weight.
  final TextStyle? selectedTextStyle;

  /// Text style for non-selected tab labels.
  ///
  /// Defaults to `onSurfaceVariant` color.
  final TextStyle? unselectedTextStyle;

  /// Elevation for tab buttons.
  final double elevation;

  /// Shape used by tab buttons.
  final BorderRadius borderRadius;

  /// Inner padding of tab buttons.
  final EdgeInsets tabPadding;

  /// Margin applied to each tab item.
  final EdgeInsets tabMargin;

  /// Margin applied to the full horizontal list.
  final EdgeInsets tabBarMargin;
}

/// Widget to manage multiple tabs that scroll.
class AnchorTabPanel extends StatefulWidget {
  /// Tabs that will move the scroll to the body widget.
  final List<Widget> tabs;

  /// Widgets that will be inserted in a scrollable column.
  final List<Widget> body;

  /// Duration of the animation that selects the tab.
  final Duration animationDuration;

  /// Curve of the animation that selects the tab.
  final Curve animationCurve;

  /// Controller for the body scroll.
  final ScrollController? scrollController;

  /// Height of the tab bar buttons.
  final double tabHeight;

  /// Height for the selected tab button.
  final double selectedTabHeight;

  /// Flag that you can put to false to avoid build each time the selected tab changes.
  final bool rebuildBody;

  /// Extra style customization for tabs.
  final AnchorTabStyle tabStyle;

  const AnchorTabPanel({
    required this.tabs,
    required this.body,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.ease,
    this.scrollController,
    this.rebuildBody = true,
    this.tabHeight = 35,
    this.selectedTabHeight = 40,
    this.tabStyle = const AnchorTabStyle(),
    super.key,
  }) : assert(tabs.length == body.length);

  @override
  State<AnchorTabPanel> createState() => _AnchorTabPanelState();
}

class _AnchorTabPanelState extends State<AnchorTabPanel> {
  late final ScrollController _internalScrollController;
  late List<GlobalKey> _tabKeys;
  late List<GlobalKey> _bodyKeys;
  List<double>? _visibility;
  Widget? _bodyWidget;
  int _selectedTab = 0;
  DateTime _ensureVisibleTime = DateTime.now();

  ScrollController get _effectiveScrollController =>
      widget.scrollController ?? _internalScrollController;

  @override
  void initState() {
    super.initState();
    _internalScrollController = ScrollController();
    _initKeys();
  }

  @override
  void didUpdateWidget(covariant AnchorTabPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tabs.length != widget.tabs.length ||
        oldWidget.body.length != widget.body.length) {
      _initKeys();
      _visibility = null;
      _bodyWidget = null;
      _selectedTab = 0;
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget tabsWidget = _createTabsWidget();

    final bool needsBuild =
        _visibility == null || _visibility!.length != widget.tabs.length || widget.rebuildBody;

    if (needsBuild) {
      _visibility = List<double>.filled(widget.tabs.length, 0);
      _bodyWidget = Expanded(
        child: SingleChildScrollView(
          controller: _effectiveScrollController,
          child: Column(
            children: List<Widget>.generate(
              widget.body.length,
              (int i) => _generateBlock(i, widget.body[i]),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        tabsWidget,
        _bodyWidget!,
      ],
    );
  }

  void _initKeys() {
    _tabKeys = List<GlobalKey>.generate(
      widget.tabs.length,
      (int index) => GlobalKey(debugLabel: 'tab $index'),
    );
    _bodyKeys = List<GlobalKey>.generate(
      widget.body.length,
      (int index) => GlobalKey(debugLabel: 'block$index'),
    );
  }

  Widget _createTabsWidget() => Container(
        margin: widget.tabStyle.tabBarMargin,
        height: widget.selectedTabHeight + 10,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.tabs.length,
          itemBuilder: (BuildContext context, int i) {
            final bool isSelected = _selectedTab == i;
            final AnchorTabStyle style = widget.tabStyle;

            return Container(
              margin: style.tabMargin,
              child: MaterialButton(
                elevation: style.elevation,
                shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
                key: _tabKeys[i],
                padding: style.tabPadding,
                height: isSelected ? widget.selectedTabHeight : widget.tabHeight,
                color: isSelected
                    ? (style.selectedBackgroundColor ?? Theme.of(context).colorScheme.secondary)
                    : (style.unselectedBackgroundColor ?? Theme.of(context).cardColor),
                child: DefaultTextStyle.merge(
                  style: isSelected
                      ? (style.selectedTextStyle ??
                          TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ))
                      : (style.unselectedTextStyle ??
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  child: widget.tabs[i],
                ),
                onPressed: () {
                  _scrollToWidgetWithKey(_bodyKeys[i]);
                  if (mounted) {
                    setState(() {
                      _selectedTab = i;
                    });
                  }
                },
              ),
            );
          },
        ),
      );

  Widget _generateBlock(int index, Widget targetWidget) => VisibilityDetector(
        key: _bodyKeys[index],
        onVisibilityChanged: (VisibilityInfo visibilityInfo) {
          final double visiblePercentage = visibilityInfo.visibleFraction * 100;
          _visibility![index] = visiblePercentage;
          final int currentIndex = lastVisibleIndex(_visibility!);

          final bool validIndex = currentIndex >= 0;
          final bool changedTab = _selectedTab != currentIndex;
          final bool isVisible = visiblePercentage > 0;
          if (validIndex && changedTab && isVisible && mounted) {
            if (DateTime.now().isBefore(_ensureVisibleTime.add(widget.animationDuration))) {
              return;
            }

            setState(() {
              _selectedTab = currentIndex;
              _scrollToWidgetWithKey(_tabKeys[currentIndex]);
            });
          }
        },
        child: targetWidget,
      );

  void _scrollToWidgetWithKey(GlobalKey key) {
    if (key.currentContext != null) {
      _ensureVisibleTime = DateTime.now();
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
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
