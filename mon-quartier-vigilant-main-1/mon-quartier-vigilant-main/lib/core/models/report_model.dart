class ReportModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String quartier;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> nearbyOrganisations;
  final List<String> photos;
  final List<String> resolutionPhotos;
  final String date;
  final int votes;
  final String reporterId;
  final String reporterType;
  final String? createdAt;
  final bool canEdit;
  final bool canDelete;

  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.quartier,
    required this.address,
    this.latitude,
    this.longitude,
    this.nearbyOrganisations = const [],
    this.photos = const [],
    this.resolutionPhotos = const [],
    required this.date,
    required this.votes,
    required this.reporterId,
    required this.reporterType,
    this.createdAt,
    this.canEdit = false,
    this.canDelete = false,
  });

  ReportModel copyWith({
    String? title,
    String? description,
    String? category,
    String? status,
    String? quartier,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? nearbyOrganisations,
    List<String>? photos,
    List<String>? resolutionPhotos,
    String? date,
    int? votes,
    String? reporterId,
    String? reporterType,
    String? createdAt,
    bool? canEdit,
    bool? canDelete,
  }) {
    return ReportModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      quartier: quartier ?? this.quartier,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nearbyOrganisations: nearbyOrganisations ?? this.nearbyOrganisations,
      photos: photos ?? this.photos,
      resolutionPhotos: resolutionPhotos ?? this.resolutionPhotos,
      date: date ?? this.date,
      votes: votes ?? this.votes,
      reporterId: reporterId ?? this.reporterId,
      reporterType: reporterType ?? this.reporterType,
      createdAt: createdAt ?? this.createdAt,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'status': status,
    'quartier': quartier,
    'address': address,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'nearbyOrganisations': nearbyOrganisations,
    'photos': photos,
    'resolutionPhotos': resolutionPhotos,
    'date': date,
    'votes': votes,
    'reporterId': reporterId,
    'reporterType': reporterType,
    if (createdAt != null) 'createdAt': createdAt,
    'canEdit': canEdit,
    'canDelete': canDelete,
  };

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    id: json['id'].toString(),
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    status: json['status'] as String,
    quartier: json['quartier'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    nearbyOrganisations: (json['nearbyOrganisations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    photos: (json['photos'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    resolutionPhotos: (json['resolutionPhotos'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    date: json['date'] as String,
    votes: (json['votes'] as num).toInt(),
    reporterId: json['reporterId'] as String? ?? 'legacy',
    reporterType: json['reporterType'] as String? ?? 'member',
    createdAt: json['createdAt'] as String?,
    canEdit: json['canEdit'] as bool? ?? false,
    canDelete: json['canDelete'] as bool? ?? false,
  );
}
