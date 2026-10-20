import 'package:flutter/cupertino.dart';

class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.category,
    required this.labels,
    required this.imageAsset,
    required this.description,
  });

  final int id;
  final String brand;
  final String name;
  final int price;
  final String category;
  final List<String> labels;
  final String imageAsset;
  final String description;
}

class RecycleCentre {
  const RecycleCentre({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.types,
    required this.sourceUrl,
    this.hours,
  });

  final int id;
  final String name;
  final String city;
  final String area;
  final List<String> types;
  final String sourceUrl;
  final String? hours;
}

class RecycleLogEntry {
  const RecycleLogEntry({
    required this.id,
    required this.materialType,
    required this.quantity,
    required this.unit,
    required this.date,
  });

  final String id;
  final String materialType;
  final double quantity;
  final String unit;
  final DateTime date;
}

const List<String> kCategories = [
  'All',
  'Personal Care',
  'Reusables',
  'Bags',
  'Kitchen',
  'Home & Garden',
  'Stationery',
];

const List<String> kRecycleTypes = [
  'All',
  'Paper',
  'Plastic',
  'Glass',
  'Metal',
  'Textiles',
  'E-waste',
  'Batteries',
];

String formatPrice(int price) {
  return '₹$price';
}

Color parseColor(String hex) {
  final buffer = StringBuffer();
  if (hex.startsWith('#')) {
    buffer.write('FF${hex.substring(1)}');
  } else {
    buffer.write('FF$hex');
  }
  return Color(int.parse(buffer.toString(), radix: 16));
}

final List<Product> kProducts = const [
  Product(
    id: 1,
    brand: 'Bentodent',
    name: 'Eco Brush Bamboo Toothbrush (Charcoal)',
    price: 129,
    category: 'Personal Care',
    labels: ['Bamboo handle', 'Charcoal bristles', 'Biodegradable'],
    imageAsset: 'assets/images/products/p01.jpg',
    description:
        'A soft-bristle bamboo toothbrush with an organically grown, biodegradable handle. Charcoal-infused bristles help whiten teeth while remaining gentle on gums.',
  ),
  Product(
    id: 2,
    brand: 'Bamboo India',
    name: 'Bamboo Toothbrush Natural - Pack of 4',
    price: 190,
    category: 'Personal Care',
    labels: ['Bamboo handle', 'Plastic-free', 'Pack of 4'],
    imageAsset: 'assets/images/products/p02.jpg',
    description:
        'A set of four natural bamboo toothbrushes with medium bristles. Made from sustainable bamboo with plastic-free packaging.',
  ),
  Product(
    id: 3,
    brand: 'Milton',
    name: 'Thermosteel Flip Lid Bottle 500ml',
    price: 699,
    category: 'Reusables',
    labels: ['Stainless steel', 'Vacuum insulated', 'BPA-free'],
    imageAsset: 'assets/images/products/p03.jpg',
    description:
        'A 500ml double-wall vacuum-insulated steel bottle with a leak-proof flip lid. Keeps drinks cold or hot for up to 24 hours.',
  ),
  Product(
    id: 4,
    brand: 'Borosil',
    name: 'Hydra Trek Bottle 750ml',
    price: 999,
    category: 'Reusables',
    labels: ['Stainless steel', 'Vacuum insulated', 'Wide mouth'],
    imageAsset: 'assets/images/products/p04.jpg',
    description:
        'A 750ml vacuum-insulated steel bottle with a wide mouth for easy filling and cleaning. Double-wall insulation retains temperature for hours.',
  ),
  Product(
    id: 5,
    brand: 'Cello',
    name: 'Aqua Pro Stainless Steel Bottle 1000ml',
    price: 299,
    category: 'Reusables',
    labels: ['Stainless steel', 'Single-wall', 'Leakproof'],
    imageAsset: 'assets/images/products/p05.jpg',
    description:
        'A 1000ml food-grade stainless steel bottle with a leakproof lid. Lightweight and suitable for daily use at school, office, or gym.',
  ),
  Product(
    id: 6,
    brand: 'Daily Dump',
    name: 'Khamba 3 Tier Small Home Composter',
    price: 2999,
    category: 'Home & Garden',
    labels: ['Terracotta', 'Home composting', 'Aerobic'],
    imageAsset: 'assets/images/products/p06.jpg',
    description:
        'A stackable terracotta home composter designed for families of 2-3. Aerobic composting for kitchen waste on balconies, terraces, or gardens.',
  ),
  Product(
    id: 7,
    brand: 'Daily Dump',
    name: 'Home Composting Starter Kit',
    price: 3499,
    category: 'Home & Garden',
    labels: ['Terracotta', 'Composting kit', 'Includes accessories'],
    imageAsset: 'assets/images/products/p07.jpg',
    description:
        'A complete home composting starter kit with terracotta bin, remix powder, rake, and microbes. Everything needed to begin composting at home.',
  ),
  Product(
    id: 8,
    brand: 'Geosmin',
    name: 'Foldable Jute Cotton Shopping Bag',
    price: 249,
    category: 'Bags',
    labels: ['Jute cotton', 'Reusable', 'Fair trade'],
    imageAsset: 'assets/images/products/p08.jpg',
    description:
        'A foldable reusable shopping bag made of jute and cotton fabric, hand-stitched by artisans in South India. Comes with a small inner pouch.',
  ),
  Product(
    id: 9,
    brand: 'Earthworks',
    name: 'Organic Cotton & Jute Tote',
    price: 299,
    category: 'Bags',
    labels: ['Organic cotton', 'Jute handle', 'Reusable'],
    imageAsset: 'assets/images/products/p09.jpg',
    description:
        'A sturdy tote bag made from 100% organic cotton fabric with a laminated jute handle. Washable and reusable for everyday shopping.',
  ),
  Product(
    id: 10,
    brand: 'The Jute Bag Maker',
    name: 'Eco-Friendly Organic Cotton Tote',
    price: 349,
    category: 'Bags',
    labels: ['Organic cotton', 'Sturdy handles', 'Eco-friendly'],
    imageAsset: 'assets/images/products/p10.jpg',
    description:
        'A vibrant yellow organic cotton tote bag ideal for shopping, travel, and beach days. Sturdy handles for comfortable carrying.',
  ),
  Product(
    id: 11,
    brand: 'Rescript',
    name: 'Eco-Friendly Notebooks - Pack of 6',
    price: 300,
    category: 'Stationery',
    labels: ['100% recycled paper', 'Plastic-free', 'Pack of 6'],
    imageAsset: 'assets/images/products/p11.jpg',
    description:
        'A pack of six eco-friendly notebooks made from 100% recycled paper. Neutral brown covers with minimal accents, made responsibly in India.',
  ),
  Product(
    id: 12,
    brand: 'Ecosphere',
    name: 'A5 Recycled Paper Notebook',
    price: 270,
    category: 'Stationery',
    labels: ['Recycled paper', 'Kraft cover', 'Made in India'],
    imageAsset: 'assets/images/products/p12.jpg',
    description:
        'An A5 size notebook made from 100% recycled paper with a natural kraft finish. Ruled pages with eco-friendly binding.',
  ),
  Product(
    id: 13,
    brand: 'Packmate',
    name: 'Spiral Notebook Recycled Paper',
    price: 300,
    category: 'Stationery',
    labels: ['100% recycled paper', 'Spiral bound', 'Ruled'],
    imageAsset: 'assets/images/products/p13.jpg',
    description:
        'A spiral-bound notebook made from 100% recycled paper with a strong spiral binding. Durable design suitable for office and academic use.',
  ),
  Product(
    id: 14,
    brand: 'Cozy Coir',
    name: 'Coir Scrubber Pack of 5',
    price: 165,
    category: 'Kitchen',
    labels: ['Coconut coir', 'Biodegradable', 'Pack of 5'],
    imageAsset: 'assets/images/products/p14.jpg',
    description:
        'A pack of five 100% natural coconut coir scrubbers for utensils and daily dishwashing. Biodegradable and safe for all cookware.',
  ),
  Product(
    id: 15,
    brand: 'Praacheen Vidhaan',
    name: 'Kitchen Coir Scrub Pack of 2',
    price: 100,
    category: 'Kitchen',
    labels: ['Coconut coir', 'Non-scratch', 'Pack of 2'],
    imageAsset: 'assets/images/products/p15.jpg',
    description:
        'A pack of two natural coir kitchen scrubs for gentle but effective cleaning. Non-scratch and safe for non-stick and ceramic surfaces.',
  ),
  Product(
    id: 16,
    brand: 'Antique Ayurveda',
    name: 'Natural Coir Dish Pan Brush',
    price: 199,
    category: 'Kitchen',
    labels: ['Coconut husk', 'Antimicrobial', 'Ergonomic grip'],
    imageAsset: 'assets/images/products/p16.jpg',
    description:
        'A natural coir dish pan brush made from durable coconut husk fibers. Naturally antimicrobial and effective at removing stubborn grime without scratching.',
  ),
];

final List<RecycleCentre> kRecycleCentres = const [
  RecycleCentre(
    id: 1,
    name: 'MCGM Dry Waste Segregation Centre - Colaba',
    city: 'Mumbai',
    area: 'Colaba',
    types: ['Paper', 'Plastic', 'Glass', 'Metal'],
    sourceUrl: 'https://portal.mcgm.gov.in/irj/go/km/docs/documents/MCGM%20Department%20List/Solid%20Waste%20Management/Docs/DWSC%20-%20List%20of%20Centres%20PDF.pdf',
    hours: 'Daily collection',
  ),
  RecycleCentre(
    id: 2,
    name: 'MCGM Dry Waste Segregation Centre - Andheri',
    city: 'Mumbai',
    area: 'Andheri (W)',
    types: ['Paper', 'Plastic', 'Glass', 'Metal'],
    sourceUrl: 'https://portal.mcgm.gov.in/irj/go/km/docs/documents/MCGM%20Department%20List/Solid%20Waste%20Management/Docs/DWSC%20-%20List%20of%20Centres%20PDF.pdf',
    hours: 'Daily collection',
  ),
  RecycleCentre(
    id: 3,
    name: 'MCGM Dry Waste Segregation Centre - Goregaon',
    city: 'Mumbai',
    area: 'Goregaon',
    types: ['Paper', 'Plastic', 'Glass', 'Metal'],
    sourceUrl: 'https://portal.mcgm.gov.in/irj/go/km/docs/documents/MCGM%20Department%20List/Solid%20Waste%20Management/Docs/DWSC%20-%20List%20of%20Centres%20PDF.pdf',
    hours: 'Daily collection',
  ),
  RecycleCentre(
    id: 4,
    name: 'ReCircle MRF Malad',
    city: 'Mumbai',
    area: 'Malad',
    types: ['Plastic', 'Paper'],
    sourceUrl: 'https://www.recircle.in/',
    hours: 'Mon-Sat',
  ),
  RecycleCentre(
    id: 5,
    name: '5RCYCLE Foundation',
    city: 'Mumbai',
    area: 'Marina Enclave Rd',
    types: ['Paper', 'Plastic', 'Textiles'],
    sourceUrl: 'https://5rcycle.org/',
    hours: 'Mon-Sat 9am-6pm',
  ),
  RecycleCentre(
    id: 6,
    name: 'Masstech Recycling LLP',
    city: 'Mumbai',
    area: 'Sakinaka',
    types: ['E-waste'],
    sourceUrl: 'https://www.mpcb.gov.in/sites/default/files/Authorised%20E-Waste%20Recyclers%20%26%20Refurbishers-May%202024.pdf',
    hours: 'Business hours',
  ),
  RecycleCentre(
    id: 7,
    name: 'Regreen Recycling',
    city: 'Mumbai',
    area: 'Andheri (E)',
    types: ['E-waste'],
    sourceUrl: 'https://www.mpcb.gov.in/sites/default/files/Authorised%20E-Waste%20Recyclers%20%26%20Refurbishers-May%202024.pdf',
    hours: 'Business hours',
  ),
  RecycleCentre(
    id: 8,
    name: 'Greenscape Eco Management Pvt Ltd',
    city: 'Delhi',
    area: 'Patparganj Industrial Area',
    types: ['E-waste'],
    sourceUrl: 'https://www.ndmc.gov.in/cpcb_approved_e-waste_vendors_list.aspx',
    hours: 'Business hours',
  ),
  RecycleCentre(
    id: 9,
    name: 'E-Parisaraa Pvt Ltd',
    city: 'Bangalore',
    area: 'Dabaspet',
    types: ['E-waste'],
    sourceUrl: 'https://cpcb.nic.in/list-of-registered-pro/',
    hours: 'Business hours',
  ),
];
