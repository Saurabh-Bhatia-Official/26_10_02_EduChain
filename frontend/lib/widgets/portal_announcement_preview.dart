import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../services/api_service.dart';

class PortalAnnouncementPreview extends StatefulWidget {
  final String role;
  const PortalAnnouncementPreview({super.key, required this.role});

  @override
  State<PortalAnnouncementPreview> createState() => _PortalAnnouncementPreviewState();
}

class _PortalAnnouncementPreviewState extends State<PortalAnnouncementPreview> {
  late Future<List<Map<String, dynamic>>> _announcements;

  @override
  void initState() {
    super.initState();
    _announcements = ApiService().getAnnouncements();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcements,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Announcements could not be loaded: ${snapshot.error}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final items = snapshot.data!
              .where((item) => item['published'] == true)
              .take(2)
              .toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Latest announcements', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    TextButton(
                      onPressed: () => context.read<NavigationProvider>().navigateTo('${widget.role}-announcements'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                ...items.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        item['read'] == true ? Icons.campaign_outlined : Icons.mark_email_unread_outlined,
                        color: item['read'] == true ? AppColors.textMuted : AppColors.primary,
                      ),
                      title: Text(item['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${item['description'] ?? ''}\n${item['announcementDate'] ?? ''} • ${item['publisher'] ?? 'Admin'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => context.read<NavigationProvider>().navigateTo('${widget.role}-announcements'),
                    )),
              ],
            ),
          );
        },
      );
}
