import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tick.dart';
import '../services/tick_feed.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Overridable in tests and in the error demo.
final failAfterProvider = StateProvider<int?>((ref) => null);

final tickFeedProvider = Provider<TickFeed>((ref) {
  return TickFeed(failAfter: ref.watch(failAfterProvider));
});

final tickerProvider = StreamProvider.autoDispose<List<Tick>>(
  (ref) => ref.watch(tickFeedProvider).watch(),
  retry: (retryCount, error) => null,
);