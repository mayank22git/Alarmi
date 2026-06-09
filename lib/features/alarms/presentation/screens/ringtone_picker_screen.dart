import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/ringtone_service.dart';
import '../../../../core/constants/app_colors.dart';

class RingtonePickerScreen extends ConsumerStatefulWidget {
  final String currentPath;
  const RingtonePickerScreen({super.key, required this.currentPath});

  @override
  ConsumerState<RingtonePickerScreen> createState() => _RingtonePickerScreenState();
}

class _RingtonePickerScreenState extends ConsumerState<RingtonePickerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<RingtoneModel> _systemRingtones = [];
  List<RingtoneModel> _filteredSystem = [];
  
  final List<RingtoneModel> _assetRingtones = [
    RingtoneModel(title: 'Default', path: 'assets/audio/Ringing.mp3', source: RingtoneSource.asset),
    RingtoneModel(title: 'EMERGENCY', path: 'assets/audio/EMERGENCY.mp3', source: RingtoneSource.asset),
    RingtoneModel(title: 'Melody', path: 'assets/audio/Melody.mp3', source: RingtoneSource.asset),


  ];
  
  String? _previewingPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSystemRingtones();
  }

  Future<void> _loadSystemRingtones() async {
    final ringtones = await ref.read(ringtoneServiceProvider).getSystemRingtones(4); // 4 = TYPE_ALARM
    if (mounted) {
      setState(() {
        _systemRingtones = ringtones;
        _filteredSystem = ringtones;
        _isLoading = false;
      });
    }
  }

  void _filter(String query) {
    setState(() {
      _filteredSystem = _systemRingtones
          .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    ref.read(ringtoneServiceProvider).stopPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ringtone'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'System'),
            Tab(text: 'Built-in'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search ringtones...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSystemList(),
                _buildAssetList(),
              ],
            ),
          ),
          _buildCustomAction(),
        ],
      ),
    );
  }

  Widget _buildSystemList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: _filteredSystem.length,
      itemBuilder: (context, index) {
        final ringtone = _filteredSystem[index];
        return _buildRingtoneTile(ringtone);
      },
    );
  }

  Widget _buildAssetList() {
    return ListView.builder(
      itemCount: _assetRingtones.length,
      itemBuilder: (context, index) {
        final ringtone = _assetRingtones[index];
        return _buildRingtoneTile(ringtone);
      },
    );
  }

  Widget _buildRingtoneTile(RingtoneModel ringtone) {
    final isSelected = widget.currentPath == ringtone.path;
    final isPreviewing = _previewingPath == ringtone.path;

    return ListTile(
      title: Text(ringtone.title),
      leading: Radio<String>(
        value: ringtone.path,
        groupValue: widget.currentPath,
        onChanged: (_) => Navigator.pop(context, ringtone),
      ),
      trailing: IconButton(
        icon: Icon(isPreviewing ? Icons.stop_circle : Icons.play_circle_outline),
        onPressed: () async {
          if (isPreviewing) {
            await ref.read(ringtoneServiceProvider).stopPreview();
            setState(() => _previewingPath = null);
          } else {
            setState(() => _previewingPath = ringtone.path);
            await ref.read(ringtoneServiceProvider).previewRingtone(ringtone.path, ringtone.source);
          }
        },
      ),
      onTap: () => Navigator.pop(context, ringtone),
    );
  }

  Widget _buildCustomAction() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
          final custom = await ref.read(ringtoneServiceProvider).pickCustomRingtone();
          if (custom != null && mounted) {
            Navigator.pop(context, custom);
          }
        },
        icon: const Icon(Icons.add_to_drive),
        label: const Text('Add from device'),
      ),
    );
  }
}
