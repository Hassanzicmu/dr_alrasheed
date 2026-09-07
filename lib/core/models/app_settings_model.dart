class AppSettings {
  final int id;
  final String appTitle;
  final String? appLogo;
  final String? appDescription;
  final String? facebook;
  final String? instagram;
  final String? whatsapp;
  final String? linkedin;
  final String? twitter;
  final String? youtube;
  final String? tiktok;

  AppSettings({
    required this.id,
    required this.appTitle,
    this.appLogo,
    this.appDescription,
    this.facebook,
    this.instagram,
    this.whatsapp,
    this.linkedin,
    this.twitter,
    this.youtube,
    this.tiktok,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] ?? 0,
      appTitle: json['app_title'] ?? 'Doctor App',
      appLogo: json['app_logo'],
      appDescription: json['app_description'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      whatsapp: json['whatsapp'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      youtube: json['youtube'],
      tiktok: json['tiktok'],
    );
  }
}
