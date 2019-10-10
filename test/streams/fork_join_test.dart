import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> get streamA =>
    Stream<int>.periodic(const Duration(milliseconds: 1), (int count) => count)
        .take(3);

Stream<int> get streamB => Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

Stream<bool> get streamC {
  final controller = StreamController<bool>()
    ..add(true)
    ..close();

  return controller.stream;
}

void main() {
  test('rx.Observable.forkJoinList', () async {
    final combined = ForkJoinStream.list<int>([
      Stream.fromIterable([1, 2, 3]),
      Observable.just(2),
      Observable.just(3),
    ]);

    await expectLater(
      combined,
      emitsInOrder(<dynamic>[
        [3, 2, 3],
        emitsDone
      ]),
    );
  });

  test('rx.Observable.forkJoinList.singleStream', () async {
    final combined = ForkJoinStream.list<int>([
      Stream.fromIterable([1, 2, 3])
    ]);

    await expectLater(
      combined,
      emitsInOrder(<dynamic>[
        [3],
        emitsDone
      ]),
    );
  });

  test('rx.Observable.forkJoin', () async {
    final combined = ForkJoinStream<int, int>(
      [
        Stream.fromIterable([1, 2, 3]),
        Observable.just(2),
        Observable.just(3),
      ],
      (values) => values.fold(0, (acc, val) => acc + val),
    );

    await expectLater(
      combined,
      emitsInOrder(<dynamic>[8, emitsDone]),
    );
  });

  test('rx.ForkJoinStream.combine3', () async {
    final observable = ForkJoinStream.combine3(
        streamA,
        streamB,
        streamC,
        (int a_value, int b_value, bool c_value) =>
            '$a_value $b_value $c_value');

    await expectLater(
        observable, emitsInOrder(<dynamic>['2 4 true', emitsDone]));
  });

  test('rx.ForkJoinStream.combine3.single.subscription', () async {
    final observable = ForkJoinStream.combine3(
        streamA,
        streamB,
        streamC,
        (int a_value, int b_value, bool c_value) =>
            '$a_value $b_value $c_value');

    await expectLater(
      observable,
      emitsInOrder(<dynamic>['2 4 true', emitsDone]),
    );
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.ForkJoinStream.combine2', () async {
    var a = Stream.fromIterable(const [1, 2]), b = Observable.just(2);

    final observable = ForkJoinStream.combine2(
        a, b, (int first, int second) => [first, second]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          [2, 2],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine2.throws', () async {
    var a = Observable.just(1), b = Observable.just(2);

    final observable = ForkJoinStream.combine2(a, b, (int first, int second) {
      throw Exception();
    });

    observable.listen(null, onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.ForkJoinStream.combine3', () async {
    var a = Observable.just(1),
        b = Observable.just("2"),
        c = Observable.just(3.0);

    final observable = ForkJoinStream.combine3(a, b, c,
        (int first, String second, double third) => [first, second, third]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, "2", 3.0],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine4', () async {
    var a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4);

    final observable = ForkJoinStream.combine4(
        a,
        b,
        c,
        d,
        (int first, int second, int third, int fourth) =>
            [first, second, third, fourth]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, 2, 3, 4],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine5', () async {
    var a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5);

    final observable = ForkJoinStream.combine5(
        a,
        b,
        c,
        d,
        e,
        (int first, int second, int third, int fourth, int fifth) =>
            <int>[first, second, third, fourth, fifth]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, 2, 3, 4, 5],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine6', () async {
    var a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6);

    Stream<List<int>> observable = ForkJoinStream.combine6(
        a,
        b,
        c,
        d,
        e,
        f,
        (int first, int second, int third, int fourth, int fifth, int sixth) =>
            [first, second, third, fourth, fifth, sixth]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, 2, 3, 4, 5, 6],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine7', () async {
    var a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6),
        g = Observable.just(7);

    final observable = ForkJoinStream.combine7(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh) =>
            [first, second, third, fourth, fifth, sixth, seventh]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, 2, 3, 4, 5, 6, 7],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine8', () async {
    var a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6),
        g = Observable.just(7),
        h = Observable.just(8);

    final observable = ForkJoinStream.combine8(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh, int eighth) =>
            [first, second, third, fourth, fifth, sixth, seventh, eighth]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, 2, 3, 4, 5, 6, 7, 8],
          emitsDone
        ]));
  });

  test('rx.ForkJoinStream.combine9', () async {
    var a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6),
        g = Observable.just(7),
        h = Observable.just(8),
        i = Observable.just(9);

    final observable = ForkJoinStream.combine9(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh, int eighth, int ninth) =>
            [
              first,
              second,
              third,
              fourth,
              fifth,
              sixth,
              seventh,
              eighth,
              ninth
            ]);

    await expectLater(
        observable,
        emitsInOrder(<dynamic>[
          const [1, 2, 3, 4, 5, 6, 7, 8, 9],
          emitsDone
        ]));
  });

  test('rx.Observable.forkJoin.asBroadcastStream', () async {
    final observable = ForkJoinStream.combine3(
        streamA,
        streamB,
        streamC,
        (int a_value, int b_value, bool c_value) =>
            '$a_value $b_value $c_value').asBroadcastStream();

// listen twice on same stream
    observable.listen(null);
    observable.listen(null);
// code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.forkJoin.error.shouldThrowA', () async {
    final observableWithError = ForkJoinStream.combine4(
        Observable.just(1),
        Observable.just(1),
        Observable.just(1),
        Stream<int>.error(Exception()),
        (int a_value, int b_value, int c_value, dynamic _) =>
            '$a_value $b_value $c_value $_');

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.forkJoin.error.shouldThrowB', () async {
    final observableWithError = ForkJoinStream.combine3(
        Observable.just(1), Observable.just(1), Observable.just(1),
        (int a_value, int b_value, int c_value) {
      throw Exception('oh noes!');
    });

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.forkJoin.pause.resume', () async {
    final first = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [1, 2, 3, 4][index]).take(4),
        second = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [5, 6, 7, 8][index]).take(4),
        last = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [9, 10, 11, 12][index]).take(4);

    StreamSubscription<Iterable<num>> subscription;
// ignore: deprecated_member_use
    subscription = ForkJoinStream.combine3(
            first, second, last, (int a, int b, int c) => [a, b, c])
        .listen(expectAsync1((value) {
      expect(value.elementAt(0), 4);
      expect(value.elementAt(1), 8);
      expect(value.elementAt(2), 12);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
