class Project {
  final String projectId;
  final String createdBy;
  final String projectName;
  final String location;
  final String startDate;
  final String endDate;
  final double totalBudget;
  final String status; // 'Planning', 'In Progress', 'Completed', 'On Hold'

  Project({
    required this.projectId,
    this.createdBy = 'Super Admin',
    required this.projectName,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    this.status = 'In Progress',
  });

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'created_by': createdBy,
      'project_name': projectName,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'total_budget': totalBudget,
      'status': status,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      projectId: map['project_id'] ?? '',
      createdBy: map['created_by'] ?? 'Super Admin',
      projectName: map['project_name'] ?? '',
      location: map['location'] ?? '',
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'] ?? '',
      totalBudget: (map['total_budget'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'In Progress',
    );
  }

  Project copyWith({
    String? projectId,
    String? createdBy,
    String? projectName,
    String? location,
    String? startDate,
    String? endDate,
    double? totalBudget,
    String? status,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      createdBy: createdBy ?? this.createdBy,
      projectName: projectName ?? this.projectName,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalBudget: totalBudget ?? this.totalBudget,
      status: status ?? this.status,
    );
  }
}
