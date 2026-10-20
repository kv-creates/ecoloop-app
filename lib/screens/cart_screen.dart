import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onStartShopping;

  const CartScreen({super.key, this.onStartShopping});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(
      builder: (context, store, _) {
        final items = store.cart.entries.toList();
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Cart'),
          ),
          child: SafeArea(
            child: items.isEmpty
                ? EmptyState(
                    icon: CupertinoIcons.cart,
                    title: 'Your cart is empty',
                    message:
                        'Add products to your cart to check out.',
                    action: CupertinoButton(
                      color: AppColors.accent,
                      onPressed: widget.onStartShopping,
                      child: const Text(
                        'Start shopping',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final entry = items[index];
                            final product = kProducts.firstWhere(
                              (p) => p.id == entry.key,
                            );
                            return Dismissible(
                              key: ValueKey(product.id),
                              onDismissed: (_) {
                                store.remove(product.id);
                                HapticFeedback.selectionClick();
                                showAppToast(context, 'Removed');
                              },
                              background: Container(
                                color: AppColors.danger,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              child: _CartItem(
                                product: product,
                                qty: entry.value,
                                onQtyChanged: (qty) {
                                  store.setQty(product.id, qty);
                                },
                                onRemove: () {
                                  store.remove(product.id);
                                  HapticFeedback.selectionClick();
                                  showAppToast(context, 'Removed');
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      _OrderSummary(store: store),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CartItem extends StatelessWidget {
  final Product product;
  final int qty;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;

  const _CartItem({
    required this.product,
    required this.qty,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kPagePadding, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          AppShadow.soft.copyWith(spreadRadius: 0),
        ],
      ),
      child: Row(
        children: [
          ProductImage(
            imageAsset: product.imageAsset,
            height: 72,
            width: 72,
            radius: kRadiusCard,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: CupertinoIcons.minus,
                    onPressed: qty > 1 ? () => onQtyChanged(qty - 1) : null,
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.softGreenTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: CupertinoIcons.plus,
                    onPressed: qty < 10 ? () => onQtyChanged(qty + 1) : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatPrice(product.price * qty),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onRemove,
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QtyButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 20,
        color: onPressed != null ? AppColors.primary : AppColors.secondaryText,
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final Store store;

  const _OrderSummary({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPagePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.hairline),
        ),
        boxShadow: [
          AppShadow.soft.copyWith(spreadRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Subtotal', value: formatPrice(store.subtotal)),
          _SummaryRow(label: 'Shipping', value: formatPrice(store.shipping)),
          const DividerLine(),
          _SummaryRow(
            label: 'Total',
            value: formatPrice(store.total),
            bold: true,
          ),
          const SizedBox(height: 20),
          if (store.total < 999)
            _FreeShippingBar(
              subtotal: store.subtotal,
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              color: AppColors.primary,
              onPressed: store.total == 0 ? null : () => _goCheckout(context),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: CupertinoButton(
              color: AppColors.danger,
              onPressed: () => _confirmClear(context),
              child: const Text(
                'Clear cart',
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
    );
  }

  void _goCheckout(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => const CheckoutScreen(),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    return showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.of(context).pop();
              store.clearCart();
              HapticFeedback.selectionClick();
              showAppToast(context, 'Cart cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.secondaryText,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.text,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
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

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.hairline,
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }
}

class _FreeShippingBar extends StatelessWidget {
  final int subtotal;

  const _FreeShippingBar({required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final remaining = 999 - subtotal;
    final progress = (subtotal / 999).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Free delivery',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            Text(
              remaining > 0
                  ? 'Add ₹$remaining more for free delivery'
                  : 'Free delivery',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFeatures: [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(
                  color: AppColors.softGreenTint,
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
