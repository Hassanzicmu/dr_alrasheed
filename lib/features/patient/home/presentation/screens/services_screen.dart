import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/locale_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/providers/services_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/service_model.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.services),
      ),
      body: servicesAsync.when(
        data: (services) {
          // Filter for top-level categories (parent_id == null)
          final mainServices = services.where((s) => s.parentId == null).toList();

          if (mainServices.isEmpty) {
            return const Center(child: Text('No services found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: mainServices.length,
            itemBuilder: (context, index) {
              final service = mainServices[index];
              final title = isAr ? service.titleAr : service.titleEn;
              final desc = isAr ? service.descriptionAr : service.descriptionEn;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: service.icon != null
                      ? Image.network(service.icon!, width: 40, height: 40)
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.medical_services, color: Theme.of(context).colorScheme.primary),
                        ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: desc != null ? Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/service_details/${service.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
