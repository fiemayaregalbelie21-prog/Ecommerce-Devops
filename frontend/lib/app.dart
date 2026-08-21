import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/feva_theme.dart';
import 'features/settings/presentation/providers/theme_provider.dart';

class FevaApp extends ConsumerWidget {
  const FevaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nova Store',
      debugShowCheckedModeBanner: false,
      theme: FevaTheme.light(),
      darkTheme: FevaTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
