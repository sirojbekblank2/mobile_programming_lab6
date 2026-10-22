# riverpod_ticker

A new Flutter project.

## part 2 questions

1. why is the feed in its own Provider?
so it can be swapped out. tests and demos override `tickFeedProvider` with a fake feed (e.g. `TickFeed(failAfter: 5)` or `TickFeed(symbols: const [])`) without touching `tickerProvider`. if the feed was created inside `tickerProvider`, there'd be no way to inject a different one.

2. what does autoDispose do when the user navigates away mid-stream?
when the last widget watching the provider is gone, riverpod cancels the stream subscription and throws away the provider's state, so the feed stops emitting. no leaked streams. when the user comes back, the provider starts from scratch: loading again, 800ms delay, old data gone.

3. what AsyncValue during the 800ms delay, and what is hasValue?
`AsyncLoading`, and `hasValue` is `false`. nothing has been `yield`ed yet (the `delayed` runs before the first `yield`), so there's no data stored.