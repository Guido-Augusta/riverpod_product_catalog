import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/src/routing/main_nav_scaffold.dart';

void main() {
  group('TabReselectNotifier & TabReselectEvent', () {
    test('initial state is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(tabReselectNotifierProvider);
      expect(state, isNull);
    });

    test('reselect updates state with correct tabIndex and timestamp', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tabReselectNotifierProvider.notifier);
      notifier.reselect(0);

      final event1 = container.read(tabReselectNotifierProvider);
      expect(event1, isNotNull);
      expect(event1!.tabIndex, 0);

      // Delay briefly to ensure distinct microseconds
      await Future<void>.delayed(const Duration(milliseconds: 2));

      notifier.reselect(0);
      final event2 = container.read(tabReselectNotifierProvider);
      expect(event2, isNotNull);
      expect(event2!.tabIndex, 0);
      expect(event2.timestamp, isNot(equals(event1.timestamp)));
    });

    test('ref.listen is triggered every time reselect is called on the same tab', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      int listenerCallCount = 0;
      int? lastNotifiedTab;

      container.listen<TabReselectEvent?>(
        tabReselectNotifierProvider,
        (previous, next) {
          listenerCallCount++;
          lastNotifiedTab = next?.tabIndex;
        },
      );

      final notifier = container.read(tabReselectNotifierProvider.notifier);
      notifier.reselect(0);
      await Future<void>.delayed(const Duration(milliseconds: 2));

      notifier.reselect(0);
      await Future<void>.delayed(const Duration(milliseconds: 2));

      notifier.reselect(1);

      expect(listenerCallCount, 3);
      expect(lastNotifiedTab, 1);
    });
  });
}
