import 'package:test/test.dart';

void main() {
  test('rx.Stream.fromIterable', () async {
    const value = 1;

    final observable = Stream.fromIterable([value]);

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });
}
