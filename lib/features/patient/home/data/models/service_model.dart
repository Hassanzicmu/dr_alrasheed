class Service {
  final int id;
  final String titleEn;
  final String titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? icon;
  final int? parentId;
  final ServiceDetail? details;
  final List<Service>? children;

  Service({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.icon,
    this.parentId,
    this.details,
    this.children,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      descriptionEn: json['description_en'],
      descriptionAr: json['description_ar'],
      icon: json['icon'],
      parentId: json['parent_id'],
      details: json['details'] != null ? ServiceDetail.fromJson(json['details']) : null,
      children: (json['children'] as List?)?.map((c) => Service.fromJson(c)).toList(),
    );
  }
}

class ServiceDetail {
  final String? image;
  final String? contentEn;
  final String? contentAr;

  ServiceDetail({this.image, this.contentEn, this.contentAr});

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      image: json['image'],
      contentEn: json['content_en'],
      contentAr: json['content_ar'],
    );
  }
}
