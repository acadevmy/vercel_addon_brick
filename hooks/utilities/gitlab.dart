import 'dart:convert';
import 'dart:io';

import 'package:json2yaml/json2yaml.dart';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

void updateGitlabCdCi(File gitlab, String applicationName) {
  applicationName = applicationName.constantCase;
  String rawYaml = gitlab.readAsStringSync();
  Map<String, dynamic> yaml =
      json.decode(json.encode(loadYaml(rawYaml))) as Map<String, dynamic>;

  yaml = yaml.map(
    (key, value) {
      if (key.contains(' ') && !key.startsWith("\"")) {
        key = "\"$key\"";
      }
      return MapEntry(key, value);
    },
  );

  final includes = (yaml['include'] as List<dynamic>?) ?? <dynamic>[];

  final hasVercelImport = includes.any(
    (include) =>
        include is Map<String, dynamic> &&
        include['file'] == '/gitlab-ci/vercel.yml',
  );

  if (!hasVercelImport) {
    includes.add({
      'file': '/gitlab-ci/vercel.yml',
      'project': 'pillar-1/devops',
      'ref': 'v1.0.0',
    });

    yaml['include'] = includes;
  }

  yaml["\"[STAGING] $applicationName\""] = {
    "extends": [".deploy-staging", ".deploy-vercel"],
    "variables": {"APPLICATION_PREFIX": applicationName}
  };

  yaml["\"[PRODUCTION] $applicationName\""] = {
    "extends": [".deploy-production", ".deploy-vercel"],
    "variables": {"APPLICATION_PREFIX": applicationName}
  };

  rawYaml = json2yaml(yaml, yamlStyle: YamlStyle.pubspecYaml);

  gitlab.writeAsStringSync(rawYaml);
}
