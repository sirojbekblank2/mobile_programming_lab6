## part 2 questions

1. why is the feed in its own Provider?
so it can be swapped out. tests and demos override `tickFeedProvider` with a fake feed (e.g. `TickFeed(failAfter: 5)` or `TickFeed(symbols: const [])`) without touching `tickerProvider`. if the feed was created inside `tickerProvider`, there'd be no way to inject a different one.

2. what does autoDispose do when the user navigates away mid-stream?
when the last widget watching the provider is gone, riverpod cancels the stream subscription and throws away the provider's state, so the feed stops emitting. no leaked streams. when the user comes back, the provider starts from scratch: loading again, 800ms delay, old data gone.

3. what AsyncValue during the 800ms delay, and what is hasValue?
`AsyncLoading`, and `hasValue` is `false`. nothing has been `yield`ed yet (the `delayed` runs before the first `yield`), so there's no data stored.


## part 3
# 3.3
error - The type 'AsyncValue<List<Tick>>' isn't exhaustively matched by the switch cases since it doesn't match the
         pattern 'AsyncLoading<List<Tick>>()'. Try adding a wildcard pattern or cases that match
         'AsyncLoading<List<Tick>>()' - lib\ticker_page.dart:16:13 - non_exhaustive_switch_expression

# 3.4
switch arms are checked top to bottom and the first match wins. AsyncData(:final value) matches every data state, including empty and single-item lists, so if it sat above them they’d never run. specific arms go first, general ones last.