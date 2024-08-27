import 'dart:io';

import 'package:dolumns/dolumns.dart';
import 'package:mason/mason.dart';

import 'utilities/constants.dart';
import 'utilities/environment.dart';
import 'utilities/vault.dart';
import 'utilities/vercel.dart';

void run(HookContext context) async {
  final hasGitlabConfiguration =
      File.fromUri(Directory.current.uri.resolve(kGitlabPath)).existsSync();

  final hasPipelineContext = hasGitlabConfiguration;
  if (!hasPipelineContext) {
    context.logger.err(
      'a CD/CI configuration was not found, if you want to add it in the future you will have to configure the deployment manually. Visit the documentation https://clidocs-devmy-pillars-projects.vercel.app/commands/generate/addon/vercel',
    );

    return;
  }

  if (hasGitlabConfiguration) {
    appendToGitlab(context);
  }

  context.logger
      .info('Remember to configure the following variables on .env.vault:');

  final vault = new Vault(
    Directory.fromUri(
      Directory.current.uri.resolve('../..'),
    ),
  );

  final Map<Environment, VercelProject> vercelContext =
      context.vars[kVercelContextKey];
  final applicationName = context.vars[kApplicationNameKey];

  for (final entry in vercelContext.entries) {
    final envName = entry.key.name;
    final projectIdVariableName = "${applicationName}_VERCEL_PROJECT_ID";
    final projectId = entry.value.projectId;
    final orgIdVariableName = "${applicationName}_VERCEL_ORG_ID";
    final orgId = entry.value.orgId;

    context.logger.info(
      '🔐 Configuring .env.vault for $envName',
    );

    context.logger.info(dolumnify(
      [
        ['VARIABLE', 'VALUE'],
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
        entry.value.projectId,
      )
      ..addVariable(
        envName,
        orgIdVariableName,
        entry.value.orgId,
      )
      ..push(envName);
  }

  final vercelTokenVariableName = "${applicationName}_VERCEL_TOKEN";
  final environments =
      Environment.values.map((environment) => environment.name).join(', ');

  context.logger.alert(
    "Remember to configure the $vercelTokenVariableName variable to .env.vault for environments $environments",
  );
}

void appendToGitlab(HookContext context) {
  final String applicationName = context.vars[kApplicationNameKey];
  final template = """

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
""";

  Process.run("echo", [template, " > ", kGitlabPath]);
}
