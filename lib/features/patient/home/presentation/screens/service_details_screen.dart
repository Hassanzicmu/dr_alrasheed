import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/locale_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/providers/services_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/service_model.dart';
import 'package:dr_abdulaziz_al_rasheed/core/utils/auth_utils.dart';

class ServiceDetailedPage extends ConsumerWidget {
  final int serviceId;

  const ServiceDetailedPage({Key? key, required this.serviceId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: serviceAsync.when(
        data: (service) {
          if (service == null) return const Center(child: Text('Service not found'));

          final title = isAr ? service.titleAr : service.titleEn;
          final content = isAr ? service.details?.contentAr : service.details?.contentEn;
          final headerImage = service.details?.image;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: headerImage != null ? 250 : 0,
                pinned: true,
                flexibleSpace: headerImage != null
                    ? FlexibleSpaceBar(
                        background: Image.network(headerImage, fit: BoxFit.cover),
                      )
                    : null,
                title: Text(title),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content != null) ...[
                        Html(
                          data: content,
                          style: {
                            "body": Style(fontSize: FontSize(16.0), lineHeight: const LineHeight(1.5)),
                            "h1": Style(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (service.children != null && service.children!.isNotEmpty) ...[
                        Text(
                          l10n.services,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: service.children!.length,
                          itemBuilder: (context, index) {
                            final child = service.children![index];
                            final childTitle = isAr ? child.titleAr : child.titleEn;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(childTitle),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () {
                                  context.push('/service_details/${child.id}');
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
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
}
