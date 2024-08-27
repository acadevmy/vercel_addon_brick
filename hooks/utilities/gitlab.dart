import 'dart:convert';
import 'dart:io';

import 'package:json2yaml/json2yaml.dart';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

import 'constants.dart';

void updateGitlabCdCi(File gitlab, String applicationName) {
  final applicationNameConstantCase = applicationName.constantCase;
  final applicationNameParamCase = applicationName.paramCase;
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
      'ref': kVercelDevopsConfigVersion,
    });

    yaml['include'] = includes;
  }

  yaml["\"[STAGING] $applicationNameConstantCase\""] = {
    "extends": [".deploy-staging", ".deploy-vercel"],
    "variables": {
      "APPLICATION_PREFIX": applicationNameConstantCase,
      "APPLICATION_BASE_PATH": "applications/$applicationNameParamCase",
    },
  };

  yaml["\"[PRODUCTION] $applicationNameConstantCase\""] = {
    "extends": [".deploy-production", ".deploy-vercel"],
    "variables": {
      "APPLICATION_PREFIX": applicationNameConstantCase,
      "APPLICATION_BASE_PATH": "applications/$applicationNameParamCase",
    },
  };

  rawYaml = json2yaml(yaml, yamlStyle: YamlStyle.pubspecYaml);

  gitlab.writeAsStringSync(rawYaml);
}
