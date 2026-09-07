class Certificate {
  final String image;

  Certificate({required this.image});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      image: json['image'] ?? '',
    );
  }
}

class DoctorProfile {
  final String nameEn;
  final String nameAr;
  final String titleEn;
  final String titleAr;
  final String infoEn;
  final String infoAr;
  final String? photo;
  final List<Certificate> certificates;

  DoctorProfile({
    required this.nameEn,
    required this.nameAr,
    required this.titleEn,
    required this.titleAr,
    required this.infoEn,
    required this.infoAr,
    this.photo,
    required this.certificates,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      infoEn: json['info_en'] ?? '',
      infoAr: json['info_ar'] ?? '',
      photo: json['photo'],
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((c) => Certificate.fromJson(c))
              .toList() ??
          [],
    );
  }
}
