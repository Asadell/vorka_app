import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String? ketuaDepartemen;
  final String? wakilDepartemen;

  DepartmentModel({
    required this.id,
    required this.name,
    this.ketuaDepartemen,
    this.wakilDepartemen,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ketuaDepartemen: map['ketuaDepartemen'],
      wakilDepartemen: map['wakilDepartemen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ketuaDepartemen': ketuaDepartemen,
      'wakilDepartemen': wakilDepartemen,
    };
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? ketuaDepartemen,
    String? wakilDepartemen,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ketuaDepartemen: ketuaDepartemen ?? this.ketuaDepartemen,
      wakilDepartemen: wakilDepartemen ?? this.wakilDepartemen,
    );
  }
}

class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String createdBy;
  final String? ketuaOrganisasi;
  final String? wakilOrganisasi;
  final List<DepartmentModel> departments;
  final DateTime createdAt;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.createdBy,
    this.ketuaOrganisasi,
    this.wakilOrganisasi,
    required this.departments,
    required this.createdAt,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'],
      createdBy: data['createdBy'] ?? '',
      ketuaOrganisasi: data['ketuaOrganisasi'],
      wakilOrganisasi: data['wakilOrganisasi'],
      departments:
          (data['departments'] as List<dynamic>?)
              ?.map((e) => DepartmentModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'createdBy': createdBy,
      'ketuaOrganisasi': ketuaOrganisasi,
      'wakilOrganisasi': wakilOrganisasi,
      'departments': departments.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? createdBy,
    String? ketuaOrganisasi,
    String? wakilOrganisasi,
    List<DepartmentModel>? departments,
    DateTime? createdAt,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      createdBy: createdBy ?? this.createdBy,
      ketuaOrganisasi: ketuaOrganisasi ?? this.ketuaOrganisasi,
      wakilOrganisasi: wakilOrganisasi ?? this.wakilOrganisasi,
      departments: departments ?? this.departments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
