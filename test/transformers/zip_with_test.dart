import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.zipWith', () async {
    Observable<int>(Observable.just(1))
        .zipWith(Observable.just(2), (int one, int two) => one + two)
        .listen(expectAsync1((int result) {
          expect(result, 3);
        }, count: 1));
  });
}
