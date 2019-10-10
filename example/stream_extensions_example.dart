import 'package:rxdart/rxdart.dart';

/// Concatenates two Streams together without any RxDart wrapping!!!
void main(List<String> arguments) {
  // concatWith is a method added by RxDart on "plain" Streams!
  final concatStream = Stream.fromIterable([1, 2, 3]).concatWith([
    Stream.fromIterable([4, 5, 6]),
    Stream.fromIterable([7, 8, 9])
  ]);

  // Instead of using the constructors on the Observable class, you can simply
  // use the base Stream classes now!
  final zipped = ZipStream.zip2(
    Stream.fromIterable([1, 2, 3]),
    Stream.fromIterable([4, 5, 6]),
    (int a, int b) => [a, b],
  );

  concatStream.listen(print);
  zipped.listen(print);
}
