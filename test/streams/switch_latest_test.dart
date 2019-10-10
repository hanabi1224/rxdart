import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('SwitchLatest', () {
    test('emits all values from an emitted Stream', () {
      expect(
        SwitchLatestStream(
          Observable.just(
            Stream.fromIterable(const ['A', 'B', 'C']),
          ),
        ),
        emitsInOrder(<dynamic>['A', 'B', 'C', emitsDone]),
      );
    });

    test('only emits values from the latest emitted stream', () {
      expect(
        SwitchLatestStream(testObservable),
        emits('C'),
      );
    });

    test('emits errors from the higher order Stream to the listener', () {
      expect(
        SwitchLatestStream(
          Stream<Stream<void>>.error(Exception()),
        ),
        emitsError(isException),
      );
    });

    test('emits errors from the emitted Stream to the listener', () {
      expect(
        SwitchLatestStream(errorObservable),
        emitsError(isException),
      );
    });

    test('closes after the last event from the last emitted Stream', () {
      expect(
        SwitchLatestStream(testObservable),
        emitsThrough(emitsDone),
      );
    });

    test('closes if the higher order stream is empty', () {
      expect(
        SwitchLatestStream(
          Stream<Stream<void>>.empty(),
        ),
        emitsThrough(emitsDone),
      );
    });

    test('is single subscription', () {
      final stream = SwitchLatestStream(testObservable);

      expect(stream, emits('C'));
      expect(() => stream.listen(null), throwsStateError);
    });

    test('can be paused and resumed', () {
      // ignore: cancel_subscriptions
      final subscription =
          SwitchLatestStream(testObservable).listen(expectAsync1((result) {
        expect(result, 'C');
      }));

      subscription.pause();
      subscription.resume();
    });
  });
}

Stream<Stream<String>> get testObservable => Stream.fromIterable([
      TimerStream('A', Duration(seconds: 2)),
      TimerStream('B', Duration(seconds: 1)),
      Observable.just('C'),
    ]);

Stream<Stream<String>> get errorObservable => Stream.fromIterable([
      TimerStream('A', Duration(seconds: 2)),
      TimerStream('B', Duration(seconds: 1)),
      Stream.error(Exception()),
    ]);
