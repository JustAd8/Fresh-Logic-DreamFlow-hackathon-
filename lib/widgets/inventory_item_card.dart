import 'package:flutter/material.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';

/// Card displaying inventory item with expiry-based visual indicators
class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  Color _getBorderColor(BuildContext context) {
    if (item.isExpired) {
      return Theme.of(context).colorScheme.error;
    } else if (item.isExpiringSoon) {
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).colorScheme.outline.withValues(alpha: 0.15);
  }

  Color _getFreshnessColor(BuildContext context) {
    switch (item.freshnessStatus) {
      case FreshnessStatus.fresh:
        return Theme.of(context).colorScheme.primaryContainer;
      case FreshnessStatus.useImmediately:
        return Colors.orange.shade100;
      case FreshnessStatus.throwAway:
        return Theme.of(context).colorScheme.errorContainer;
    }
  }

  Color _getFreshnessTextColor(BuildContext context) {
    switch (item.freshnessStatus) {
      case FreshnessStatus.fresh:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case FreshnessStatus.useImmediately:
        return Colors.orange.shade900;
      case FreshnessStatus.throwAway:
        return Theme.of(context).colorScheme.onErrorContainer;
    }
  }

  Widget _buildExpiryBadge(BuildContext context) {
    if (item.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Expired',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (item.isExpiringSoon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Use Soon',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${item.daysRemaining}d left',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _getBorderColor(context),
            width: item.isExpired || item.isExpiringSoon ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: item.imageUrl != null && item.imageUrl!.startsWith('assets/')
                            ? Image.asset(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, size: 24),
                                  ),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                child: Center(
                                  child: Text(
                                    item.imageUrl ?? '📦',
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.quantity} ${item.unit}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(item.category.displayName),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        labelStyle: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getFreshnessColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.freshnessStatus.icon,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getFreshnessTextColor(context),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.freshnessStatus.displayName,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _getFreshnessTextColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildExpiryBadge(context),
                ],
              ),
            ),
            if (item.isExpired)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'EXPIRED',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
