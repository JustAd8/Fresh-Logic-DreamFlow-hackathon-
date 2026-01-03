import 'package:flutter/material.dart';
import 'package:fridgeflow/services/user_service.dart';
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
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text('Profile & Settings', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Profile & Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
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
            _buildSection('Personal Information', [
              _buildTextField('Name', _nameController, Icons.person),
              _buildTextField('Email', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
              _buildTextField('Age', _ageController, Icons.cake, keyboardType: TextInputType.number, required: false),
              _buildTextField('Current Location', _locationController, Icons.location_on, required: false),
            ]),
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
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
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
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
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
        fillColor: Colors.white,
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
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
        checkmarkColor: AppTheme.primaryColor,
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'FridgeFlow v1.0.0',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  );
}
