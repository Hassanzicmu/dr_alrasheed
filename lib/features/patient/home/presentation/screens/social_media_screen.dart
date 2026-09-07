import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMediaScreen extends ConsumerWidget {
  const SocialMediaScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Remove any non-numeric characters for the link, except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.socialMedia),
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (settings == null) {
            return const Center(child: Text('Failed to load social media links.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (settings.appLogo != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Image.network(
                        settings.appLogo!,
                        height: 100,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                if (settings.appDescription != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Text(
                      settings.appDescription!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                  title: 'WhatsApp',
                  subtitle: settings.whatsapp,
                  onTap: settings.whatsapp != null ? () => _launchWhatsApp(settings.whatsapp!) : null,
                ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF1877F2),
                  title: 'Facebook',
                  subtitle: settings.facebook,
                  onTap: settings.facebook != null ? () => _launchUrl(settings.facebook!) : null,
                ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE4405F),
                  title: 'Instagram',
                  subtitle: settings.instagram,
                  onTap: settings.instagram != null ? () => _launchUrl(settings.instagram!) : null,
                ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.twitter,
                  color: const Color(0xFF1DA1F2),
                  title: 'Twitter / X',
                  subtitle: settings.twitter,
                  onTap: settings.twitter != null ? () => _launchUrl(settings.twitter!) : null,
                ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.linkedin,
                  color: const Color(0xFF0A66C2),
                  title: 'LinkedIn',
                  subtitle: settings.linkedin,
                  onTap: settings.linkedin != null ? () => _launchUrl(settings.linkedin!) : null,
                ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.youtube,
                  color: const Color(0xFFFF0000),
                  title: 'YouTube',
                  subtitle: settings.youtube,
                  onTap: settings.youtube != null ? () => _launchUrl(settings.youtube!) : null,
                ),
                _buildSocialTile(
                  context,
                  icon: FontAwesomeIcons.tiktok,
                  color: Colors.black,
                  title: 'TikTok',
                  subtitle: settings.tiktok,
                  onTap: settings.tiktok != null ? () => _launchUrl(settings.tiktok!) : null,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSocialTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    if (subtitle == null || subtitle.isEmpty) {
      return const SizedBox.shrink(); // Don't show if not configured
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
