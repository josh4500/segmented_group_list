# segmented_group_list
The segmented_group_list package provides a robust solution for grouping items into segmented lists with separated headers.
This package allows for sophisticated groupings where each segment is defined by a header, and items within a segment are typically differentiated by a comparator logic.
However, it offers a unique feature that permits certain headers to override the default comparator logic, enabling items with the same header to be grouped together regardless of their underlying differences.

This behavior is controlled via a customizable itemHeadGetter callback, which defines the header for each item. When multiple items share the same header, the comparator logic can be selectively bypassed, facilitating more flexible and intuitive groupings.

## Features

- Segmented Grouping: Organize your Flutter app's data into distinct segments, each with its own header, making it easy to categorize and display grouped information.

- Custom Comparator Logic: Implement custom comparator logic to control how items are differentiated within each segment, offering precise management of item order and grouping.

- Header-Based Grouping Override: Use the itemHeadGetter callback to define headers for items. When items share the same header, the comparator logic can be bypassed, allowing for flexible grouping that suits various use cases.

- Dynamic Segmentation: Automatically adjust groupings in response to changes in item properties or headers, ensuring your UI remains up-to-date with minimal effort.

- Seamless Integration: Designed to integrate smoothly with Flutter projects, this package offers a straightforward API for easy adoption and quick setup.

## Getting started

```agsl
flutter pub add segenemted_group_list
```

## Usage

```dart
class MyDemo extends StatelessWidget {
  const MyDemo({super.key});
  @override
  Widget build(BuildContext context) {
    final groupedTimes = <HistoryItem>[
      ShortHistoryItem(DateTime.now()),
      ShortHistoryItem(DateTime.now()),
      ShortHistoryItem(DateTime.now()),
      ShortHistoryItem(DateTime.now()),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 1))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 1))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 1))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 2))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 3))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 15))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 15))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 15))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 30))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 30))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 30))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 33))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 33))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 300))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 300))),
      VideosHistoryItem(DateTime.now().subtract(const Duration(days: 301))),
    ];
    final historyItems = groupedTimes.group([
      Grouper<ShortHistoryItem>(),
      Grouper<VideosHistoryItem>(),
    ]);
    return DefaultGroupProvider<DateTime>(
      applyHeadSeg: DateHead.month.index,
      buildAsFirst: (DateTime currentDateBuild) {
        final firstGroup = historyItems.first.items;
        return currentDateBuild == firstGroup.first.time;
      },
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: myTabs,
          ),
        ),
        body: CustomScrollView(
          sliver: [
            for (final historyItem in historyItems)
              if (historyItem.type == ShortHistoryItem)
                SliverSingleGroup<DateTime>(
                  item: historyItem.items.first.time,
                  separatorBuilder: (date) => SeparatorWidget(date: date),
                  itemHeadGetter: (DateTime item) => item.asHeader.index,
                  child: const ShortsHistory(),
                )
              else
                SliverGroupList<DateTime>(
                  comparator: (a, b) => !a.compareYMD(b),
                  itemBuilder: (BuildContext context, int index) {
                    return HistoryVideo(
                      index: index,
                      sharedSlidableState: sharedSlidableState,
                      onMore: onMorePlayableVideo,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SeparatorWidget(
                      date: historyItem[index].time,
                    );
                  },
                  itemIndexer: (int index) => historyItem[index].time,
                  childCount: historyItem.length,
                  itemHeadGetter: (DateTime item) => item.asHeader.index,
                ),
          ],
        ),
      ),
    );
  }
}
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
