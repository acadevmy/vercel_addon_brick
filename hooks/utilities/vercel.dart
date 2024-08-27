import 'dart:convert';
import 'dart:io';

class Vercel {
  final String token;
  Vercel(this.token);

  VercelProject link() {
    final vercelFolder = Directory.fromUri(
      Directory.current.uri.resolve('.vercel'),
    );

    if (vercelFolder.existsSync()) {
      vercelFolder.deleteSync(recursive: true);
    }

    Process.runSync('pnpm', [
      'dlx',
      'vercel',
      'link',
      '--yes',
      '--token',
      token,
    ]);

    final vercelProject = File.fromUri(
      Directory.current.uri.resolve('.vercel/project.json'),
    );

    if (!vercelProject.existsSync()) {
      throw Exception("Missing vercel project.json");
    }

    final rawJson = vercelProject.readAsStringSync();
    final json = jsonDecode(rawJson) as Map<String, dynamic>;

    return VercelProject(
      orgId: json['orgId'],
      projectId: json['projectId'],
      token: token,
    );
  }
}

class VercelProject {
  final String token;
  final String orgId;
  final String projectId;

  VercelProject(
      {required this.orgId, required this.projectId, required this.token});

  VercelProject.fromJson(Map<String, dynamic> json)
      : orgId = json['orgId'] as String,
        projectId = json['projectId'] as String,
        token = json['token'];

  Map<String, dynamic> toJson() {
    return {
      'orgId': orgId,
      'projectId': projectId,
      'token': token,
    };
  }
}
