import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/spacing.dart';
import '../config/typography.dart';
import '../models/api_response.dart';
import 'json_viewer.dart';

class ResponseViewer extends StatefulWidget {
  final ApiResponse response;
  final String? error;

  const ResponseViewer({
    super.key,
    required this.response,
    this.error,
  });

  @override
  State<ResponseViewer> createState() => _ResponseViewerState();
}

class _ResponseViewerState extends State<ResponseViewer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.response;
    final colors = Theme.of(context).colorScheme;

    final sc = r.statusCode;
    final statusColor = sc.statusColor;
    final statusLabel = '${r.statusCode} ${r.statusMessage}';
    final sizeStr = _formatSize(r.body?.toString().length ?? 0);
    final timeStr = '${r.responseTime}ms';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
          color: colors.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status row
              Row(
                children: [
                  AnimatedContainer(
                    duration: 300.ms,
                    padding: EdgeInsets.symmetric(
                        horizontal: Spacing.md, vertical: Spacing.xs),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Spacing.chipRadius),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  _chip(Icons.timer_outlined, timeStr, colors),
                  const SizedBox(width: Spacing.sm),
                  _chip(Icons.data_usage, sizeStr, colors),
                ],
              ),
              if (widget.error != null) ...[
                const SizedBox(height: Spacing.sm),
                Text(
                  widget.error!,
                  style: TextStyle(
                    color: const Color(0xFFF59E0B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: Spacing.sm),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Headers'),
                  Tab(text: 'Body'),
                ],
                labelColor: colors.primary,
                unselectedLabelColor: colors.onSurfaceVariant,
                indicatorColor: colors.primary,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 360,
          child: TabBarView(
            controller: _tabController,
            children: [
              _headersTab(r.headers, colors),
              _bodyTab(r, colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, ColorScheme colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Spacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _headersTab(Map<String, dynamic> headers, ColorScheme colors) {
    if (headers.isEmpty) {
      return Center(
        child: Text('No response headers',
            style: TextStyle(color: colors.onSurfaceVariant)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: headers.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
          child: Container(
            padding: EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(Spacing.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    e.key,
                    style: AppTextStyles.codeSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.value.toString(),
                    style:
                        AppTextStyles.codeSmall.copyWith(color: colors.onSurface),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bodyTab(ApiResponse r, ColorScheme colors) {
    final bodyStr = r.body?.toString() ?? '';
    if (bodyStr.isEmpty) {
      return Center(
        child: Text('Empty response body',
            style: TextStyle(color: colors.onSurfaceVariant)),
      );
    }

    return Container(
      color: colors.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: r.isJson
            ? JsonViewer(body: bodyStr)
            : SelectableText(
                bodyStr,
                style: AppTextStyles.code.copyWith(fontSize: 13),
              ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
