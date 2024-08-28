enum ApplicationType {
  angular('angular'),
  next('nextjs'),
  nest(null),
  unsupported(null);

  final String? vercelFramework;

  const ApplicationType(this.vercelFramework);
}
