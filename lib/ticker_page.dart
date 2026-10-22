import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/ticker_providers.dart';
import 'widgets/tick_row.dart';

class TickerPage extends ConsumerWidget {
  const TickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticks = ref.watch(tickerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ticker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => ref.read(failAfterProvider.notifier).state = 5,
          ),
          IconButton(
            icon: const Icon(Icons.healing),
            onPressed: () => ref.read(failAfterProvider.notifier).state = null,
          ),
        ],
      ),
      body: switch (ticks) {
        // error, but old data exists: banner + dimmed rows
        AsyncError(:final error, :final value?) => Column(children: [
            MaterialBanner(
              content: Text('Feed error: $error — showing last prices'),
              actions: [
                TextButton(
                  onPressed: () => ref.invalidate(tickerProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
            Expanded(
              child: Opacity(
                opacity: 0.5,
                child: ListView(children: [for (final t in value) TickRow(t, key: ValueKey(t.symbol))]),
              ),
            ),
          ]),
        // error, nothing to show
        AsyncError(:final error) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Could not load ticker\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(tickerProvider),
                child: const Text('Retry'),
              ),
            ]),
          ),
        // loading again but old data exists: keep rows, thin bar on top
        AsyncValue(:final value?, isLoading: true) => Column(children: [
            const LinearProgressIndicator(),
            Expanded(
              child: ListView(children: [for (final t in value) TickRow(t, key: ValueKey(t.symbol))]),
            ),
          ]),
        // content-based arms from exercise 3.4
        AsyncData(value: []) => const Center(child: Text('No symbols subscribed')),
        AsyncData(value: [final only]) => Center(child: TickRow(only)),
        // plain data
        AsyncData(:final value) => RefreshIndicator(
    onRefresh: () => ref.refresh(tickerProvider.future),
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [for (final t in value) TickRow(t, key: ValueKey(t.symbol))],
    ),
  ),
        // cold start, nothing yet
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}