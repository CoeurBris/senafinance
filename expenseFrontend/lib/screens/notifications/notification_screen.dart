import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_expenses/providers/notification_provider.dart';
import 'package:app_expenses/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago; // ajoute la dépendance si tu veux un "il y a 2h"

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text('Tout marquer lu'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!),
                  TextButton(
                    onPressed: () => provider.loadNotifications(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (provider.notifications.isEmpty) {
            return const Center(child: Text('Aucune notification.'));
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(),
            child: ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final NotificationModel notif = provider.notifications[index];
                return ListTile(
                  tileColor: notif.isRead ? null : const Color(0xFFF1F8E9),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.notifications_active, color: Color(0xFF3B6334)),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(notif.body),
                  trailing: Text(
                    timeago.format(notif.createdAt, locale: 'fr'),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  onTap: () {
                    if (!notif.isRead && notif.id != null) {
                      provider.markAsRead(notif.id!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}