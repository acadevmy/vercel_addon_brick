import 'dart:io';

import 'package:mason/mason.dart';

const kNonInteractiveKey = 'devmyNonInteractive';

bool isNonInteractive(HookContext context) {
  return context.vars[kNonInteractiveKey] == true || !stdin.hasTerminal;
}

String? readEnvironmentVariable(String key) {
  final value = Platform.environment[key];
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return value;
}
