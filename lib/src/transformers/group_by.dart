import 'dart:async';

/// The GroupBy operator divides an [Observable] that emits items into
/// an [Observable] that emits [GroupByStream],
/// each one of which emits some subset of the items
/// from the original source [Observable].
///
/// [GroupByStream] acts like a regular [Observable], yet
/// adding a 'key' property, which receives its [Type] and value from
/// the [grouper] Function.
///
/// All items with the same key are emitted by the same [GroupByStream].

class GroupByStreamTransformer<T, S>
    extends StreamTransformerBase<T, GroupByStream<T, S>> {
  final S Function(T) grouper;

  GroupByStreamTransformer(this.grouper);

  @override
  Stream<GroupByStream<T, S>> bind(Stream<T> stream) =>
      _buildTransformer<T, S>(grouper).bind(stream);

  static StreamTransformer<T, GroupByStream<T, S>> _buildTransformer<T, S>(
      S Function(T) grouper) {
    return StreamTransformer<T, GroupByStream<T, S>>(
        (Stream<T> input, bool cancelOnError) {
      final mapper = <S, StreamController<T>>{};
      StreamController<GroupByStream<T, S>> controller;
      StreamSubscription<T> subscription;

      final controllerBuilder = (S forKey) => () {
            final groupedController = StreamController<T>();

            controller
                .add(GroupByStream<T, S>(forKey, groupedController.stream));

            return groupedController;
          };

      controller = StreamController<GroupByStream<T, S>>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  try {
                    final key = grouper(value);
                    // ignore: close_sinks
                    final groupedController =
                        mapper.putIfAbsent(key, controllerBuilder(key));

                    groupedController.add(value);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  mapper.values.forEach((controller) => controller.close());
                  mapper.clear();

                  controller.close();
                });
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}

class GroupByStream<T, S> extends StreamView<T> {
  final S key;

  GroupByStream(this.key, Stream<T> stream) : super(stream);
}
