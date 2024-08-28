import 'dart:io';

import 'package:mason/mason.dart';

import 'utilities/application.dart';
import 'utilities/application_type.dart';
import 'utilities/constants.dart';
import 'utilities/environment.dart';
import 'utilities/vercel.dart';
import 'utilities/vercel_context.dart';

void run(HookContext context) {
  context.logger.prompt('''
======================================
          Vercel Configuration Setup
======================================

This command automates the process of setting up the Vercel configuration for 
the current application, making it ready for deployment. It performs the 
following tasks automatically:

1. Requests Vercel Tokens:
   For both the staging and production environments, you will be asked to 
   provide their respective Vercel tokens. You can obtain these tokens by 
   visiting:
   https://vercel.com/account/tokens

2. Updates the CDCI file:
   The command will modify your (GitLab CI) configuration to include deployment 
   steps for both staging and production environments.
   
3. Populates .env.vault variables:
   The script will automatically insert environment variables into the 
   .env.vault file for both staging and production.


IMPORTANT:
- Separate Vercel accounts:
  This command assumes that staging and production are hosted on two separate 
  Vercel accounts. Using the same token for both environments will result in 
  deployment issues. Make sure to provide distinct tokens for each environment.
  
- Account access:
  If you do not have access to the Vercel accounts for staging or production, 
  please contact your project lead or admin to request access before running 
  this setup.

======================================

Press Enter to proceed with the setup...

''');
  final vercelContext = <Environment, VercelProject>{};

  for (final env in Environment.values) {
    context.logger.info('${env.name.upperCase} configuration');
    final vercelToken = context.logger.prompt(
      'Insert VERCEL_TOKEN for ${env.name.upperCase} (https://vercel.com/account/tokens):',
    );

    final vercel = Vercel(vercelToken);

    vercelContext[env] = vercel.link();
  }

  context.vars[kVercelContextKey] = serializeVercelContext(vercelContext);
  final application = Application(directory: Directory.current.absolute);
  context.vars[kVercelFrameworkKey] = application.type.vercelFramework;
  context.vars[kVercelIsNestjsKey] = application.type == ApplicationType.nest;
  print(context.vars[kVercelIsNestjsKey]);
}
