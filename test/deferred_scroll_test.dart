import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  testWidgets('scrollTo deferred by a transition survives the list going away',
      (tester) async {
    final itemScrollController = ItemScrollController();
    final show = ValueNotifier(true);
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<bool>(
        valueListenable: show,
        builder: (context, visible, _) => visible
            ? ScrollablePositionedList.builder(
                itemCount: 1000,
                itemScrollController: itemScrollController,
                itemBuilder: (context, i) =>
                    SizedBox(height: 40, child: Text('$i')),
              )
            : const SizedBox(),
      ),
    ));

    // a distant target starts a transition
    unawaited(itemScrollController.scrollTo(
        index: 500, duration: const Duration(seconds: 1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // runs on the next frame, after the list is gone
    var done = false;
    unawaited(itemScrollController
        .scrollTo(index: 800, duration: const Duration(seconds: 1))
        .then((_) => done = true));
    show.value = false;
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.pump();
    expect(done, isTrue);
  });
}
