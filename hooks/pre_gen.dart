import 'dart:io';

import 'package:mason/mason.dart';

import 'utilities/application.dart';
import 'utilities/constants.dart';
import 'utilities/environment.dart';
import 'utilities/vercel.dart';

void run(HookContext context) {
  final vercel = Vercel();

  final vercelContext = <Environment, VercelProject>{};

  for (final env in Environment.values) {
    vercel.logout();
    context.logger.info('Configure ${env.name} environment');
    vercel.login();
    vercelContext[env] = vercel.link();
  }

  context.vars[kVercelContextKey] = vercelContext;
  final application = Application(directory: Directory.current.absolute);
  context.vars[kVercelFrameworkKey] = application.type.vercelFramework;
}
