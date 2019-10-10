import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.MergeStreamWith', () async {
    final delayedStream = TimerStream(1, Duration(milliseconds: 10));
    final immediateStream = Observable.just(2);
    const expected = [2, 1];
    var count = 0;

    delayedStream.mergeWith([immediateStream]).listen(expectAsync1((result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });
}
