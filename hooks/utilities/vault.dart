import 'dart:io';

class Vault {
  final Directory directory;
  Vault(this.directory);

  void pull(String environment) {
    Process.runSync('pnpm', ['dlx', 'dotenv-vault', 'pull', environment],
        workingDirectory: directory.path);
  }

  void push(String environment) {
    Process.runSync('pnpm', ['dlx', 'dotenv-vault', 'push', environment],
        workingDirectory: directory.path);
  }

  void addVariable(String environment, String name, dynamic value) {
    final dotenv = File.fromUri(directory.uri.resolve('.env.$environment'));
    dotenv.writeAsStringSync('\n$name=$value', mode: FileMode.append);
  }
}
