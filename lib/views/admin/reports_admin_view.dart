import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/report_model.dart';
import '../../view_models/report_view_model.dart';

class ReportsAdminView extends StatelessWidget {
  const ReportsAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: StreamBuilder<List<ReportModel>>(
            stream: context.read<ReportViewModel>().reportsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final reports = snapshot.data ?? [];
              if (reports.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có báo cáo nào',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return _buildReportCard(context, reports[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(
            'Quản lý báo cáo',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Realtime',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    final reportVM = context.read<ReportViewModel>();
    final isPending = report.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(report.status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(report.createdAt),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Lý do: ${report.reason}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Người báo cáo: ${report.reporterName}',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              'Đối tượng: ${report.targetType == 'post' ? "Bài viết" : "Người dùng"} (${report.targetId})',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildTargetPreview(context, report),
            if (isPending) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => reportVM
                        .takeModerationAction(
                          reportId: report.id,
                          targetId: report.targetId,
                          targetType: report.targetType,
                          action: 'dismiss',
                        )
                        .then((success) {
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã bỏ qua báo cáo'),
                              ),
                            );
                          }
                        }),
                    child: Text(
                      'Bỏ qua',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ),
                  const Spacer(),
                  if (report.targetType == 'post') ...[
                    ElevatedButton.icon(
                      onPressed: () => reportVM
                          .takeModerationAction(
                            reportId: report.id,
                            targetId: report.targetId,
                            targetType: report.targetType,
                            action: 'hide',
                          )
                          .then((success) {
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã ẩn bài viết')),
                              );
                            }
                          }),
                      icon: const Icon(Icons.visibility_off_outlined, size: 16),
                      label: const Text('Ẩn bài'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => reportVM
                          .takeModerationAction(
                            reportId: report.id,
                            targetId: report.targetId,
                            targetType: report.targetType,
                            action: 'delete',
                          )
                          .then((success) {
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xóa bài viết'),
                                ),
                              );
                            }
                          }),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Xóa bài'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ] else if (report.targetType == 'user') ...[
                    ElevatedButton.icon(
                      onPressed: () => reportVM
                          .takeModerationAction(
                            reportId: report.id,
                            targetId: report.targetId,
                            targetType: report.targetType,
                            action: 'block',
                          )
                          .then((success) {
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã khóa người dùng'),
                                ),
                              );
                            }
                          }),
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Khóa người dùng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTargetPreview(BuildContext context, ReportModel report) {
    final reportVM = context.read<ReportViewModel>();

    return FutureBuilder(
      future: reportVM.getTargetPreview(report.targetId, report.targetType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text(
            'Không thể tải nội dung mục tiêu',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.red[300],
              fontStyle: FontStyle.italic,
            ),
          );
        }

        final data = snapshot.data;
        if (report.targetType == 'post') {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.images != null && data.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      data.images[0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.content ?? 'Không có nội dung',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      (data.photoUrl != null && data.photoUrl.isNotEmpty)
                      ? NetworkImage(data.photoUrl)
                      : null,
                  child: (data.photoUrl == null || data.photoUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.displayName ?? 'Ẩn danh',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
