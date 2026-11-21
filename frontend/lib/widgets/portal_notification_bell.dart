import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../services/api_service.dart';

class PortalNotificationBell extends StatefulWidget {
  final String role;
  const PortalNotificationBell({super.key, required this.role});

  @override
  State<PortalNotificationBell> createState() => _PortalNotificationBellState();
}

class _PortalNotificationBellState extends State<PortalNotificationBell> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _notifications = [];
  int _unread = 0;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final values = await Future.wait([
        _api.getNotifications(),
        _api.getUnreadNotificationCount(),
      ]);
      if (mounted) {
        setState(() {
          _notifications = values[0] as List<Map<String, dynamic>>;
          _unread = values[1] as int;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    try {
      if (item['read'] != true) await _api.markNotificationRead(item['id'].toString());
      await _refresh();
      if (!mounted) return;
      final page = item['targetType'] == 'ANNOUNCEMENT' ? 'announcements' : 'leaves';
      context.read<NavigationProvider>().navigateTo(
        '${widget.role}-$page',
        {'targetId': item['targetId']?.toString()},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<Map<String, dynamic>>(
        tooltip: 'Notifications${_unread > 0 ? ' ($_unread unread)' : ''}',
        onOpened: _refresh,
        onSelected: _open,
        itemBuilder: (context) {
          if (_notifications.isEmpty) {
            return [
              PopupMenuItem<Map<String, dynamic>>(
                enabled: false,
                child: SizedBox(
                  width: 260,
                  child: Text(_error == null ? 'No notifications yet.' : 'Could not load notifications: $_error'),
                ),
              ),
            ];
          }
          return _notifications.take(8).map((item) => PopupMenuItem<Map<String, dynamic>>(
                value: item,
                child: SizedBox(
                  width: 280,
                  child: Row(
                    children: [
                      Icon(item['read'] == true ? Icons.notifications_none : Icons.notifications_active_outlined,
                          color: item['read'] == true ? AppColors.textMuted : AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['message']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: item['read'] == true ? FontWeight.normal : FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList();
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textMuted),
              if (_unread > 0)
                Positioned(
                  right: -7,
                  top: -7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        _unread > 99 ? '99+' : '$_unread',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
