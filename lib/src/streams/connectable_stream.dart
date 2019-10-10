import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/replay_stream.dart';

/// A ConnectableObservable resembles an ordinary Observable, except that it
/// can be listened to multiple times and does not begin emitting items when
/// it is listened to, but only when its [connect] method is called.
///
/// This class can be used to broadcast a single-subscription Stream, and
/// can be used to wait for all intended Observers to [listen] to the
/// Observable before it begins emitting items.
abstract class ConnectableStream<T> extends StreamView<T> {
  ConnectableStream(Stream<T> stream) : super(stream);

  /// Returns an Observable that automatically connects (at most once) to this
  /// ConnectableObservable when the first Observer subscribes.
  ///
  /// To disconnect from the source Stream, provide a [connection] callback and
  /// cancel the `subscription` at the appropriate time.
  Stream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  });

  /// Instructs the [ConnectableStream] to begin emitting items from the
  /// source Stream. To disconnect from the source stream, cancel the
  /// subscription.
  StreamSubscription<T> connect();

  /// Returns an Observable that stays connected to this ConnectableObservable
  /// as long as there is at least one subscription to this
  /// ConnectableObservable.
  Stream<T> refCount();
}

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast Stream.
class PublishConnectableStream<T> extends ConnectableStream<T> {
  final Stream<T> _source;
  final PublishSubject<T> _subject;

  factory PublishConnectableStream(Stream<T> source) {
    return PublishConnectableStream<T>._(source, PublishSubject<T>());
  }

  PublishConnectableStream._(this._source, this._subject) : super(_subject);

  @override
  Stream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_subject.add, onError: _subject.addError),
      _subject,
    );
  }

  @override
  Stream<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_subject.add, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }
}

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast Stream that replays the latest value to any new listener, and
/// provides synchronous access to the latest emitted value.
class ValueConnectableStream<T> extends ConnectableStream<T>
    implements ValueStream<T> {
  final Stream<T> _source;
  final BehaviorSubject<T> _subject;

  ValueConnectableStream._(this._source, this._subject) : super(_subject);

  factory ValueConnectableStream(Stream<T> source) =>
      ValueConnectableStream<T>._(
        source,
        BehaviorSubject<T>(),
      );

  factory ValueConnectableStream.seeded(
    Stream<T> source,
    T seedValue,
  ) =>
      ValueConnectableStream<T>._(
        source,
        BehaviorSubject<T>.seeded(seedValue),
      );

  @override
  ValueStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_subject.add, onError: _subject.addError),
      _subject,
    );
  }

  @override
  ValueStream<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_subject.add, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }

  @override
  T get value => _subject.value;

  @override
  bool get hasValue => _subject.hasValue;
}

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast Stream that replays emitted items to any new listener, and
/// provides synchronous access to the list of emitted values.
class ReplayConnectableStream<T> extends ConnectableStream<T>
    implements ReplayStream<T> {
  final Stream<T> _source;
  final ReplaySubject<T> _subject;

  factory ReplayConnectableStream(Stream<T> stream, {int maxSize}) {
    return ReplayConnectableStream<T>._(
      stream,
      ReplaySubject<T>(maxSize: maxSize),
    );
  }

  ReplayConnectableStream._(this._source, this._subject) : super(_subject);

  @override
  ReplayStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_subject.add, onError: _subject.addError),
      _subject,
    );
  }

  @override
  ReplayStream<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_subject.add, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }

  @override
  List<T> get values => _subject.values;
}

/// A special [StreamSubscription] that not only cancels the connection to
/// the source [Stream], but also closes down a subject that drives the Stream.
class ConnectableObservableStreamSubscription<T> extends StreamSubscription<T> {
  final StreamSubscription<T> _source;
  final Subject<T> _subject;

  ConnectableObservableStreamSubscription(this._source, this._subject);

  @override
  Future<dynamic> cancel() {
    _subject.close();
    return _source.cancel();
  }

  @override
  Future<E> asFuture<E>([E futureValue]) => _source.asFuture(futureValue);

  @override
  bool get isPaused => _source.isPaused;

  @override
  void onData(void Function(T data) handleData) => _source.onData(handleData);

  @override
  void onDone(void Function() handleDone) => _source.onDone(handleDone);

  @override
  void onError(Function handleError) => _source.onError(handleError);

  @override
  void pause([Future<dynamic> resumeSignal]) => _source.pause(resumeSignal);

  @override
  void resume() => _source.resume();
}
