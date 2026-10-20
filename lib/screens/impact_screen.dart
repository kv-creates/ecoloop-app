import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _quantityError;
  String _selectedUnit = 'kg';
  String _selectedMaterial = 'Paper';

  @override
  void dispose() {
    _materialController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _showAddEntrySheet(BuildContext context, Store store) {
    _materialController.text = '';
    _quantityController.text = '';
    _quantityError = null;
    _selectedUnit = 'kg';
    _selectedMaterial = 'Paper';

    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Add recycling entry'),
        message: const Text(
          'Log the materials you recycled this month.',
        ),
        actions: [
          _MaterialPicker(
            value: _selectedMaterial,
            onChanged: (v) => setState(() => _selectedMaterial = v!),
          ),
          const SizedBox(height: 12),
          _QuantityField(
            controller: _quantityController,
            errorText: _quantityError,
          ),
          const SizedBox(height: 12),
          _UnitPicker(
            value: _selectedUnit,
            onChanged: (v) => setState(() => _selectedUnit = v!),
          ),
          const SizedBox(height: 12),
          CupertinoActionSheetAction(
            onPressed: () {
              final qty = double.tryParse(_quantityController.text);
              if (qty == null || qty <= 0) {
                setState(() => _quantityError = 'Enter a valid quantity');
                return;
              }
              store.addRecycleEntry(_selectedMaterial, qty, _selectedUnit);
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: const Text('Log entry'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(
      builder: (context, store, _) {
        final monthly = store.monthlyRecycled;
        final totalKg = store.totalRecycledKg;

        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Impact'),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(kPagePadding),
              children: [
                const Text(
                  'Your impact',
                  style: AppText.title22,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ImpactStatCard(
                        title: 'Orders placed',
                        value: '${store.ordersPlaced}',
                        icon: CupertinoIcons.cart,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ImpactStatCard(
                        title: 'Items bought',
                        value: '${store.itemsBought}',
                        icon: CupertinoIcons.bag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ImpactStatCard(
                        title: 'Wishlist',
                        value: '${store.wishlist.length}',
                        icon: CupertinoIcons.heart,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ImpactStatCard(
                        title: 'Recycled (kg)',
                        value: totalKg.toStringAsFixed(1),
                        icon: CupertinoIcons.refresh,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Monthly recycling log'),
                const SizedBox(height: 12),
                if (monthly.isEmpty)
                  const Center(
                    child: Text(
                      'No recycling entries logged yet.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  )
                else
                  _MonthlyBarChart(monthly: monthly),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton.filled(
                    onPressed: () =>
                        _showAddEntrySheet(context, store),
                    child: const Text(
                      'Add recycling entry',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: AppColors.primary,
                    onPressed: () => _showAddEntrySheet(context, store),
                    child: const Text(
                      'Add recycling entry',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Recent entries'),
                const SizedBox(height: 12),
                if (store.recycleLog.isEmpty)
                  const Center(
                    child: Text(
                      'No entries yet.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  )
                else
                  ...store.recycleLog.take(5).map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.refresh,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.materialType,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${entry.quantity.toStringAsFixed(1)} ${entry.unit}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.secondaryText,
                              fontFeatures: [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImpactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ImpactStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          AppShadow.soft.copyWith(spreadRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final Map<String, double> monthly;

  const _MonthlyBarChart({required this.monthly});

  @override
  Widget build(BuildContext context) {
    final entries = monthly.entries.toList();
    final max = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    _monthLabel(entry.key),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 16,
                          child: Stack(
                            children: [
                              Container(
                                color: AppColors.softGreenTint,
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                    (entry.value / max).clamp(0.0, 1.0),
                                child: Container(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.value.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFeatures: [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _monthLabel(String key) {
    final parts = key.split('-');
    if (parts.length == 2) {
      final month = int.tryParse(parts[1]) ?? 1;
      const names = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return names[month - 1];
    }
    return key;
  }
}

class _MaterialPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _MaterialPicker({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final materials = ['Paper', 'Plastic', 'Glass', 'Metal', 'Textiles', 'E-waste', 'Batteries'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Material',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoSegmentedControl<String>(
          children: {
            for (final m in materials)
              m: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  m,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          },
          groupValue: value,
          onValueChanged: onChanged,
        ),
      ],
    );
  }
}

class _QuantityField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const _QuantityField({
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: '0',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _UnitPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _UnitPicker({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unit',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoSegmentedControl<String>(
          children: {
            'kg': const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('kg'),
            ),
            'items': const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('items'),
            ),
          },
          groupValue: value,
          onValueChanged: onChanged,
        ),
      ],
    );
  }
}
