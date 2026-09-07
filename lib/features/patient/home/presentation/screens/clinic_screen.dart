import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/locale_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/providers/clinic_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/clinic_branch_model.dart';

class ClinicScreen extends ConsumerWidget {
  const ClinicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(clinicBranchesProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return Scaffold(
      body: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return Center(child: Text(l10n.error));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              final title = isAr ? branch.titleAr : branch.titleEn;
              final address = isAr ? branch.addressAr : branch.addressEn;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (branch.images.isNotEmpty)
                    _buildImageGallery(context, branch.images),
                  const SizedBox(height: 24),
                  _buildInfoTile(
                    context,
                    Icons.location_on,
                    l10n.location,
                    address,
                    onTap: branch.mapUrl != null ? () => _launchURL(branch.mapUrl!) : null,
                  ),
                  const SizedBox(height: 16),
                  ...branch.phones.map((phone) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildInfoTile(
                      context,
                      Icons.phone,
                      l10n.phone,
                      phone,
                      onTap: () => _launchURL('tel:$phone'),
                    ),
                  )).toList(),
                  const Divider(height: 48),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> images) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(
                    color: onTap != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
