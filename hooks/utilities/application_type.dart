enum ApplicationType {
  angular('angular'),
  next('nextjs'),
  unsupported(null);

  final String? vercelFramework;

  const ApplicationType(this.vercelFramework);
}
