import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_screen.dart';

class ShopScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const ShopScreen({super.key, this.initialQuery, this.initialCategory});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _query = '';
  String _category = 'All';
  String _sort = 'Featured';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _query = widget.initialQuery!;
    }
    if (widget.initialCategory != null &&
        widget.initialCategory!.isNotEmpty &&
        widget.initialCategory != 'All') {
      _category = widget.initialCategory!;
    }
  }

  List<Product> get _filtered {
    final cats = kProducts.where((p) {
      if (_category == 'All') return true;
      return p.category == _category;
    }).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      return cats.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.labels.any((l) => l.toLowerCase().contains(q));
      }).toList();
    }
    return cats;
  }

  List<Product> get _sorted {
    final list = List<Product>.from(_filtered);
    switch (_sort) {
      case 'Price low to high':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'Price high to low':
        list.sort((a, b) => b.price.compareTo(a.price));
      case 'Name A-Z':
        list.sort((a, b) => a.name.compareTo(b.name));
      default:
    }
    return list;
  }

  void _showSortSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Sort by'),
        actions: [
          _SortActionSheetItem(
            title: 'Featured',
            selected: _sort == 'Featured',
            onTap: () {
              setState(() => _sort = 'Featured');
              Navigator.of(context).pop();
            },
          ),
          _SortActionSheetItem(
            title: 'Price low to high',
            selected: _sort == 'Price low to high',
            onTap: () {
              setState(() => _sort = 'Price low to high');
              Navigator.of(context).pop();
            },
          ),
          _SortActionSheetItem(
            title: 'Price high to low',
            selected: _sort == 'Price high to low',
            onTap: () {
              setState(() => _sort = 'Price high to low');
              Navigator.of(context).pop();
            },
          ),
          _SortActionSheetItem(
            title: 'Name A-Z',
            selected: _sort == 'Name A-Z',
            onTap: () {
              setState(() => _sort = 'Name A-Z');
              Navigator.of(context).pop();
            },
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Shop'),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              child: CupertinoSearchTextField(
                placeholder: 'Search products',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final c in kCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _ShopCategoryChip(
                        label: c,
                        selected: c == _category,
                        onTap: () => setState(() => _category = c),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              child: Row(
                children: [
                  const Text(
                    'Sort:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showSortSheet(context),
                    child: Text(
                      _sort,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              child: Text(
                '${_sorted.length} result${_sorted.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_sorted.isEmpty)
              Expanded(
                child: EmptyState(
                  icon: CupertinoIcons.search,
                  title: 'No results',
                  message:
                      'Try adjusting your filters or clearing them.',
                  action: CupertinoButton(
                    color: AppColors.accent,
                    onPressed: () {
                      setState(() {
                        _category = 'All';
                        _query = '';
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPagePadding,
                  ),
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    children: [
                      for (final product in _sorted)
                        _ShopProductCard(
                          product: product,
                          onTap: () => Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) =>
                                  ProductScreen(productId: product.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShopCategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ShopCategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
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
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SortActionSheetItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SortActionSheetItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.text,
            ),
          ),
          if (selected)
            const Icon(
              CupertinoIcons.check_mark,
              color: AppColors.primary,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _ShopProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const _ShopProductCard({
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWishlisted = context.watch<Store>().isWishlisted(product.id);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ProductImage(
                imageAsset: product.imageAsset,
                height: 160,
                width: double.infinity,
                radius: kRadiusImageTile,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _HeartButton(
                  productId: product.id,
                  isWishlisted: isWishlisted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.brand,
            style: AppText.caption12.copyWith(
              color: AppColors.accent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            formatPrice(product.price),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  final int productId;
  final bool isWishlisted;

  const _HeartButton({
    required this.productId,
    required this.isWishlisted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<Store>().toggleWish(productId);
        HapticFeedback.selectionClick();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF000000).withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isWishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isWishlisted ? AppColors.danger : const Color(0xFFFFFFFF),
          size: 18,
        ),
      ),
    );
  }
}
