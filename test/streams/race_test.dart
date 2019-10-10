import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> getDelayedStream(int delay, int value) async* {
  final completer = Completer<Null>();

  Timer(Duration(milliseconds: delay), () => completer.complete());

  await completer.future;

  yield value;
  yield value + 1;
  yield value + 2;
}

void main() {
  test('rx.RaceStream', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);
    var expected = 1;

    RaceStream([first, second, last]).listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result.compareTo(expected++), 0);
    }, count: 3));
  });

  test('rx.RaceStream.single.subscription', () async {
    final first = getDelayedStream(50, 1);

    final observable = RaceStream([first]);

    observable.listen(null);
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.RaceStream.asBroadcastStream', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);

    final observable = RaceStream([first, second, last]).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.RaceStream.shouldThrowA', () {
    expect(() => RaceStream<Null>(null), throwsArgumentError);
  });

  test('rx.RaceStream.shouldThrowB', () {
    expect(() => RaceStream<Null>(const []), throwsArgumentError);
  });

  test('rx.RaceStream.shouldThrowC', () async {
    final observable = RaceStream([Stream<Null>.error(Exception('oh noes!'))]);

    // listen twice on same stream
    observable.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
  });

  test('rx.RaceStream.pause.resume', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);

    StreamSubscription<int> subscription;
    // ignore: deprecated_member_use
    subscription =
        RaceStream([first, second, last]).listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
