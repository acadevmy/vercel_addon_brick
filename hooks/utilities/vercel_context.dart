import 'environment.dart';
import 'vercel.dart';

Map<Environment, VercelProject> deserializeVercelContext(
    Map<String, dynamic> json) {
  return json.map(
    (key, value) =>
        MapEntry(Environment.fromJson(key), VercelProject.fromJson(value)),
  );
}

Map<String, dynamic> serializeVercelContext(
    Map<Environment, VercelProject> context) {
  return context.map(
    (key, value) => MapEntry(key.toJson(), value.toJson()),
  );
}
