import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_catalog_app/src/routing/app_router.dart';
import 'package:product_catalog_app/src/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: const AppRoot()));
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final theme = MaterialTheme(Theme.of(context).textTheme);

    return MaterialApp.router(
      theme: theme.lightMediumContrast(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
