enum ApplicationType {
  angular('angular'),
  next('next'),
  unsupported(null);

  final String? vercelFramework;

  const ApplicationType(this.vercelFramework);
}
