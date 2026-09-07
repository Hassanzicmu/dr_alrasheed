import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/locale_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/doctor_profile/providers/doctor_profile_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/doctor_profile/data/models/doctor_profile_model.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/core/utils/auth_utils.dart';

class DoctorDetailsScreen extends ConsumerWidget {
  const DoctorDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorProfileAsync = ref.watch(doctorProfileProvider);
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutDoctor),
      ),
      body: doctorProfileAsync.when(
        data: (profile) {
          final name = isAr ? profile.nameAr : profile.nameEn;
          final title = isAr ? profile.titleAr : profile.titleEn;
          final info = isAr ? profile.infoAr : profile.infoEn;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, name, title, profile.photo, l10n),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Html(data: info),
                ),
                if (profile.certificates.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, l10n.certificates),
                  _buildCertificatesGallery(context, profile.certificates),
                ],
                const SizedBox(height: 120),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              performActionWithAuthCheck(context, ref, () {
                context.push('/book_appointment');
              });
            },
            child: Text(l10n.bookAppointment),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String title, String? photoUrl, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              image: photoUrl != null ? DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              ) : const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/300?img=47'),
                fit: BoxFit.cover,
              )
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text(l10n.reviewsCount, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildCertificatesGallery(BuildContext context, List<Certificate> certificates) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(16),
                  child: InteractiveViewer(
                    child: Image.network(cert.image, fit: BoxFit.contain),
                  ),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                image: DecorationImage(
                  image: NetworkImage(cert.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
