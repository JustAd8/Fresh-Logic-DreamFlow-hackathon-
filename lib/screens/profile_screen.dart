import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/theme_service.dart';
import 'package:fridgeflow/theme.dart';
import 'package:fridgeflow/utils/responsive_layout.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedLanguage = 'en';
  String _selectedRegion = 'IN';
  String _selectedCurrency = 'INR';
  List<String> _dietaryPreferences = [];
  List<String> _allergies = [];
  
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  int _adminTapCount = 0;

  final List<String> _availableLanguages = ['en', 'hi', 'ta', 'te', 'bn', 'mr', 'gu', 'kn', 'ml', 'pa'];
  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'bn': 'বাংলা (Bengali)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
  };

  final List<String> _availableRegions = ['IN', 'US', 'UK', 'CA', 'AU'];
  final Map<String, String> _regionNames = {
    'IN': 'India',
    'US': 'United States',
    'UK': 'United Kingdom',
    'CA': 'Canada',
    'AU': 'Australia',
  };

  final List<String> _availableCurrencies = ['INR', 'USD', 'GBP', 'EUR', 'CAD', 'AUD'];
  final Map<String, String> _currencySymbols = {
    'INR': '₹',
    'USD': '\$',
    'GBP': '£',
    'EUR': '€',
    'CAD': 'C\$',
    'AUD': 'A\$',
  };

  final List<String> _dietaryOptions = ['Vegetarian', 'Vegan', 'Gluten-Free', 'Lactose-Free', 'Jain', 'Halal'];
  final List<String> _allergyOptions = ['Nuts', 'Dairy', 'Eggs', 'Soy', 'Wheat', 'Shellfish', 'Fish'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await UserService().initialize();
      final user = UserService().currentUser;
      
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _ageController.text = user.age?.toString() ?? '';
          _locationController.text = user.currentLocation ?? '';
          _selectedLanguage = user.language;
          _selectedRegion = user.region;
          _selectedCurrency = user.currency;
          _dietaryPreferences = List.from(user.dietaryPreferences);
          _allergies = List.from(user.allergies);
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = UserService().currentUser;
      if (user == null) return;

      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        language: _selectedLanguage,
        region: _selectedRegion,
        currency: _selectedCurrency,
        currentLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        dietaryPreferences: _dietaryPreferences,
        allergies: _allergies,
      );

      await UserService().updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Profile & Settings', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Profile & Settings', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: ResponsiveLayout.centerConstrainedContent(
        context,
        maxWidth: 800,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: ResponsiveLayout.getHorizontalPadding(context).copyWith(
              top: ResponsiveLayout.getSpacing(context, mobile: 16),
              bottom: ResponsiveLayout.getSpacing(context, mobile: 16),
            ),
            children: [
            _buildProfilePhotoSection(),
            const SizedBox(height: 24),
            _buildSection('Personal Information', [
              _buildTextField('Name', _nameController, Icons.person),
              _buildTextField('Email', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
              _buildTextField('Age', _ageController, Icons.cake, keyboardType: TextInputType.number, required: false),
              _buildTextField('Current Location', _locationController, Icons.location_on, required: false),
            ]),
            const SizedBox(height: 24),
            _buildThemeSection(),
            const SizedBox(height: 24),
            _buildSection('Regional Settings', [
              _buildDropdown('Language', _selectedLanguage, _availableLanguages, _languageNames, (val) => setState(() => _selectedLanguage = val!)),
              _buildDropdown('Region', _selectedRegion, _availableRegions, _regionNames, (val) => setState(() => _selectedRegion = val!)),
              _buildDropdown('Currency', _selectedCurrency, _availableCurrencies, _currencySymbols, (val) => setState(() => _selectedCurrency = val!)),
            ]),
            const SizedBox(height: 24),
            _buildSection('Dietary Preferences', [
              _buildChipSelection(_dietaryOptions, _dietaryPreferences, (prefs) => setState(() => _dietaryPreferences = prefs)),
            ]),
            const SizedBox(height: 24),
            _buildSection('Allergies & Restrictions', [
              _buildChipSelection(_allergyOptions, _allergies, (allergies) => setState(() => _allergies = allergies)),
            ]),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildAdminAccessButton(),
            const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(height: 12),
      ...children,
    ],
  );

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool required = true, TextInputType? keyboardType}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: required ? (val) => val?.trim().isEmpty ?? true ? '$label is required' : null : null,
    ),
  );

  Widget _buildDropdown(String label, String value, List<String> options, Map<String, String> names, ValueChanged<String?> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(names[opt] ?? opt))).toList(),
      onChanged: onChanged,
    ),
  );

  Widget _buildChipSelection(List<String> options, List<String> selectedItems, ValueChanged<List<String>> onChanged) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: options.map((option) {
      final isSelected = selectedItems.contains(option);
      return FilterChip(
        label: Text(option),
        selected: isSelected,
        onSelected: (isNowSelected) {
          final newList = List<String>.from(selectedItems);
          if (isNowSelected) {
            newList.add(option);
          } else {
            newList.remove(option);
          }
          onChanged(newList);
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.primary,
      );
    }).toList(),
  );

  Widget _buildStatsCard() {
    final user = UserService().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          const Text('Your Impact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Saved', '${_currencySymbols[_selectedCurrency]}${user.totalMoneySaved.toStringAsFixed(0)}'),
              _buildStatItem('Member Since', _formatDate(user.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
    ],
  );

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildProfilePhotoSection() {
    final user = UserService().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null || user.photoUrl!.isEmpty
                ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimaryContainer)
                : null,
          ),
          if (_isUploadingPhoto)
            Positioned.fill(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                if (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                  IconButton(
                    onPressed: _deletePhoto,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _uploadPhoto,
                  icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isUploadingPhoto = true);

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        throw Exception('Failed to read file bytes');
      }

      final photoUrl = await UserService().uploadProfilePhoto(bytes, file.name);

      if (photoUrl != null) {
        final user = UserService().currentUser;
        if (user != null) {
          final updatedUser = user.copyWith(photoUrl: photoUrl);
          await UserService().updateUser(updatedUser);

          setState(() {});

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile photo updated successfully'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Photo upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isUploadingPhoto = true);
      await UserService().deleteProfilePhoto();
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo deleted'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Photo delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Widget _buildThemeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            _buildThemeOption('Light Mode', ThemeMode.light, Icons.light_mode),
            const Divider(),
            _buildThemeOption('Dark Mode', ThemeMode.dark, Icons.dark_mode),
            const Divider(),
            _buildThemeOption('System Default', ThemeMode.system, Icons.brightness_auto),
          ],
        ),
      ),
    ],
  );

  Widget _buildThemeOption(String label, ThemeMode mode, IconData icon) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final isSelected = themeService.themeMode == mode;

    return InkWell(
      onTap: () async {
        await themeService.setThemeMode(mode);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme changed to $label'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminAccessButton() => GestureDetector(
    onTap: () {
      setState(() => _adminTapCount++);
      if (_adminTapCount >= 7) {
        _adminTapCount = 0;
        context.push('/admin');
      }
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(
            'FridgeFlow v1.0.0',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    ),
  );
}
