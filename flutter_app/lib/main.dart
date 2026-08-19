import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log all Flutter runtime exceptions directly to terminal stdout
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('================= [FLUTTER RUNTIME ERROR] =================');
    debugPrint(details.exceptionAsString());
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
    debugPrint('==========================================================');
  };

  // Log uncaught async platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('================= [PLATFORM UNCAUGHT ERROR] =================');
    debugPrint(error.toString());
    debugPrint(stack.toString());
    debugPrint('============================================================');
    return true;
  };

  await setupServiceLocator();
  runApp(const SchooKeepApp());
}
