import 'dart:convert';

class CliConfig {
  final String networkPackage;
  final String stateManagement;
  final String navigation;
  final bool useEquatable;

  CliConfig({
    required this.networkPackage,
    required this.stateManagement,
    required this.navigation,
    required this.useEquatable,
  });

  Map<String, dynamic> toJson() => {
        'network_package': networkPackage,
        'state_management': stateManagement,
        'navigation': navigation,
        'equatable': useEquatable,
      };

  factory CliConfig.fromJson(Map<String, dynamic> json) => CliConfig(
        networkPackage: json['network_package'] ?? 'http',
        stateManagement: json['state_management'] ?? 'bloc',
        navigation: json['navigation'] ?? 'go_router',
        useEquatable: json['equatable'] ?? true,
      );

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory CliConfig.fromJsonString(String jsonString) =>
      CliConfig.fromJson(jsonDecode(jsonString));
}
