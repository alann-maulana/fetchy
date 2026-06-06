import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    Color statusColor;
    if (r.statusCode >= 200 && r.statusCode < 300) {
      statusColor = Colors.green;
    } else if (r.statusCode >= 300 && r.statusCode < 400) {
      statusColor = Colors.orange;
    } else if (r.statusCode >= 400 && r.statusCode < 500) {
      statusColor = Colors.red;
    } else if (r.statusCode >= 500) {
      statusColor = Colors.red.shade700;
    } else {
      statusColor = Colors.grey;
    }

    final statusLabel = '${r.statusCode} ${r.statusMessage}';
    final sizeStr = _formatSize(r.body?.toString().length ?? 0);
    final timeStr = '${r.responseTime}ms';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          color: theme.colorScheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withAlpha(100)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _chip(Icons.timer_outlined, timeStr, theme),
                  const SizedBox(width: 8),
                  _chip(Icons.data_usage, sizeStr, theme),
                ],
              ),
              if (widget.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.error!,
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Headers'),
                  Tab(text: 'Body'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 340,
          child: TabBarView(
            controller: _tabController,
            children: [
              _headersTab(r.headers),
              _bodyTab(r),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _headersTab(Map<String, dynamic> headers) {
    if (headers.isEmpty) {
      return const Center(child: Text('No response headers'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: headers.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  e.value.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _bodyTab(ApiResponse r) {
    final bodyStr = r.body?.toString() ?? '';
    if (bodyStr.isEmpty) return const Center(child: Text('Empty response body'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: r.isJson
          ? JsonViewer(body: bodyStr)
          : SelectableText(
              bodyStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
            ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
