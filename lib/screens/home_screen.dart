import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<String?>? onSearch;
  final VoidCallback? onShop;
  final ValueChanged<String>? onCategory;
  final VoidCallback? onAbout;

  const HomeScreen({
    super.key,
    this.onSearch,
    this.onShop,
    this.onCategory,
    this.onAbout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/hero.jpg'), context);
    for (int i = 1; i <= 6; i++) {
      precacheImage(
        AssetImage('assets/images/products/p${i.toString().padLeft(2, '0')}.jpg'),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('EcoLoop'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: widget.onAbout,
                child: const Icon(
                  CupertinoIcons.info_circle,
                  size: 22,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(kPagePadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to shop sustainably?',
                      style: AppText.body15.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SearchField(
                      onSubmitted: widget.onSearch,
                    ),
                    const SizedBox(height: 24),
                    _HeroCard(onShop: widget.onShop),
                    const SizedBox(height: 24),
                    SectionHeader(title: 'Categories'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final c in kCategories)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _CategoryChip(
                                label: c,
                                selected: c == 'All',
                                onTap: c == 'All'
                                    ? () {}
                                    : () => widget.onCategory?.call(c),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(title: 'Featured'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = kProducts[index % kProducts.length];
                    return _FeaturedCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => ProductScreen(productId: product.id),
                        ),
                      ),
                    );
                  },
                  childCount: 4,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 24,
                bottom: 40,
                left: kPagePadding,
                right: kPagePadding,
              ),
              sliver: SliverToBoxAdapter(
                child: _RecycleTeaserCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String?>? onSubmitted;

  const _SearchField({this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: 'Search products',
      onSubmitted: onSubmitted,
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback? onShop;

  const _HeroCard({this.onShop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusCard),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/hero.jpg',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.7),
                    AppColors.primary.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Buy better. Waste less.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep the loop going with sustainable essentials.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Color(0xFFD8E8CD),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    color: AppColors.accent,
                    onPressed: onShop,
                    child: const Text(
                      'Shop products',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  _CategoryChip({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
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

class _FeaturedCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const _FeaturedCard({
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
                height: 150,
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

class _RecycleTeaserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softGreenTint,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.refresh,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recycle right',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find verified centres near you.',
                  style: AppText.body15.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}
