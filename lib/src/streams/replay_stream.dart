/// An [Observable] that provides synchronous access to the emitted values
abstract class ReplayStream<T> implements Stream<T> {
  List<T> get values;
}
