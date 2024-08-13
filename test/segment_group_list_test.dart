import 'package:flutter_test/flutter_test.dart';

import 'package:segment_group_list/segment_group_list.dart';

class TestGroup<T> extends GroupValue<T> {
  updateValueOf(int value) {
    this.value = value;
  }

  updateHeadsOf(int value, int localIndex) {
    heads.add(value);
    indexes.add(localIndex);
  }
}

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
          if (prevOrNextHead < currentHead || prevOrNextHead > currentHead) {
            group.indexes.insert(currentHeadIndex, localIndex);
            attrLocalIndex = localIndex;
          }
        }
      }

      return group.position.isBefore
          ? prevOrNextHead <= currentHead && attrLocalIndex == localIndex
          : prevOrNextHead > currentHead && attrLocalIndex == localIndex;
    } else {
      group.heads
        ..remove(currentHead)
        ..add(currentHead)
        ..sort();
      final headIndex = group.heads.indexOf(currentHead);
      group.indexes[headIndex] = localIndex;
      return true;
    }
  }

  return currentHead != group.value || prevOrNextHead != currentHead;
}

void main() {
  test('Group without applyHeadSeg', () {
    final group = TestGroup<int>();
    group
      ..position = SeparatedPosition.before
      ..buildAsFirst = (item) => item == 0;

    final List<int> sampleHeads = [0, 0, 0, 1, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8];
    int localIndex = 0;
    for (final currentHead in sampleHeads) {
      if (currentHead > group.value) {
        group.updateValueOf(currentHead);
      }

      if (group.heads.isEmpty || currentHead > group.heads.last) {
        group.updateHeadsOf(currentHead, localIndex);
      }
      localIndex++;
    }
    expect(group.value, 8);
    expect(group.heads, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
    expect(group.indexes, [0, 3, 8, 9, 10, 11, 12, 13, 14]);
  });

  final sharedGroup = TestGroup<int>()
    ..applyHeadSeg = 3
    ..position = SeparatedPosition.before
    ..buildAsFirst = (item) => item == 0;

  test('Group with applyHeadSeg', () {
    final sampleItemsWithHeads = [0, 0, 0, 1, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8];
    final childCount = sampleItemsWithHeads.length;
    int localIndex = 0;
    List<int> headsAtIndex = [];

    for (final currentHead in sampleItemsWithHeads) {
      final int currentItem = sampleItemsWithHeads[localIndex];

      final int prevOrNextItem;
      bool lastOrFirstItem = false;

      if (sharedGroup.position.isBefore) {
        if (localIndex <= 0) {
          prevOrNextItem = currentItem;
          lastOrFirstItem = true;
        } else {
          prevOrNextItem = sampleItemsWithHeads[localIndex - 1];
        }
      } else {
        if (localIndex + 1 >= childCount || localIndex <= 0) {
          prevOrNextItem = currentItem;
          lastOrFirstItem = true;
        } else {
          prevOrNextItem = sampleItemsWithHeads[localIndex + 1];
        }
      }

      if (localIndex == 0 && sharedGroup.position.isBefore) {
        expect(lastOrFirstItem, true);
      } else if (localIndex == childCount - 1 &&
          !sharedGroup.position.isBefore) {
        expect(lastOrFirstItem, true);
      }

      final canGroup = lastOrFirstItem ||
          _canGroup<int>(
            prevOrNextItem,
            currentItem,
            sharedGroup,
            (int a, int b) => a < b,
            (int item) => item,
            localIndex,
          );

      if (canGroup) headsAtIndex.add(localIndex);

      if (currentHead > sharedGroup.value) {
        sharedGroup.updateValueOf(currentHead);
      }

      if (sharedGroup.heads.isEmpty || currentHead > sharedGroup.heads.last) {
        sharedGroup.updateHeadsOf(currentHead, localIndex);
      }

      localIndex++;
    }

    expect(sharedGroup.value, 8);
    expect(headsAtIndex, [0, 3, 8, 9, 10, 11, 12, 13, 14]);
    expect(sharedGroup.heads, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
    expect(sharedGroup.indexes, [0, 3, 8, 9, 10, 11, 12, 13, 14]);
  });

  test('Group with applyHeadSeg (in reverse)', () {
    final sampleItemsWithHeads = [0, 0, 0, 1, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8];

    final childCount = sampleItemsWithHeads.length;
    int localIndex = childCount - 1;
    List<int> headsAtIndex = [];

    for (final currentHead in sampleItemsWithHeads) {
      final int currentItem = sampleItemsWithHeads[localIndex];

      final int prevOrNextItem;
      bool lastOrFirstItem = false;

      if (sharedGroup.position.isBefore) {
        if (localIndex <= 0) {
          prevOrNextItem = currentItem;
          lastOrFirstItem = true;
        } else {
          prevOrNextItem = sampleItemsWithHeads[localIndex - 1];
        }
      } else {
        if (localIndex + 1 >= childCount || localIndex <= 0) {
          prevOrNextItem = currentItem;
          lastOrFirstItem = true;
        } else {
          prevOrNextItem = sampleItemsWithHeads[localIndex + 1];
        }
      }

      if (localIndex == 0 && sharedGroup.position.isBefore) {
        expect(lastOrFirstItem, true);
      } else if (localIndex == childCount - 1 &&
          !sharedGroup.position.isBefore) {
        expect(lastOrFirstItem, true);
      }

      final canGroup = lastOrFirstItem ||
          _canGroup<int>(
            prevOrNextItem,
            currentItem,
            sharedGroup,
            (int a, int b) => a < b,
            (int item) => item,
            localIndex,
          );

      if (canGroup) headsAtIndex.insert(0, localIndex);

      if (currentHead > sharedGroup.value) {
        sharedGroup.updateValueOf(currentHead);
      }

      if (sharedGroup.heads.isEmpty || currentHead > sharedGroup.heads.last) {
        sharedGroup.updateHeadsOf(currentHead, localIndex);
      }

      localIndex--;
    }

    expect(sharedGroup.value, 8);
    expect(headsAtIndex, [0, 3, 8, 9, 10, 11, 12, 13, 14]);
    expect(sharedGroup.heads, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
    expect(sharedGroup.indexes, [0, 3, 8, 9, 10, 11, 12, 13, 14]);
  });
}
