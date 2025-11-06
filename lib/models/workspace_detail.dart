// models/workspace_detail.dart
class WorkspaceDetail {
  final int id;
  final String name; // Ganti 'name' jika key di JSON berbeda (cth: 'item_name')
  final String condition;
  final String typeText; // Dari accessor 'type_text'

  WorkspaceDetail({
    required this.id,
    required this.name,
    required this.condition,
    required this.typeText,
  });

  factory WorkspaceDetail.fromJson(Map<String, dynamic> json) {
    return WorkspaceDetail(
      id: json['id'],
      name: json['name'] ?? json['item_name'] ?? 'N/A',
      condition: json['condition'] ?? 'N/A',
      typeText: json['type_text'] ?? 'N/A',
    );
  }
}