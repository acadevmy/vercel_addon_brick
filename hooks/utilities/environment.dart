enum Environment {
  staging,
  production;

  static Environment fromJson(String value) {
    return Environment.values
        .firstWhere((environment) => environment.name == value);
  }

  String toJson() {
    return this.name;
  }
}
