library segment_group_list;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

typedef ItemIndexer<E> = E Function(int index);
typedef ItemHeadGetter<E> = int Function(E item);
typedef SeparatorWidgetBuilder<E> = Widget Function(E item);
typedef SeparatorComparator<E> = bool Function(E a, E b);
typedef IndexWidgetBuilder = Widget Function(BuildContext context, int index);
typedef BuildAsFirst<E> = bool Function(E currentItemBuild);

/// Position at which the Separator rendered.
enum SeparatedPosition {
  /// Renders the Separator before a group.
  ///
  /// Example: Notification date separator
  before,

  /// Renders the Separator after a group.
  ///
  /// Example: Messaging date separator
  after;

  /// Whether position is [SeparatedPosition.before]
  bool get isBefore => this == SeparatedPosition.before;
}

class GroupValue<E> {
  int value = 0;

  /// Segment to group multiple sub heads.
  ///
  /// Groups item if placement is in a group with the same head but might
  /// fail comparator.
  ///
  /// Example: Given items of DateTime can be grouped into Today, Yesterday, This week
  /// ,This month ...etc groups. If comparator changes head when item is not the same day
  /// to the next or previous item (depending on the [SeparatorPosition]). This week
  /// and This month groups might have a multiple items with different day but still
  /// needs to be in the correct group.
  ///
  /// See also:
  /// *
  int applyHeadSeg = -1;

  /// Position at which the Separator rendered.
  late SeparatedPosition position;

  /// List of heads available in order of items build
  List<int> heads = [];

  /// Index of heads
  List<int> indexes = [];

  /// Callback to check if item is the first item of the list
  late BuildAsFirst<E> buildAsFirst;
}

/// [GroupValue] provider widget wrapped around child or children GroupList widget
/// [DefaultGroupProvider] is preferred to be use to auto manage [GroupValue]
/// rather than creating a new [GroupValueProvider]
class GroupValueProvider<E> extends InheritedWidget {
  const GroupValueProvider({
    super.key,
    required this.group,
    required super.child,
  });

  final GroupValue<E> group;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static _findAncestorAssertion<E>(GroupValue<E>? ancestor) {
    assert(
      ancestor != null,
      'Ensure to have a GroupValueProvider widget as an ancestor, or use DefaultGroupValue as an ancestor',
    );
  }

  static GroupValue<E>? maybeOf<E>(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<GroupValueProvider<E>>()
        ?.group;
  }

  static GroupValue<E> of<E>(BuildContext context) {
    return maybeOf<E>(context)!;
  }

  static void _updateValueOf<E>(BuildContext context, int value) {
    final group = maybeOf<E>(context);
    _findAncestorAssertion(group);
    group?.value = value;
  }

  static void _updateHeadsOf<E>(BuildContext context, int value, int index) {
    final group = maybeOf<E>(context);
    _findAncestorAssertion(group);
    group?.heads.add(value);
    group?.indexes.add(index);
  }
}

/// The [GroupValueProvider] for descendant widgets that don't specify one
/// explicitly.
///
///
/// [DefaultGroupProvider] is an inherited widget that is used to share a
/// [GroupValue] with multiple GroupList Widget.
///
/// ```dart
/// class MyDemo extends StatelessWidget {
///   const MyDemo({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///   final groupedTimes = <HistoryItem>[
///       ShortHistoryItem(DateTime.now()),
///       ShortHistoryItem(DateTime.now()),
///       ShortHistoryItem(DateTime.now()),
///       ShortHistoryItem(DateTime.now()),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 1))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 1))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 1))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 15))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 15))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 15))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 30))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 30))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 30))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 33))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 33))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 300))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 300))),
///       VideosHistoryItem(DateTime.now().subtract(const Duration(days: 301))),
///     ];
///
///     final historyItems = groupedTimes.group([
///       Grouper<ShortHistoryItem>(),
///       Grouper<VideosHistoryItem>(),
///     ]);
///     return DefaultGroupProvider<DateTime>(
///       applyHeadSeg: DateHead.month.index,
///       buildAsFirst: (DateTime currentDateBuild) {
//           final firstGroup = historyItems.first.items;
//           return currentDateBuild == firstGroup.first.time;
//         },
///       child: Scaffold(
///         appBar: AppBar(
///           bottom: const TabBar(
///             tabs: myTabs,
///           ),
///         ),
///         body: CustomScrollView(
///           sliver: [
///              for (final historyItem in historyItems)
///                 if (historyItem.type == ShortHistoryItem)
///                   SliverSingleGroup<DateTime>(
///                     item: historyItem.items.first.time,
///                     separatorBuilder: (date) => SeparatorWidget(date: date),
///                     itemHeadGetter: (DateTime item) => item.asHeader.index,
///                     child: const ShortsHistory(),
///                   )
///                 else
///                   SliverGroupList<DateTime>(
///                     comparator: (a, b) => !a.compareYMD(b),
///                     itemBuilder: (BuildContext context, int index) {
///                       return HistoryVideo(
///                         index: index,
///                         sharedSlidableState: sharedSlidableState,
///                         onMore: onMorePlayableVideo,
///                       );
///                     },
///                     separatorBuilder: (BuildContext context, int index) {
///                       return SeparatorWidget(
///                         date: historyItem[index].time,
///                       );
///                     },
///                     itemIndexer: (int index) => historyItem[index].time,
///                     childCount: historyItem.length,
///                     itemHeadGetter: (DateTime item) => item.asHeader.index,
///                   ),
///         ],
///       ),
///      ),
///    );
///   }
/// }
/// ```
class DefaultGroupProvider<E> extends StatefulWidget {
  const DefaultGroupProvider({
    super.key,
    this.applyHeadSeg,
    required this.buildAsFirst,
    required this.child,
    this.position = SeparatedPosition.before,
  });

  /// Segment to group multiple sub heads.
  ///
  /// Groups item if placement is in a group with the same head but might
  /// fail comparator.
  ///
  /// Example: Given items of DateTime can be grouped into Today, Yesterday, This week
  /// ,This month ...etc groups. If comparator changes head when item is not the same day
  /// to the next or previous item (depending on the [SeparatorPosition]). This week
  /// and This month groups might have a multiple items with different day but still
  /// needs to be in the correct group.
  ///
  /// See also:
  /// *
  final int? applyHeadSeg;

  /// Position at which the Separator rendered.
  final SeparatedPosition position;

  /// Callback to check if current item is the first item
  final BuildAsFirst<E> buildAsFirst;

  final Widget child;

  @override
  State<DefaultGroupProvider<E>> createState() =>
      _DefaultGroupProviderState<E>();
}

class _DefaultGroupProviderState<E> extends State<DefaultGroupProvider<E>> {
  final GroupValue<E> group = GroupValue<E>();

  @override
  void didUpdateWidget(covariant DefaultGroupProvider<E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      group.indexes.clear();
      group.heads.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GroupValueProvider(
      group: group
        ..position = widget.position
        ..buildAsFirst = widget.buildAsFirst
        ..applyHeadSeg = widget.applyHeadSeg ?? -1,
      child: widget.child,
    );
  }
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

bool _canGroup<E>(
  E prevOrNextItem,
  E currentItem,
  GroupValue<E> group,
  SeparatorComparator<E> comparator,
  ItemHeadGetter<E> itemHeadGetter,
  int localIndex,
) {
  final currentHead = itemHeadGetter(currentItem);
  final prevOrNextHead = itemHeadGetter(prevOrNextItem);

  assert(currentHead >= 0 && prevOrNextHead >= 0, 'Head cannot be less than 0');
  final comparatorResult = comparator(currentItem, prevOrNextItem);
  final applyHeadSeg = group.applyHeadSeg;

  if (currentHead > applyHeadSeg && comparatorResult) {
    return true;
  }

  if (currentHead < group.value && localIndex >= 0) {
    final currentHeadIndex = group.heads.indexOf(currentHead);

    if (currentHeadIndex >= 0) {
      int attrLocalIndex = group.indexes[currentHeadIndex];

      if (localIndex != attrLocalIndex) {
        if (prevOrNextHead < currentHead || prevOrNextHead > currentHead) {
          group.indexes.insert(currentHeadIndex, localIndex);
          attrLocalIndex = localIndex;
        }
      }

      return group.position.isBefore
          ? prevOrNextHead <= currentHead && attrLocalIndex == localIndex
          : prevOrNextHead > currentHead && attrLocalIndex == localIndex;
    } else {
      group.heads
        ..add(currentHead)
        ..sort();
      final headIndex = group.heads.indexOf(currentHead);
      group.indexes.insert(headIndex, localIndex);
      return true;
    }
  }

  return currentHead != group.value || prevOrNextHead != currentHead;
}

Widget _separatorLogicBuilder<E>(
  BuildContext context,
  IndexWidgetBuilder separatorBuilder,
  SeparatorComparator<E> comparator,
  ItemHeadGetter<E> itemHeadGetter,
  ItemIndexer<E> indexer, {
  int localIndex = -1,
  int childCount = 1,
}) {
  final group = GroupValueProvider.of<E>(context);
  final E currentItem = indexer(localIndex);
  final E prevOrNextItem;
  bool lastOrFirstItem = false;

  if (group.position.isBefore) {
    if (localIndex <= 0) {
      prevOrNextItem = currentItem;
      lastOrFirstItem = true;
    } else {
      prevOrNextItem = indexer(localIndex - 1);
    }
  } else {
    if (localIndex + 1 >= childCount || localIndex <= 0) {
      prevOrNextItem = currentItem;
      lastOrFirstItem = true;
    } else {
      prevOrNextItem = indexer(localIndex + 1);
    }
  }

  final currentHead = itemHeadGetter(currentItem);
  assert(currentHead >= 0, 'Head cannot be less than 0');
  final canGroup = lastOrFirstItem ||
      _canGroup(
        prevOrNextItem,
        currentItem,
        group,
        comparator,
        itemHeadGetter,
        localIndex,
      );
  Widget separatorWidget = const SizedBox();

  if (group.buildAsFirst(currentItem) || canGroup) {
    separatorWidget = separatorBuilder(context, localIndex);
  }

  if (currentHead > group.value) {
    GroupValueProvider._updateValueOf<E>(context, currentHead);
  }

  if (group.heads.isEmpty || currentHead > group.heads.last) {
    GroupValueProvider._updateHeadsOf<E>(context, currentHead, localIndex);
  }

  return separatorWidget;
}

/// Single Sliver widget to be grouped with [SliverGroupList]]
/// - [E]: The type of the item to be passed to the separator builder.
class SliverSingleGroup<E> extends StatelessWidget {
  const SliverSingleGroup({
    super.key,
    required this.child,
    required this.separatorBuilder,
    required this.item,
    required this.itemHeadGetter,
  });

  final E item;
  final ItemHeadGetter<E> itemHeadGetter;
  final SeparatorWidgetBuilder<E> separatorBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final separatorWidget = _separatorLogicBuilder<E>(
      context,
      (BuildContext _, int __) => separatorBuilder(item),
      (E _, E __) => false,
      itemHeadGetter,
      (int _) => item,
    );

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [separatorWidget, child],
      ),
    );
  }
}

/// SliverGroupList
///
/// Builds a Sliver with [SliverChildBuilderDelegate]
///
/// - [E]: The type of the item to be passed to the [separatorBuilder], [itemHeadGetter]
/// [comparator] and [itemIndexer].
class SliverGroupList<E> extends StatelessWidget {
  const SliverGroupList({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.itemIndexer,
    required this.comparator,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.findChildIndexCallback,
    this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
    this.semanticIndexOffset = 0,
    required this.childCount,
    required this.itemHeadGetter,
  });

  final int childCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int? Function(Widget, int) semanticIndexCallback;
  final int? Function(Key)? findChildIndexCallback;
  final int semanticIndexOffset;

  /// A callback function that builds the widget for each item in the list based on its index.
  ///
  /// - [context]: The build context for the item.
  /// - [index]: The index of the item in the list.
  final IndexWidgetBuilder itemBuilder;

  /// A callback function that builds the separator widget between items based on the index.
  ///
  /// - [context]: The build context for the separator.
  /// - [index]: The index of the item after which the separator should be placed.
  final IndexWidgetBuilder separatorBuilder;

  /// A function that compares two items of type [E] and determines whether a separator should be shown between them.
  ///
  /// - [a]: The first item in the comparison.
  /// - [b]: The second item in the comparison.
  ///
  /// Returns `true` if a separator should be placed between the two items; otherwise, `false`.
  final SeparatorComparator<E> comparator;

  /// A callback function that retrieves the head or key from an item of type [E].
  /// This head is used in determining where to place separators or other grouping logic.
  ///
  /// - [item]: The item from which to retrieve the head.
  ///
  /// Example:
  /// ```dart
  /// final itemList = <ItemType>[];
  /// int itemHeadGetter(ItemType item){
  ///   return switch(item.datetime){
  ///     isToday => 0,
  ///     isYesterday => 1,
  ///     isThisWeek => 2,
  ///     isThisMonth => 3,
  ///     ...
  ///   };
  /// }
  /// ```
  /// Returns a integer value representing the head of the item, which is used
  /// for head group comparison.
  final ItemHeadGetter<E> itemHeadGetter;

  /// A function that maps an item of type [E] to its index in the list, useful for determining
  /// the position of items and applying the appropriate logic for indexing, separators, or other operations.
  ///
  /// - [item]: The item to be indexed.
  ///
  /// Example:
  /// ```dart
  /// final itemList = <ItemType>[];
  /// ItemType itemIndexer(int index){
  ///   return itemList[index];
  /// }
  /// ```
  ///
  /// Returns the index of the item in the list.
  final ItemIndexer<E> itemIndexer;

  @override
  Widget build(BuildContext context) {
    final group = GroupValueProvider.of<E>(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final localIndex = index ~/ 2;
          if (group.position.isBefore ? index.isEven : index.isOdd) {
            return _separatorLogicBuilder(
              context,
              separatorBuilder,
              comparator,
              itemHeadGetter,
              itemIndexer,
              localIndex: localIndex,
              childCount: childCount,
            );
          }

          return itemBuilder(context, localIndex);
        },
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        findChildIndexCallback: findChildIndexCallback,
        semanticIndexCallback: semanticIndexCallback,
        semanticIndexOffset: semanticIndexOffset,
        childCount: childCount * 2,
      ),
    );
  }
}

/// GroupList
///
/// Uses a [ListView.builder(...)]
///
/// - [E]: The type of the item to be passed to the [separatorBuilder], [itemHeadGetter]
/// [comparator] and [itemIndexer].
class GroupList<E> extends StatelessWidget {
  const GroupList({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.comparator,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    required this.scrollDirection,
    this.controller,
    this.primary,
    this.physics,
    required this.shrinkWrap,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.findChildIndexCallback,
    required this.itemCount,
    this.cacheExtent,
    required this.dragStartBehavior,
    required this.keyboardDismissBehavior,
    this.restorationId,
    required this.clipBehavior,
    this.semanticChildCount,
    required this.itemHeadGetter,
    required this.itemIndexer,
  });

  final Axis scrollDirection;
  final bool reverse = false;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final double? Function(int, SliverLayoutDimensions)? itemExtentBuilder;
  final Widget? prototypeItem;
  final int? Function(Key)? findChildIndexCallback;
  final int itemCount;
  final int? semanticChildCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  /// A callback function that builds the widget for each item in the list based on its index.
  ///
  /// - [context]: The build context for the item.
  /// - [index]: The index of the item in the list.
  final IndexWidgetBuilder itemBuilder;

  /// A callback function that builds the separator widget between items based on the index.
  ///
  /// - [context]: The build context for the separator.
  /// - [index]: The index of the item after which the separator should be placed.
  final IndexWidgetBuilder separatorBuilder;

  /// A function that compares two items of type [E] and determines whether a separator should be shown between them.
  ///
  /// - [a]: The first item in the comparison.
  /// - [b]: The second item in the comparison.
  ///
  /// Returns `true` if a separator should be placed between the two items; otherwise, `false`.
  final SeparatorComparator<E> comparator;

  /// A callback function that retrieves the head or key from an item of type [E].
  /// This head is used in determining where to place separators or other grouping logic.
  ///
  /// - [item]: The item from which to retrieve the head.
  ///
  /// Example:
  /// ```dart
  /// final itemList = <ItemType>[];
  /// int itemHeadGetter(ItemType item){
  ///   return switch(item.datetime){
  ///     isToday => 0,
  ///     isYesterday => 1,
  ///     isThisWeek => 2,
  ///     isThisMonth => 3,
  ///     ...
  ///   };
  /// }
  /// ```
  /// Returns a integer value representing the head of the item, which is used
  /// for head group comparison.
  final ItemHeadGetter<E> itemHeadGetter;

  /// A function that maps an item of type [E] to its index in the list, useful for determining
  /// the position of items and applying the appropriate logic for indexing, separators, or other operations.
  ///
  /// - [item]: The item to be indexed.
  ///
  /// Example:
  /// ```dart
  /// final itemList = <ItemType>[];
  /// ItemType itemIndexer(int index){
  ///   return itemList[index];
  /// }
  /// ```
  ///
  /// Returns the index of the item in the list.
  final ItemIndexer<E> itemIndexer;

  int? get localChildCount => itemCount * 2;

  @override
  Widget build(BuildContext context) {
    final group = GroupValueProvider.of<E>(context);
    return ListView.builder(
      physics: physics,
      padding: padding,
      reverse: reverse,
      primary: primary,
      controller: controller,
      itemExtent: itemExtent,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      restorationId: restorationId,
      scrollDirection: scrollDirection,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      findChildIndexCallback: findChildIndexCallback,
      prototypeItem: prototypeItem,
      keyboardDismissBehavior: keyboardDismissBehavior,
      itemExtentBuilder: itemExtentBuilder,
      dragStartBehavior: dragStartBehavior,
      semanticChildCount: semanticChildCount,
      itemBuilder: (BuildContext context, int index) {
        final localIndex = index ~/ 2;

        if (group.position.isBefore ? index.isEven : index.isOdd) {
          return _separatorLogicBuilder(
            context,
            separatorBuilder,
            comparator,
            itemHeadGetter,
            itemIndexer,
            localIndex: localIndex,
            childCount: itemCount,
          );
        }

        return itemBuilder(context, localIndex);
      },
      itemCount: itemCount,
    );
  }
}
