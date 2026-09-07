class TeamMember {
  final int id;
  final String nameEn;
  final String nameAr;
  final String titleEn;
  final String titleAr;
  final String? image;

  TeamMember({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.titleEn,
    required this.titleAr,
    this.image,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      image: json['image'],
    );
  }
}
