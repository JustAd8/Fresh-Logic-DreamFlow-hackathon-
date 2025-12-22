import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/inventory_service.dart';
import 'package:fridgeflow/services/food_scan_service.dart';
import 'package:fridgeflow/services/compost_classifier_service.dart';
import 'package:fridgeflow/widgets/inventory_item_card.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';
import 'package:fridgeflow/theme.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final _userService = UserService();
  final _inventoryService = InventoryService();
  final _foodScanService = FoodScanService();
  final _compostClassifier = CompostClassifierService();
  final _imagePicker = ImagePicker();

  List<InventoryItem> _items = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final user = _userService.currentUser;
      if (user != null) {
        _items = _inventoryService.getSortedByExpiry(user.id);
      }
    } catch (e) {
      debugPrint('Error loading items: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _simulateIoTSync() async {
    final user = _userService.currentUser;
    if (user == null) return;

    setState(() => _isSyncing = true);

    try {
      await _inventoryService.simulateIoTSync(user.id);
      await _loadItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('IoT sync complete! 5 items added'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _deleteItem(InventoryItem item) async {
    try {
      await _inventoryService.deleteItem(item.id);
      await _loadItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _scanFoodItem() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isScanning = true);

      final result = await _foodScanService.analyzeImage(image.path);

      if (mounted) {
        setState(() => _isScanning = false);
      }

      if (!result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to scan item'),
              backgroundColor: result['isProhibited'] == true 
                ? Theme.of(context).colorScheme.error 
                : null,
            ),
          );
        }
        return;
      }

      if (mounted) {
        _showAddItemDialog(
          prefillName: result['itemName'],
          prefillCategory: result['category'],
          prefillFreshnessStatus: result['freshnessStatus'],
          prefillExpiryDays: result['expiryDays'],
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning: $e')),
        );
      }
    }
  }

  Future<void> _checkCompostOrCook() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isScanning = true);

      final result = await _compostClassifier.analyzeProduceSafety(image.path);

      if (mounted) {
        setState(() => _isScanning = false);
      }

      if (!result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to analyze produce')),
          );
        }
        return;
      }

      if (mounted) {
        _showCompostOrCookResult(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing: $e')),
        );
      }
    }
  }

  void _showCompostOrCookResult(Map<String, dynamic> result) {
    final safety = result['safety'] as ProduceSafety;
    final produceName = result['produceName'] as String;
    final recommendation = result['recommendation'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: safety == ProduceSafety.safeToEat
                    ? Theme.of(context).colorScheme.primaryContainer
                    : safety == ProduceSafety.risky
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                safety.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                safety.displayName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produceName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog({
    String? prefillName,
    FoodCategory? prefillCategory,
    FreshnessStatus? prefillFreshnessStatus,
    int? prefillExpiryDays,
  }) {
    final nameController = TextEditingController(text: prefillName);
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'units');
    var selectedCategory = prefillCategory ?? FoodCategory.other;
    var selectedFreshnessStatus = prefillFreshnessStatus ?? FreshnessStatus.fresh;
    var expiryDays = prefillExpiryDays ?? 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add Item',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FoodCategory>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: FoodCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FreshnessStatus>(
                  value: selectedFreshnessStatus,
                  decoration: InputDecoration(
                    labelText: 'Freshness Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: FreshnessStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Text(status.icon),
                          const SizedBox(width: 8),
                          Text(status.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => selectedFreshnessStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Expires in: $expiryDays days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: expiryDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$expiryDays days',
                  onChanged: (value) {
                    setModalState(() => expiryDays = value.toInt());
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) return;

                          final user = _userService.currentUser;
                          if (user == null) return;

                          final now = DateTime.now();
                          final newItem = InventoryItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: user.id,
                            itemName: nameController.text.trim(),
                            quantity: int.tryParse(quantityController.text) ?? 1,
                            unit: unitController.text.trim(),
                            purchaseDate: now,
                            expiryDate: now.add(Duration(days: expiryDays)),
                            category: selectedCategory,
                            freshnessStatus: selectedFreshnessStatus,
                            imageUrl: _foodScanService.getSuggestedEmoji(selectedCategory),
                            createdAt: now,
                            updatedAt: now,
                          );

                          await _inventoryService.addItem(newItem);
                          await _loadItems();
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item added!')),
                            );
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pantry'),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'scan') {
                  _scanFoodItem();
                } else if (value == 'compost') {
                  _checkCompostOrCook();
                } else if (value == 'add') {
                  _showAddItemDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'scan',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 12),
                      Text('Scan to Add'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'compost',
                  child: Row(
                    children: [
                      Icon(Icons.eco),
                      SizedBox(width: 12),
                      Text('Compost or Cook?'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 12),
                      Text('Add Manually'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.kitchen_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add items or sync with IoT',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadItems,
                  child: GridView.builder(
                    padding: AppSpacing.paddingMd,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return InventoryItemCard(
                        item: item,
                        onDelete: () => _deleteItem(item),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSyncing ? null : _simulateIoTSync,
        icon: _isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.sync),
        label: Text(_isSyncing ? 'Syncing...' : 'IoT Sync'),
      ),
    );
  }
}
