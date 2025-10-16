import 'dart:convert';

/// Immutable configuration chosen for project scaffolding.
class CliConfig {
  /// The network package to use, e.g. 'http' or 'dio'.
  final String networkPackage;

  /// The state management approach, e.g. 'bloc' or 'cubit'.
  final String stateManagement;

  /// The navigation approach, e.g. 'go_router' or 'navigator'.
  final String navigation;

  /// Whether to include Equatable for value equality.
  final bool useEquatable;

  /// Creates a new configuration instance.
  CliConfig({
    required this.networkPackage,
    required this.stateManagement,
    required this.navigation,
    required this.useEquatable,
  });

  /// Serializes this configuration to a JSON map.
  Map<String, dynamic> toJson() => {
        'network_package': networkPackage,
        'state_management': stateManagement,
        'navigation': navigation,
        'equatable': useEquatable,
      };

  /// Creates a configuration from a JSON map.
  factory CliConfig.fromJson(Map<String, dynamic> json) => CliConfig(
        networkPackage: json['network_package'] ?? 'http',
        stateManagement: json['state_management'] ?? 'bloc',
        navigation: json['navigation'] ?? 'go_router',
        useEquatable: json['equatable'] ?? true,
      );

  /// Serializes this configuration to a pretty-printed JSON string.
  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Parses a configuration from a JSON string.
  factory CliConfig.fromJsonString(String jsonString) =>
      CliConfig.fromJson(jsonDecode(jsonString));
}
