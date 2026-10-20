import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _addressError;
  String? _cityError;
  String? _pinError;
  final ScrollController _scroll = ScrollController();

  bool _validate() {
    bool ok = true;
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Required' : null;
      final email = _emailController.text.trim();
      _emailError = email.isEmpty || !email.contains('@')
          ? 'Enter a valid email'
          : null;
      final phone = _phoneController.text.trim();
      _phoneError = phone.length != 10 ||
              !RegExp(r'^\d{10}$').hasMatch(phone)
          ? 'Enter 10-digit phone'
          : null;
      _addressError = _addressController.text.trim().isEmpty ? 'Required' : null;
      _cityError = _cityController.text.trim().isEmpty ? 'Required' : null;
      final pin = _pinController.text.trim();
      _pinError = pin.length != 6 ||
              !RegExp(r'^\d{6}$').hasMatch(pin)
          ? 'Enter 6-digit PIN'
          : null;
      ok = _nameError == null &&
          _emailError == null &&
          _phoneError == null &&
          _addressError == null &&
          _cityError == null &&
          _pinError == null;
    });
    if (!ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstError();
      });
    }
    return ok;
  }

  void _scrollToFirstError() {
    final errors = [
      _nameError,
      _emailError,
      _phoneError,
      _addressError,
      _cityError,
      _pinError,
    ];
    final first = errors.indexWhere((e) => e != null);
    if (first == -1) return;
    double target = first.toDouble() * 70.0;
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    if (store.cart.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Checkout'),
        ),
        child: EmptyState(
          icon: CupertinoIcons.cart,
          title: 'Your cart is empty',
          message:
              'Add products before checking out.',
          action: CupertinoButton(
            color: AppColors.accent,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Start shopping',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Checkout'),
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(kPagePadding),
            children: [
              const Text(
                'Shipping details',
                style: AppText.headline17,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cash on delivery. No payment is collected online.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              _FormFieldRow(
                controller: _nameController,
                placeholder: 'Full name',
                errorText: _nameError,
              ),
              const SizedBox(height: 12),
              _FormFieldRow(
                controller: _emailController,
                placeholder: 'Email',
                errorText: _emailError,
              ),
              const SizedBox(height: 12),
              _FormFieldRow(
                controller: _phoneController,
                placeholder: 'Phone (10 digits)',
                errorText: _phoneError,
              ),
              const SizedBox(height: 12),
              _FormFieldRow(
                controller: _addressController,
                placeholder: 'Address',
                errorText: _addressError,
              ),
              const SizedBox(height: 12),
              _FormFieldRow(
                controller: _cityController,
                placeholder: 'City',
                errorText: _cityError,
              ),
              const SizedBox(height: 12),
              _FormFieldRow(
                controller: _pinController,
                placeholder: 'PIN code (6 digits)',
                errorText: _pinError,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softGreenTint,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order total',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          formatPrice(store.total),
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
                    const SizedBox(height: 8),
                    Text(
                      '${store.count} item${store.count == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton.filled(
                  onPressed: () {
                    if (_validate()) {
                      _placeOrder(context, store);
                    }
                  },
                  child: const Text(
                    'Place order',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context, Store store) {
    store.placeOrder();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ConfirmationScreen(
          orderNumber: 'ECO-${_randomSix()}',
          subtotal: store.subtotal,
          shipping: store.shipping,
          total: store.total,
          itemCount: store.itemsBought,
          onContinueShopping: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  String _randomSix() {
    final seq = '0123456789';
    var result = '';
    for (var i = 0; i < 6; i++) {
      result += seq[(i * 7 + 3) % seq.length];
    }
    return result;
  }
}

class _FormFieldRow extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final String? errorText;

  const _FormFieldRow({
    required this.controller,
    required this.placeholder,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoFormSection(
          header: null,
          children: [
            CupertinoFormRow(
              child: CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  final int subtotal;
  final int shipping;
  final int total;
  final int itemCount;
  final VoidCallback onContinueShopping;

  const ConfirmationScreen({
    super.key,
    required this.orderNumber,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.itemCount,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Order confirmed'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AnimatedCheckIcon(),
                    const SizedBox(height: 16),
                    const Text(
                      'Order confirmed',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cash on delivery. Your order will be delivered soon.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 280,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(kRadiusCard),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ConfirmationRow(label: 'Items', value: '$itemCount'),
                          _ConfirmationRow(
                            label: 'Subtotal',
                            value: formatPrice(subtotal),
                          ),
                          _ConfirmationRow(
                            label: 'Shipping',
                            value: formatPrice(shipping),
                          ),
                          _ConfirmationRow(
                            label: 'Total',
                            value: formatPrice(total),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton.filled(
                  onPressed: onContinueShopping,
                  child: const Text(
                    'Continue shopping',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCheckIcon extends StatefulWidget {
  const AnimatedCheckIcon({super.key});

  @override
  State<AnimatedCheckIcon> createState() => _AnimatedCheckIconState();
}

class _AnimatedCheckIconState extends State<AnimatedCheckIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      transform: Matrix4.diagonal3Values(_scale.value, _scale.value, 1),
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.checkmark_seal_fill,
        color: AppColors.primary,
        size: 64,
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ConfirmationRow({
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
