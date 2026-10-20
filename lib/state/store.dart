import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data.dart';

class Store extends ChangeNotifier {
  Store() {
    _load();
  }

  final Map<int, int> _cart = {};
  final Set<int> _wishlist = {};
  final List<RecycleLogEntry> _recycleLog = [];
  int _ordersPlaced = 0;
  int _itemsBought = 0;

  bool _initialized = false;

  bool get initialized => _initialized;
  Map<int, int> get cart => Map.unmodifiable(_cart);
  Set<int> get wishlist => Set.unmodifiable(_wishlist);
  List<RecycleLogEntry> get recycleLog => List.unmodifiable(_recycleLog);
  int get ordersPlaced => _ordersPlaced;
  int get itemsBought => _itemsBought;

  int get count => _cart.values.fold<int>(0, (sum, v) => sum + v);

  int get subtotal {
    int total = 0;
    for (final entry in _cart.entries) {
      final product = kProducts.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => kProducts.first,
      );
      total += product.price * entry.value;
    }
    return total;
  }

  int get shipping {
    if (subtotal == 0 || subtotal >= 999) return 0;
    return 49;
  }

  int get total => subtotal + shipping;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      if (cartJson != null) {
        final decoded = jsonDecode(cartJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final id = int.tryParse(entry.key);
          final qty = (entry.value as num).toInt();
          if (id != null && kProducts.any((p) => p.id == id)) {
            _cart[id] = qty.clamp(1, 10);
          }
        }
      }
      final wishJson = prefs.getString('wishlist');
      if (wishJson != null) {
        final decoded = jsonDecode(wishJson) as List<dynamic>;
        for (final value in decoded) {
          final id = int.tryParse(value.toString());
          if (id != null && kProducts.any((p) => p.id == id)) {
            _wishlist.add(id);
          }
        }
      }
      final logJson = prefs.getString('recycle_log');
      if (logJson != null) {
        final decoded = jsonDecode(logJson) as List<dynamic>;
        for (final value in decoded) {
          final map = value as Map<String, dynamic>;
          _recycleLog.add(RecycleLogEntry(
            id: map['id'] as String,
            materialType: map['materialType'] as String,
            quantity: (map['quantity'] as num).toDouble(),
            unit: map['unit'] as String,
            date: DateTime.parse(map['date'] as String),
          ));
        }
      }
      _ordersPlaced = prefs.getInt('orders_placed') ?? 0;
      _itemsBought = prefs.getInt('items_bought') ?? 0;
    } catch (_) {
      // Ignore persistence errors; start with empty state.
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        _cart.map((key, value) => MapEntry(key.toString(), value)),
      );
      await prefs.setString('cart', cartJson);
      await prefs.setString('wishlist', jsonEncode(_wishlist.toList()));
      await prefs.setString(
        'recycle_log',
        jsonEncode(_recycleLog.map((e) => {
              'id': e.id,
              'materialType': e.materialType,
              'quantity': e.quantity,
              'unit': e.unit,
              'date': e.date.toIso8601String(),
            }).toList()),
      );
      await prefs.setInt('orders_placed', _ordersPlaced);
      await prefs.setInt('items_bought', _itemsBought);
    } catch (_) {
      // Ignore persistence errors.
    }
  }

  void add(int id, int qty) {
    if (!_cart.containsKey(id)) {
      _cart[id] = 0;
    }
    _cart[id] = (_cart[id]! + qty).clamp(1, 10);
    _save();
    notifyListeners();
  }

  void setQty(int id, int qty) {
    final clamped = qty.clamp(1, 10);
    if (clamped == 0) {
      _cart.remove(id);
    } else {
      _cart[id] = clamped;
    }
    _save();
    notifyListeners();
  }

  void remove(int id) {
    _cart.remove(id);
    _save();
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _save();
    notifyListeners();
  }

  void toggleWish(int id) {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }
    _save();
    notifyListeners();
  }

  bool isWishlisted(int id) => _wishlist.contains(id);

  void placeOrder() {
    _ordersPlaced++;
    _itemsBought += count;
    clearCart();
  }

  void addRecycleEntry(String materialType, double quantity, String unit) {
    final entry = RecycleLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      materialType: materialType,
      quantity: quantity,
      unit: unit,
      date: DateTime.now(),
    );
    _recycleLog.insert(0, entry);
    _save();
    notifyListeners();
  }

  void removeRecycleEntry(String id) {
    _recycleLog.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  double get totalRecycledKg {
    double total = 0;
    for (final entry in _recycleLog) {
      if (entry.unit == 'kg') {
        total += entry.quantity;
      } else {
        total += entry.quantity * 0.5;
      }
    }
    return total;
  }

  Map<String, double> get monthlyRecycled {
    final map = <String, double>{};
    final now = DateTime.now();
    for (final entry in _recycleLog) {
      final diff = now.difference(entry.date).inDays;
      if (diff <= 30) {
        final key = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
        final kg = entry.unit == 'kg' ? entry.quantity : entry.quantity * 0.5;
        map[key] = (map[key] ?? 0) + kg;
      }
    }
    return map;
  }
}
