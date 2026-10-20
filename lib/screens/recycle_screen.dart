import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RecycleScreen extends StatefulWidget {
  const RecycleScreen({super.key});

  @override
  State<RecycleScreen> createState() => _RecycleScreenState();
}

class _RecycleScreenState extends State<RecycleScreen> {
  String _selectedType = 'All';
  String _cityQuery = '';

  List<RecycleCentre> get _filtered {
    return kRecycleCentres.where((c) {
      final typeMatch = _selectedType == 'All' || c.types.contains(_selectedType);
      final cityMatch = _cityQuery.isEmpty ||
          c.city.toLowerCase().contains(_cityQuery.toLowerCase()) ||
          c.area.toLowerCase().contains(_cityQuery.toLowerCase());
      return typeMatch && cityMatch;
    }).toList();
  }

  Widget typeChip(String label) {
    final selected = _selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: selected
              ? null
              : Border.all(color: AppColors.hairline),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFFFFFFFF)
                  : AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Open website'),
        message: const Text('Copy the link to open it in your browser.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.of(context).pop();
              HapticFeedback.selectionClick();
            },
            child: const Text('Copy link'),
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
    final filtered = _filtered;
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Recycle'),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              child: CupertinoSearchTextField(
                placeholder: 'Search by city or area',
                onChanged: (v) => setState(() => _cityQuery = v),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: kPagePadding),
              child: SectionHeader(title: 'Material type'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final t in kRecycleTypes)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: typeChip(t),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              Expanded(
                child: EmptyState(
                  icon: CupertinoIcons.location,
                  title: 'No centres found',
                  message:
                      'Try adjusting the material type or search term.',
                  action: CupertinoButton(
                    color: AppColors.accent,
                    onPressed: () {
                      setState(() {
                        _selectedType = 'All';
                        _cityQuery = '';
                      });
                    },
                    child: const Text(
                      'Clear filters',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final centre = filtered[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: kPagePadding,
                        vertical: 6,
                      ),
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
                          ProductImage(
                            imageAsset: 'assets/images/recycle/recycle_header.jpg',
                            height: 100,
                            width: double.infinity,
                            radius: 0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        centre.name,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${centre.area}, ${centre.city}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: centre.types
                                      .map(
                                        (t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.softGreenTint,
                                            borderRadius:
                                                BorderRadius.circular(
                                              kRadiusPill,
                                            ),
                                          ),
                                          child: Text(
                                            t,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: CupertinoButton(
                                    color: AppColors.primary,
                                    onPressed: () =>
                                        _openUrl(context, centre.sourceUrl),
                                    child: const Text(
                                      'Open website',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
