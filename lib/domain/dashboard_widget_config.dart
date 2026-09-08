class DashboardWidgetConfig {
  final String id;
  final String size; // 'compact', 'normal'
  final int span; // 1 = 50%, 2 = 100%

  const DashboardWidgetConfig({
    required this.id,
    this.size = 'normal',
    this.span = 2,
  });

  DashboardWidgetConfig copyWith({String? id, String? size, int? span}) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      size: size ?? this.size,
      span: span ?? this.span,
    );
  }

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      id: json['id'] as String,
      size: json['size'] as String? ?? 'normal',
      span:
          json['span'] as int? ??
          (json['id'].toString().startsWith('stats_') ? 1 : 2),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'size': size, 'span': span};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardWidgetConfig &&
        other.id == id &&
        other.size == size &&
        other.span == span;
  }

  @override
  int get hashCode => id.hashCode ^ size.hashCode ^ span.hashCode;
}
