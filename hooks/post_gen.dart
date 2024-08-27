import 'dart:io';

import 'package:dolumns/dolumns.dart';
import 'package:mason/mason.dart';

import 'utilities/constants.dart';
import 'utilities/environment.dart';
import 'utilities/vault.dart';
import 'utilities/vercel.dart';
import 'utilities/vercel_context.dart';

void run(HookContext context) {
  final gitlabConfiguration = File.fromUri(
    Directory.current.absolute.parent.parent.uri.resolve(kGitlabFileName),
  );

  final hasGitlabConfiguration = gitlabConfiguration.existsSync();

  final hasPipelineContext = hasGitlabConfiguration;
  if (!hasPipelineContext) {
    context.logger.err(
      'a CD/CI configuration was not found, if you want to add it in the future you will have to configure the deployment manually. Visit the documentation https://clidocs-devmy-pillars-projects.vercel.app/commands/generate/addon/vercel',
    );

    return;
  }

  if (hasGitlabConfiguration) {
    appendToGitlab(gitlabConfiguration, context);
  }

  context.logger
      .info('Remember to configure the following variables on .env.vault:');

  final vault = new Vault(
    Directory.fromUri(
      Directory.current.uri.resolve('../..'),
    ),
  );

  final Map<String, dynamic> rawVercelContext = context.vars[kVercelContextKey];

  final Map<Environment, VercelProject> vercelContext =
      deserializeVercelContext(rawVercelContext);

  final applicationName = context.vars[kApplicationNameKey];

  for (final entry in vercelContext.entries) {
    final envName = entry.key.name;
    final projectIdVariableName = "${applicationName}_VERCEL_PROJECT_ID";
    final projectId = entry.value.projectId;
    final orgIdVariableName = "${applicationName}_VERCEL_ORG_ID";
    final orgId = entry.value.orgId;
    final vercelTokenVariableName = "${applicationName}_VERCEL_TOKEN";
    final vercelToken = entry.value.token;

    context.logger.info(
      '🔐 Configuring .env.vault for $envName',
    );

    context.logger.info(dolumnify(
      [
        ['VARIABLE', 'VALUE'],
        [vercelTokenVariableName, vercelToken],
        [projectIdVariableName, projectId],
        [orgIdVariableName, orgId],
      ],
      columnSplitter: ' | ',
      headerIncluded: true,
      headerSeparator: '=',
    ));

    vault
      ..pull(envName)
      ..addVariable(
        envName,
        projectIdVariableName,
        projectId,
      )
      ..addVariable(
        envName,
        orgIdVariableName,
        orgId,
      )
      ..addVariable(
        envName,
        vercelTokenVariableName,
        vercelToken,
      )
      ..push(envName);
  }
}

void appendToGitlab(File gitlab, HookContext context) {
  final String applicationName = context.vars[kApplicationNameKey];

  gitlab.writeAsStringSync("""

"[STAGING] $applicationName":
  extends:
    - .deploy-staging
    - .deploy-vercel
  variables:
    APPLICATION_PREFIX: "$applicationName"

"[PRODUCTION] $applicationName":
  extends:
    - .deploy-production
    - .deploy-vercel
  variables:
    APPLICATION_PREFIX: "$applicationName"
""", mode: FileMode.append);
}
