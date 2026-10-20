import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'screens/about_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/impact_screen.dart';
import 'screens/recycle_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/wishlist_screen.dart';
import 'state/store.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = Store();
  runApp(ChangeNotifierProvider.value(value: store, child: const EcoLoopApp()));
}

class EcoLoopApp extends StatelessWidget {
  const EcoLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'EcoLoop',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: AppColors.primary,
        barBackgroundColor: AppColors.background,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: AppText.headline17,
          navLargeTitleTextStyle: AppText.largeTitle,
        ),
      ),
      home: const TabShell(),
    );
  }
}

class TabShell extends StatefulWidget {
  const TabShell({super.key});

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  late final CupertinoTabController _controller;
  String? _searchQuery;
  String? _homeCategory;

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController(initialIndex: 0);
  }

  void _handleSearch(String? query) {
    if (query == null || query.trim().isEmpty) return;
    setState(() {
      _searchQuery = query.trim();
      _homeCategory = null;
    });
    _controller.index = 1;
  }

  void _handleCategory(String category) {
    setState(() {
      _homeCategory = category;
      _searchQuery = null;
    });
    _controller.index = 1;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.background,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.secondaryText,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bag),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'Recycle',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie),
            label: 'Impact',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: CartBadge(),
            label: 'Cart',
          ),
        ],
      ),
      tabBuilder: (context, i) {
        switch (i) {
          case 0:
            return CupertinoPageScaffold(
              child: HomeScreen(
                onSearch: _handleSearch,
                onShop: () {
                  _searchQuery = null;
                  _homeCategory = null;
                  _controller.index = 1;
                },
                onCategory: _handleCategory,
                onAbout: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const AboutScreen(),
                  ),
                ),
              ),
            );
          case 1:
            return CupertinoPageScaffold(
              child: ShopScreen(
                initialQuery: _searchQuery,
                initialCategory: _homeCategory,
              ),
            );
          case 2:
            return const CupertinoPageScaffold(child: RecycleScreen());
          case 3:
            return const CupertinoPageScaffold(child: ImpactScreen());
          case 4:
            return const CupertinoPageScaffold(child: WishlistScreen());
          case 5:
            return CupertinoPageScaffold(
              child: CartScreen(
                onStartShopping: () {
                  _searchQuery = null;
                  _controller.index = 1;
                },
              ),
            );
          default:
            return const CupertinoPageScaffold(child: HomeScreen());
        }
      },
    );
  }
}

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(
      builder: (context, store, _) {
        final count = store.count;
        return Stack(
          children: [
            const Icon(CupertinoIcons.cart),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
