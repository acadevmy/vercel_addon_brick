import 'dart:io';

import 'package:dolumns/dolumns.dart';
import 'package:mason/mason.dart';

import 'utilities/constants.dart';
import 'utilities/environment.dart';
import 'utilities/gitlab.dart';
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

  final String applicationName = context.vars[kApplicationNameKey] as String;
  if (hasGitlabConfiguration) {
    updateGitlabCdCi(gitlabConfiguration, applicationName);
  }

  final vault = new Vault(Directory.current.absolute.parent.parent);

  final Map<String, dynamic> rawVercelContext = context.vars[kVercelContextKey];

  final Map<Environment, VercelProject> vercelContext =
      deserializeVercelContext(rawVercelContext);

  for (final entry in vercelContext.entries) {
    final envName = entry.key.name;
    final projectIdVariableName =
        "${applicationName.constantCase}_VERCEL_PROJECT_ID";
    final projectId = entry.value.projectId;
    final orgIdVariableName = "${applicationName.constantCase}_VERCEL_ORG_ID";
    final orgId = entry.value.orgId;
    final vercelTokenVariableName =
        "${applicationName.constantCase}_VERCEL_TOKEN";
    final vercelToken = entry.value.token;

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

    context.logger.info(
      '🔐 Configured .env.vault for $envName',
    );

    context.logger.info('\n');

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

    context.logger.info('\n');
  }
}
