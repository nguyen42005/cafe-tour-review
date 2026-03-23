import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/announcement_model.dart';
import '../../view_models/notification_admin_view_model.dart';
import '../../view_models/profile_view_model.dart';

class NotificationsAdminView extends StatefulWidget {
  const NotificationsAdminView({super.key});

  @override
  State<NotificationsAdminView> createState() => _NotificationsAdminViewState();
}

class _NotificationsAdminViewState extends State<NotificationsAdminView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'info';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationAdminViewModel>();
    final adminId = context.read<ProfileViewModel>().currentUser?.id ?? '';

    return Column(
      children: [
        _buildHeader(context, viewModel, adminId),
        Expanded(
          child: StreamBuilder<List<AnnouncementModel>>(
            stream: viewModel.announcementsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final announcements = snapshot.data ?? [];
              if (announcements.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có thông báo nào được gửi',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final item = announcements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getTypeColor(
                          item.type,
                        ).withOpacity(0.1),
                        child: Icon(
                          _getTypeIcon(item.type),
                          color: _getTypeColor(item.type),
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => viewModel.deleteAnnouncement(item.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationAdminViewModel viewModel,
    String adminId,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Thông báo hệ thống',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showSendDialog(context, viewModel, adminId),
            icon: const Icon(Icons.send),
            label: const Text('Gửi thông báo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showSendDialog(
    BuildContext context,
    NotificationAdminViewModel viewModel,
    String adminId,
  ) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Gửi thông báo mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'info', child: Text('Thông tin')),
                    DropdownMenuItem(value: 'warning', child: Text('Cảnh báo')),
                    DropdownMenuItem(
                      value: 'promotion',
                      child: Text('Khuyến mãi'),
                    ),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => _selectedType = val!),
                  decoration: const InputDecoration(
                    labelText: 'Loại thông báo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await viewModel.sendAnnouncement(
                  title: _titleController.text,
                  content: _contentController.text,
                  type: _selectedType,
                  adminId: adminId,
                );
                if (success && mounted) {
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã gửi thông báo thành công'),
                    ),
                  );
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'promotion':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'promotion':
        return Icons.campaign;
      default:
        return Icons.info_outline;
    }
  }
}
