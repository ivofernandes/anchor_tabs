import 'package:anchor_tabs/src/anchor_tab_panel.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

typedef TabBuilder = Widget Function(BuildContext context, int index);
typedef BodyBuilder = Widget Function(BuildContext context, int index);

class AnchorTabPanelBuilder extends StatefulWidget {
  /// Number of tabs.
  final int itemCount;

  /// Tab builder function.
  final TabBuilder tabBuilder;

  /// Body builder function.
  final BodyBuilder bodyBuilder;

  /// Duration of the animation that selects the tab.
  final Duration animationDuration;

  /// Curve of the animation that selects the tab.
  final Curve animationCurve;

  /// Height of the tab bar buttons.
  final double tabHeight;

  /// Height for the selected tab button.
  final double selectedTabHeight;

  /// Flag kept for backwards compatibility. Body is lazily built by default.
  final bool rebuildBody;

  /// Extra style customization for tabs.
  final AnchorTabStyle tabStyle;

  const AnchorTabPanelBuilder({
    required this.itemCount,
    required this.tabBuilder,
    required this.bodyBuilder,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.ease,
    this.rebuildBody = true,
    this.tabHeight = 35,
    this.selectedTabHeight = 40,
    this.tabStyle = const AnchorTabStyle(),
    super.key,
  });

  @override
  State<AnchorTabPanelBuilder> createState() => _AnchorTabPanelBuilderState();
}

class _AnchorTabPanelBuilderState extends State<AnchorTabPanelBuilder> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  int _selectedTab = 0;
  DateTime _ensureVisibleTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_syncTabFromScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_syncTabFromScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _createTabsWidget(),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: widget.itemCount,
              itemBuilder: (BuildContext context, int index) => widget.bodyBuilder(context, index),
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
            ),
          ),
        ],
      );

  Widget _createTabsWidget() => Container(
        margin: widget.tabStyle.tabBarMargin,
        height: widget.selectedTabHeight + 10,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.itemCount,
          itemBuilder: (BuildContext context, int i) {
            final bool isSelected = _selectedTab == i;
            final AnchorTabStyle style = widget.tabStyle;

            return Container(
              margin: style.tabMargin,
              child: MaterialButton(
                elevation: style.elevation,
                shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
                padding: style.tabPadding,
                height: isSelected ? widget.selectedTabHeight : widget.tabHeight,
                color: isSelected
                    ? (style.selectedBackgroundColor ?? Theme.of(context).colorScheme.secondary)
                    : (style.unselectedBackgroundColor ?? Theme.of(context).cardColor),
                child: DefaultTextStyle.merge(
                  style: isSelected
                      ? (style.selectedTextStyle ??
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                          ))
                      : (style.unselectedTextStyle ??
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  child: widget.tabBuilder(context, i),
                ),
                onPressed: () {
                  _ensureVisibleTime = DateTime.now();
                  _itemScrollController.scrollTo(
                    index: i,
                    duration: widget.animationDuration,
                    curve: widget.animationCurve,
                  );
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

  void _syncTabFromScroll() {
    if (DateTime.now().isBefore(_ensureVisibleTime.add(widget.animationDuration))) {
      return;
    }

    final Iterable<ItemPosition> positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return;
    }

    final List<ItemPosition> visible = positions.where((ItemPosition p) => p.itemTrailingEdge > 0).toList()
      ..sort((ItemPosition a, ItemPosition b) => a.index.compareTo(b.index));

    if (visible.isEmpty) {
      return;
    }

    final int currentIndex = visible.first.index;
    if (currentIndex != _selectedTab && mounted) {
      setState(() {
        _selectedTab = currentIndex;
      });
    }
  }
}
