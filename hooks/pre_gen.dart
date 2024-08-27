import 'dart:io';

import 'package:mason/mason.dart';

import 'utilities/application.dart';
import 'utilities/constants.dart';
import 'utilities/environment.dart';
import 'utilities/vercel.dart';

void run(HookContext context) {
  final vercelContext = <Environment, VercelProject>{};

  for (final env in Environment.values) {
    context.logger.info('${env.name.upperCase} configuration');
    context.logger.info('Insert VERCEL_TOKEN for ${env.name.upperCase}');
    context.logger.warn(
        '(make sure you enter your application account token and not your personal one)');
    final vercelToken = context.logger.prompt(
      '(https://vercel.com/account/tokens):',
    );

    final vercel = Vercel(vercelToken);

    vercelContext[env] = vercel.link();
  }

  context.vars[kVercelContextKey] = vercelContext;
  final application = Application(directory: Directory.current.absolute);
  context.vars[kVercelFrameworkKey] = application.type.vercelFramework;
}
