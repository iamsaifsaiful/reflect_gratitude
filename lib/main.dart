import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/content.dart';
import 'data/entry_store.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(darkStatusBar);

  final content = await ContentRepository.load(rootBundle);
  final state = AppState(store: PrefsEntryStore(), content: content);
  await state.load();

  runApp(ReflectApp(state: state));
}
