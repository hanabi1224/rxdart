import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

List<Stream<int>> _getStreams() {
  var a = Stream.periodic(const Duration(milliseconds: 1), (count) => count)
          .take(3),
      b = Stream.fromIterable(const [1, 2, 3, 4]);

  return [a, b];
}

void main() {
  test('rx.MergeStream', () async {
    final observable = MergeStream(_getStreams());

    await expectLater(
        observable, emitsInOrder(const <int>[1, 2, 3, 4, 0, 1, 2]));
  });

  test('rx.MergeStream.single.subscription', () async {
    final observable = MergeStream(_getStreams());

    observable.listen(null);
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.MergeStream.asBroadcastStream', () async {
    final observable = MergeStream(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.MergeStream.error.shouldThrowA', () async {
    final observableWithError =
        MergeStream(_getStreams()..add(Stream<int>.error(Exception())));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.MergeStream.error.shouldThrowB', () {
    expect(() => MergeStream<int>(null), throwsArgumentError);
  });

  test('rx.MergeStream.error.shouldThrowC', () {
    expect(() => MergeStream<int>(const []), throwsArgumentError);
  });

  test('rx.MergeStream.error.shouldThrowD', () {
    expect(() => MergeStream([Observable.just(1), null]), throwsArgumentError);
  });

  test('rx.MergeStream.pause.resume', () async {
    final first = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [1, 2, 3, 4][index]),
        second = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [5, 6, 7, 8][index]),
        last = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [9, 10, 11, 12][index]);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription =
        MergeStream([first, second, last]).listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
