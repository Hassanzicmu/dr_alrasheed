class ClinicBranch {
  final int id;
  final String titleEn;
  final String titleAr;
  final String addressEn;
  final String addressAr;
  final String? mapUrl;
  final List<String> phones;
  final List<String> images;

  ClinicBranch({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.addressEn,
    required this.addressAr,
    this.mapUrl,
    required this.phones,
    required this.images,
  });

  factory ClinicBranch.fromJson(Map<String, dynamic> json) {
    return ClinicBranch(
      id: json['id'],
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      addressEn: json['address_en'] ?? '',
      addressAr: json['address_ar'] ?? '',
      mapUrl: json['map_url'],
      phones: (json['phones'] as List?)?.map((p) => p['number'] as String).toList() ?? [],
      images: (json['images'] as List?)?.map((i) => i as String).toList() ?? [],
    );
  }
}
