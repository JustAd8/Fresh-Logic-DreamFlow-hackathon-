import 'package:flutter/material.dart';
import 'package:fridgeflow/services/admin_export_service.dart';
import 'package:fridgeflow/theme.dart';
import 'package:fridgeflow/utils/responsive_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _passwordController = TextEditingController();
  final _adminService = AdminExportService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  Map<String, int>? _stats;
  
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _adminService.getDatabaseStats();
      setState(() => _stats = stats);
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  void _authenticate() {
    final password = _passwordController.text.trim();
    if (_adminService.validatePassword(password)) {
      setState(() => _isAuthenticated = true);
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication successful'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportData(String type) async {
    setState(() => _isLoading = true);
    
    try {
      String csvData = '';
      String filename = '';
      
      switch (type) {
        case 'users':
          csvData = await _adminService.exportUsersToCSV();
          filename = 'fridgeflow_users_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'inventory':
          csvData = await _adminService.exportInventoryToCSV();
          filename = 'fridgeflow_inventory_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'community':
          csvData = await _adminService.exportCommunityListingsToCSV();
          filename = 'fridgeflow_community_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'all':
          await _exportAllData();
          return;
      }

      if (csvData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No $type data found to export'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Generate download URL and trigger download
      final dataUrl = _adminService.downloadCSV(csvData, filename);
      await _triggerDownload(dataUrl, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type data exported successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAllData() async {
    try {
      final allData = await _adminService.exportAllData();
      
      for (final entry in allData.entries) {
        if (entry.value.isNotEmpty) {
          final filename = 'fridgeflow_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.csv';
          final dataUrl = _adminService.downloadCSV(entry.value, filename);
          await _triggerDownload(dataUrl, filename);
          // Small delay between downloads
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Export all error: $e');
      rethrow;
    }
  }

  Future<void> _triggerDownload(String dataUrl, String filename) async {
    try {
      final uri = Uri.parse(dataUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, webOnlyWindowName: '_blank');
      }
    } catch (e) {
      debugPrint('Download trigger error: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: const Text(
          '🔒 Admin Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveLayout.centerConstrainedContent(
        context,
        maxWidth: 900,
        child: _isAuthenticated ? _buildAdminDashboard() : _buildLoginScreen(),
      ),
    );
  }

  Widget _buildLoginScreen() => Center(
    child: SingleChildScrollView(
      padding: ResponsiveLayout.getHorizontalPadding(context).copyWith(
        top: ResponsiveLayout.getSpacing(context, mobile: 40),
        bottom: ResponsiveLayout.getSpacing(context, mobile: 40),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.red.shade900),
            const SizedBox(height: 24),
            const Text(
              'Admin Access',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter admin password to access data export',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Admin Password',
                prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onSubmitted: (_) => _authenticate(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Authenticate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⚠️ Admin access only',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildAdminDashboard() => ListView(
    padding: ResponsiveLayout.getHorizontalPadding(context).copyWith(
      top: ResponsiveLayout.getSpacing(context, mobile: 24),
      bottom: ResponsiveLayout.getSpacing(context, mobile: 24),
    ),
    children: [
      _buildWelcomeCard(),
      const SizedBox(height: 24),
      _buildStatsSection(),
      const SizedBox(height: 24),
      _buildExportSection(),
      const SizedBox(height: 24),
      _buildWarningCard(),
    ],
  );

  Widget _buildWelcomeCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.red.shade900, Colors.red.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
      ],
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_user, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Export all user data in CSV format for analysis and backup purposes.',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    ),
  );

  Widget _buildStatsSection() {
    if (_stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        ),
      );
    }

    final gridColumns = ResponsiveLayout.getGridColumns(context, mobile: 1, tablet: 3, desktop: 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Database Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (gridColumns == 1) {
              return Column(
                children: [
                  _buildStatCard('Total Users', _stats!['users']!, Icons.people, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatCard('Inventory Items', _stats!['inventory']!, Icons.inventory, Colors.green),
                  const SizedBox(height: 12),
                  _buildStatCard('Community Listings', _stats!['community_listings']!, Icons.share, Colors.orange),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildStatCard('Total Users', _stats!['users']!, Icons.people, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Inventory Items', _stats!['inventory']!, Icons.inventory, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Community Listings', _stats!['community_listings']!, Icons.share, Colors.orange)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
    ),
    child: Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 12),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textColor)),
      ],
    ),
  );

  Widget _buildExportSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Export Data',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
      ),
      const SizedBox(height: 16),
      _buildExportButton('Export Users Data', 'users', Icons.people, Colors.blue),
      const SizedBox(height: 12),
      _buildExportButton('Export Inventory Data', 'inventory', Icons.inventory, Colors.green),
      const SizedBox(height: 12),
      _buildExportButton('Export Community Listings', 'community', Icons.share, Colors.orange),
      const SizedBox(height: 20),
      _buildExportButton('Export All Data', 'all', Icons.download, Colors.red.shade900, isHighlighted: true),
    ],
  );

  Widget _buildExportButton(String label, String type, IconData icon, Color color, {bool isHighlighted = false}) => SizedBox(
    width: double.infinity,
    height: isHighlighted ? 60 : 50,
    child: ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _exportData(type),
      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon),
      label: Text(label, style: TextStyle(fontSize: isHighlighted ? 16 : 14, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isHighlighted ? color : color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isHighlighted ? 4 : 2,
      ),
    ),
  );

  Widget _buildWarningCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.amber.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.amber.shade700, width: 2),
    ),
    child: Row(
      children: [
        Icon(Icons.warning, color: Colors.amber.shade900, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Privacy Notice',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
              ),
              const SizedBox(height: 4),
              Text(
                'Exported data contains sensitive user information. Handle with care and ensure compliance with data protection regulations.',
                style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
