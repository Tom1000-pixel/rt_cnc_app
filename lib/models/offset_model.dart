class OffsetItem {
  final String id;
  final int line;
  final String type;
  final String op;
  final String tool;
  final double x;
  final double z;

  OffsetItem({
    required this.id,
    required this.line,
    required this.type,
    required this.op,
    required this.tool,
    required this.x,
    required this.z,
  });

  factory OffsetItem.fromJson(Map<String, dynamic> json) {
    return OffsetItem(
      id: json['id'].toString(),
      line: json['line'] as int,
      type: json['type'] ?? '',
      op: json['op'] ?? '',
      tool: json['tool'] ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      z: (json['z'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
