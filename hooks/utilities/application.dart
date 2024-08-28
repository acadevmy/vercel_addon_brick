import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:mason/mason.dart';

import 'application_type.dart';

class Application {
  Directory directory;
  ApplicationType type;

  String get name =>
      directory.uri.pathSegments.lastWhere((path) => path.isNotEmpty);
  String get displayName => '$name (${type.name.pascalCase})';

  Application({required this.directory})
      : type = getApplicationTypeFromDirectory(directory);
}

bool checkIfIsAngularApplication(Directory directory) {
  const angularDescriptor = 'angular.json';

  return File.fromUri(directory.uri.resolve(angularDescriptor)).existsSync();
}

bool checkIfIsNestJSApplication(Directory directory) {
  const nestDescriptor = 'nest-cli.json';

  return File.fromUri(directory.uri.resolve(nestDescriptor)).existsSync();
}

bool checkIfIsNextApplication(Directory directory) {
  final nextDescriptor = Glob("next.config.*");
  return nextDescriptor.listSync(root: directory.path).isNotEmpty;
}

ApplicationType getApplicationTypeFromDirectory(Directory directory) {
  if (checkIfIsAngularApplication(directory)) {
    return ApplicationType.angular;
  }

  if (checkIfIsNestJSApplication(directory)) {
    return ApplicationType.nest;
  }

  if (checkIfIsNextApplication(directory)) {
    return ApplicationType.next;
  }

  return ApplicationType.unsupported;
}
