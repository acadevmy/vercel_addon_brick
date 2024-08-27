import 'dart:convert';
import 'dart:io';

class Vercel {
  void logout() {
    Process.runSync(
      'corepack',
      ['pnpm dlx vercel logout'],
      runInShell: true,
    );
  }

  void login() {
    Process.runSync(
      'corepack',
      ['pnpm dlx vercel login'],
      runInShell: true,
    );
  }

  VercelProject link() {
    Process.runSync(
      'corepack',
      ['pnpm dlx vercel link'],
      runInShell: true,
    );

    final vercelProject =
        File.fromUri(Directory.current.uri.resolve('.vercel/project.json'));
    if (!vercelProject.existsSync()) {
      throw Exception("Missing vercel project.json");
    }

    final rawJson = vercelProject.readAsStringSync();
    final json = jsonDecode(rawJson) as Map<String, dynamic>;

    return VercelProject.fromJson(json);
  }
}

class VercelProject {
  final String orgId;
  final String projectId;

  VercelProject({required this.orgId, required this.projectId});

  VercelProject.fromJson(Map<String, dynamic> json)
      : orgId = json['orgId'] as String,
        projectId = json['projectId'] as String;
}
