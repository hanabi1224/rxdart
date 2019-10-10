/// An [Observable] that provides synchronous access to the last emitted item
abstract class ValueStream<T> implements Stream<T> {
  /// Last emitted value, or null if there has been no emission yet
  /// See [hasValue]
  T get value;

  bool get hasValue;
}
