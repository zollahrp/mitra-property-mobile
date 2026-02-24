# API Filter Property - Dokumentasi & Integrasi Mobile

## Overview

Backend menyediakan **multiple dedicated endpoints** untuk filtering property berdasarkan berbagai kriteria. Semua endpoint filtering mengembalikan data dalam format **paginated response**.

---

## Base URL

```
http://<your-backend-url>/api/property
```

**Catatan:** Ganti `<your-backend-url>` dengan URL backend Anda (contoh: `http://localhost:3000` atau `https://your-domain.com`)

---

## Authentication

Semua endpoint filtering memerlukan **Bearer Token** di header:

```
Authorization: Bearer <your-jwt-token>
```

---

## Format Response

Semua endpoint filtering mengembalikan response dengan format yang sama:

```json
{
  "items": [
    {
      "id": "uuid",
      "nama": "Nama Property",
      "kode": "MTPR-25-ABCDE",
      "lokasi": "Alamat lengkap",
      "deskripsi": "Deskripsi property",
      "harga": "1500000000",
      "luas_tanah": "120",
      "luas_bangunan": "80",
      "kamar_tidur": 3,
      "kamar_mandi": 2,
      "dapur": 1,
      "garasi": 1,
      "carport": 1,
      "listrik": "2200",
      "air": "1000",
      "foto": [
        {
          "id": "uuid",
          "photo_url": "http://..."
        }
      ],
      "sertifikat": "SHM",
      "furnish": "furnish",
      "hadap": "Utara",
      "property_type": "rumah",
      "tipe": "minimalis",
      "listing_type": "beli",
      "status": "approved",
      "reject_reason": null,
      "userId": "uuid",
      "views": 150,
      "clicks": 25,
      "telepon": "081234567890",
      "created_at": "2025-02-24T10:00:00.000Z",
      "updated_at": "2025-02-24T10:00:00.000Z"
    }
  ],
  "total": 50,
  "page": 1,
  "perPage": 10,
  "totalPages": 5
}
```

---

## Daftar Endpoint Filtering

### 1. Filter Berdasarkan Status Approval

#### Get Approved Properties
Property yang sudah disetujui admin.

```
GET /api/property/approved?page=1
```

**Use Case:** Menampilkan property yang siap ditampilkan ke public.

---

#### Get Pending Properties (Admin Only)
Property yang menunggu persetujuan admin.

```
GET /api/property/pending?page=1
```

**Role Required:** `admin`

---

### 2. Filter Berdasarkan Listing Type (Beli/Sewa)

#### Get Property untuk Dijual (Beli)
```
GET /api/property/for-sale?page=1
```

**Use Case:** Menampilkan semua property yang dijual.

---

#### Get Property untuk Disewa (Rent)
```
GET /api/property/for-rent?page=1
```

**Use Case:** Menampilkan semua property yang disewakan.

---

### 3. Filter Berdasarkan Property Type

#### Get Rumah
```
GET /api/property/rumah?page=1
```

---

#### Get Apartemen
```
GET /api/property/apartemen?page=1
```

---

#### Get Kavling (Tanah)
```
GET /api/property/kavling?page=1
```

---

### 4. Filter Berdasarkan Furnishing Status

#### Get Furnished Properties
Property dengan perabot lengkap.

```
GET /api/property/furnished?page=1
```

---

#### Get Semi-Furnished Properties
Property dengan sebagian perabot.

```
GET /api/property/semi-furnished?page=1
```

---

#### Get Unfurnished Properties
Property tanpa perabot.

```
GET /api/property/unfurnished?page=1
```

---

### 5. Filter Berdasarkan Sertifikat

#### Get Property SHM (Sertifikat Hak Milik)
```
GET /api/property/shm?page=1
```

---

#### Get Property SHGB (Sertifikat Hak Guna Bangunan)
```
GET /api/property/shgb?page=1
```

---

#### Get Property PPJB (Perjanjian Pengikatan Jual Beli)
```
GET /api/property/ppjb?page=1
```

---

### 6. Filter Berdasarkan Harga

#### Get Property - Harga Terendah ke Tertinggi
```
GET /api/property/lowest-price?page=1
```

**Use Case:** Menampilkan property dari harga termurah.

---

#### Get Property - Harga Tertinggi ke Terendah
```
GET /api/property/highest-price?page=1
```

**Use Case:** Menampilkan property dari harga termahal.

---

### 7. Filter Berdasarkan Waktu

#### Get Newest Properties (Property Terbaru)
```
GET /api/property/newest?page=1
```

**Use Case:** Menampilkan property yang baru ditambahkan.

---

### 8. Search by Name

#### Search Property by Nama
```
GET /api/property/search/:query?page=1
```

**Parameters:**
- `:query` - Text untuk pencarian (case-insensitive)

**Example:**
```
GET /api/property/search/Rumah%20Minimalis?page=1
```

**Use Case:** Fitur pencarian property berdasarkan nama.

---

## Query Parameters

Semua endpoint mendukung query parameter:

| Parameter | Type   | Default | Description                    |
|-----------|--------|---------|--------------------------------|
| `page`    | number | `1`     | Nomor halaman untuk pagination |

**Default `perPage`:** 10 items per halaman

---

## Integrasi Flutter - Step by Step

### Step 1: Buat Model Class

Buat file `lib/models/property.dart`:

```dart
class Property {
  final String id;
  final String nama;
  final String kode;
  final String? lokasi;
  final String deskripsi;
  final String harga;
  final String? luasTanah;
  final String? luasBangunan;
  final int? kamarTidur;
  final int? kamarMandi;
  final int? dapur;
  final int? garasi;
  final int? carport;
  final String? listrik;
  final String? air;
  final List<PropertyPhoto> foto;
  final String sertifikat;
  final String? furnish;
  final String? hadap;
  final String propertyType;
  final String? tipe;
  final String listingType;
  final String status;
  final String? rejectReason;
  final String userId;
  final int views;
  final int clicks;
  final String? telepon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.nama,
    required this.kode,
    this.lokasi,
    required this.deskripsi,
    required this.harga,
    this.luasTanah,
    this.luasBangunan,
    this.kamarTidur,
    this.kamarMandi,
    this.dapur,
    this.garasi,
    this.carport,
    this.listrik,
    this.air,
    required this.foto,
    required this.sertifikat,
    this.furnish,
    this.hadap,
    required this.propertyType,
    this.tipe,
    required this.listingType,
    required this.status,
    this.rejectReason,
    required this.userId,
    required this.views,
    required this.clicks,
    this.telepon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      lokasi: json['lokasi'],
      deskripsi: json['deskripsi'],
      harga: json['harga'],
      luasTanah: json['luas_tanah'],
      luasBangunan: json['luas_bangunan'],
      kamarTidur: json['kamar_tidur'],
      kamarMandi: json['kamar_mandi'],
      dapur: json['dapur'],
      garasi: json['garasi'],
      carport: json['carport'],
      listrik: json['listrik'],
      air: json['air'],
      foto: (json['foto'] as List<dynamic>?)
              ?.map((f) => PropertyPhoto.fromJson(f))
              .toList() ??
          [],
      sertifikat: json['sertifikat'],
      furnish: json['furnish'],
      hadap: json['hadap'],
      propertyType: json['property_type'],
      tipe: json['tipe'],
      listingType: json['listing_type'],
      status: json['status'],
      rejectReason: json['reject_reason'],
      userId: json['userId'],
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
      telepon: json['telepon'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper untuk format harga ke Rupiah
  String get formattedHarga {
    final number = int.tryParse(harga) ?? 0;
    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

class PropertyPhoto {
  final String id;
  final String photoUrl;

  PropertyPhoto({
    required this.id,
    required this.photoUrl,
  });

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    return PropertyPhoto(
      id: json['id'],
      photoUrl: json['photo_url'],
    );
  }
}

class PaginatedProperties {
  final List<Property> items;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  PaginatedProperties({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory PaginatedProperties.fromJson(Map<String, dynamic> json) {
    return PaginatedProperties(
      items: (json['items'] as List<dynamic>)
          .map((item) => Property.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
```

---

### Step 2: Buat API Service

Buat file `lib/services/property_api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class PropertyApiService {
  final String baseUrl;
  String? _authToken;

  PropertyApiService({required this.baseUrl});

  // Set auth token setelah login
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Helper method untuk headers
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Generic method untuk fetch paginated properties
  Future<PaginatedProperties> _fetchProperties(String endpoint, {int page = 1}) async {
    final url = Uri.parse('$baseUrl$endpoint?page=$page');
    
    final response = await http.get(url, headers: _headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaginatedProperties.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Token tidak valid');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Gagal mengambil data property');
    }
  }

  // ==================== FILTERING ENDPOINTS ====================

  // 1. Approved Properties
  Future<PaginatedProperties> getApprovedProperties({int page = 1}) {
    return _fetchProperties('/api/property/approved', page: page);
  }

  // 2. Pending Properties (Admin)
  Future<PaginatedProperties> getPendingProperties({int page = 1}) {
    return _fetchProperties('/api/property/pending', page: page);
  }

  // 3. For Sale (Beli)
  Future<PaginatedProperties> getPropertiesForSale({int page = 1}) {
    return _fetchProperties('/api/property/for-sale', page: page);
  }

  // 4. For Rent (Sewa)
  Future<PaginatedProperties> getPropertiesForRent({int page = 1}) {
    return _fetchProperties('/api/property/for-rent', page: page);
  }

  // 5. Rumah
  Future<PaginatedProperties> getRumahProperties({int page = 1}) {
    return _fetchProperties('/api/property/rumah', page: page);
  }

  // 6. Apartemen
  Future<PaginatedProperties> getApartemenProperties({int page = 1}) {
    return _fetchProperties('/api/property/apartemen', page: page);
  }

  // 7. Kavling
  Future<PaginatedProperties> getKavlingProperties({int page = 1}) {
    return _fetchProperties('/api/property/kavling', page: page);
  }

  // 8. Furnished
  Future<PaginatedProperties> getFurnishedProperties({int page = 1}) {
    return _fetchProperties('/api/property/furnished', page: page);
  }

  // 9. Semi-Furnished
  Future<PaginatedProperties> getSemiFurnishedProperties({int page = 1}) {
    return _fetchProperties('/api/property/semi-furnished', page: page);
  }

  // 10. Unfurnished
  Future<PaginatedProperties> getUnfurnishedProperties({int page = 1}) {
    return _fetchProperties('/api/property/unfurnished', page: page);
  }

  // 11. SHM
  Future<PaginatedProperties> getSHMProperties({int page = 1}) {
    return _fetchProperties('/api/property/shm', page: page);
  }

  // 12. SHGB
  Future<PaginatedProperties> getSHGBProperties({int page = 1}) {
    return _fetchProperties('/api/property/shgb', page: page);
  }

  // 13. PPJB
  Future<PaginatedProperties> getPPJBProperties({int page = 1}) {
    return _fetchProperties('/api/property/ppjb', page: page);
  }

  // 14. Lowest Price
  Future<PaginatedProperties> getLowestPriceProperties({int page = 1}) {
    return _fetchProperties('/api/property/lowest-price', page: page);
  }

  // 15. Highest Price
  Future<PaginatedProperties> getHighestPriceProperties({int page = 1}) {
    return _fetchProperties('/api/property/highest-price', page: page);
  }

  // 16. Newest Properties
  Future<PaginatedProperties> getNewestProperties({int page = 1}) {
    return _fetchProperties('/api/property/newest', page: page);
  }

  // 17. Search by Name
  Future<PaginatedProperties> searchProperties(String query, {int page = 1}) async {
    final encodedQuery = Uri.encodeComponent(query);
    return _fetchProperties('/api/property/search/$encodedQuery', page: page);
  }

  // ==================== DETAIL & OTHERS ====================

  // Get Property by ID
  Future<Property> getPropertyById(String id) async {
    final url = Uri.parse('$baseUrl/api/property/$id');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Property.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Property tidak ditemukan');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Gagal mengambil detail property');
    }
  }

  // Get Property Photos
  Future<List<PropertyPhoto>> getPropertyPhotos(String propertyId) async {
    final url = Uri.parse('$baseUrl/api/property/$propertyId/photos');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((photo) => PropertyPhoto.fromJson(photo)).toList();
    } else {
      throw Exception('Gagal mengambil foto property');
    }
  }

  // Register Property Click
  Future<void> registerClick(String propertyId) async {
    final url = Uri.parse('$baseUrl/api/property/$propertyId/click');
    final response = await http.post(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Gagal register click');
    }
  }
}
```

---

### Step 3: Setup Dependency Injection

Di `lib/main.dart` atau file provider Anda:

```dart
import 'package:flutter/material.dart';
import 'services/property_api_service.dart';

// Global instance atau gunakan provider/riverpod
final propertyApiService = PropertyApiService(
  baseUrl: 'http://192.168.1.100:3000', // Sesuaikan dengan IP/URL backend
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitra Property',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
```

---

### Step 4: Implementasi UI dengan Filtering

#### Contoh 1: Halaman Home dengan Multiple Filter Tabs

Buat file `lib/screens/home_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_api_service.dart';
import 'property_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PropertyApiService _apiService = propertyApiService;
  
  String _selectedFilter = 'approved';
  PaginatedProperties? _properties;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;

  final Map<String, String> _filterOptions = {
    'approved': 'Semua (Approved)',
    'beli': 'Dijual',
    'sewa': 'Disewa',
    'rumah': 'Rumah',
    'apartemen': 'Apartemen',
    'kavling': 'Kavling',
    'furnished': 'Furnished',
    'lowest-price': 'Harga Terendah',
  };

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      PaginatedProperties result;

      switch (_selectedFilter) {
        case 'beli':
          result = await _apiService.getPropertiesForSale(page: page);
          break;
        case 'sewa':
          result = await _apiService.getPropertiesForRent(page: page);
          break;
        case 'rumah':
          result = await _apiService.getRumahProperties(page: page);
          break;
        case 'apartemen':
          result = await _apiService.getApartemenProperties(page: page);
          break;
        case 'kavling':
          result = await _apiService.getKavlingProperties(page: page);
          break;
        case 'furnished':
          result = await _apiService.getFurnishedProperties(page: page);
          break;
        case 'lowest-price':
          result = await _apiService.getLowestPriceProperties(page: page);
          break;
        default:
          result = await _apiService.getApprovedProperties(page: page);
      }

      setState(() {
        if (page == 1) {
          _properties = result;
        } else {
          // Append for pagination
          _properties = PaginatedProperties(
            items: [..._properties!.items, ...result.items],
            total: result.total,
            page: result.page,
            perPage: result.perPage,
            totalPages: result.totalPages,
          );
        }
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _currentPage = 1;
    });
    _loadProperties(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mitra Property'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _navigateToSearch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final key = _filterOptions.keys.elementAt(index);
                final label = _filterOptions[key]!;
                final isSelected = _selectedFilter == key;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) => _onFilterSelected(key),
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue,
                  ),
                );
              },
            ),
          ),

          // Property List
          Expanded(
            child: _isLoading && _properties == null
                ? Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _properties == null || _properties!.items.isEmpty
                        ? Center(child: Text('Tidak ada property'))
                        : RefreshIndicator(
                            onRefresh: () => _loadProperties(page: 1),
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _properties!.items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _properties!.items.length) {
                                  // Load more / Pagination indicator
                                  if (_currentPage < _properties!.totalPages) {
                                    _loadProperties(page: _currentPage + 1);
                                    return Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return SizedBox.shrink();
                                }

                                final property = _properties!.items[index];
                                return _buildPropertyCard(property);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: () => _navigateToDetail(property),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              child: property.foto.isNotEmpty
                  ? Image.network(
                      property.foto[0].photoUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.home, size: 50),
                      ),
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.home, size: 50),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.nama,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    property.formattedHarga,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.lokasi ?? '-',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFeatureChip(Icons.bed, '${property.kamarTidur ?? '-'}'),
                      SizedBox(width: 8),
                      _buildFeatureChip(Icons.bathtub, '${property.kamarMandi ?? '-'}'),
                      SizedBox(width: 8),
                      _buildFeatureChip(Icons.square_foot, '${property.luasBangunan ?? property.luasTanah ?? '-'} m²'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/search');
  }

  void _navigateToDetail(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailPage(property: property),
      ),
    );
  }
}
```

---

#### Contoh 2: Search Page

Buat file `lib/screens/search_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_api_service.dart';
import 'property_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PropertyApiService _apiService = propertyApiService;
  final TextEditingController _searchController = TextEditingController();
  
  PaginatedProperties? _results;
  bool _isSearching = false;
  bool _hasSearched = false;
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search({int page = 1}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final result = await _apiService.searchProperties(query, page: page);

      setState(() {
        if (page == 1) {
          _results = result;
        } else {
          _results = PaginatedProperties(
            items: [..._results!.items, ...result.items],
            total: result.total,
            page: result.page,
            perPage: result.perPage,
            totalPages: result.totalPages,
          );
        }
        _currentPage = page;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari property...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = null;
                  _hasSearched = false;
                });
              },
            ),
          ),
          onSubmitted: (_) => _search(page: 1),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _search(page: 1),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Ketik untuk mencari property',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _isSearching && _results == null
                    ? Center(child: CircularProgressIndicator())
                    : _results == null || _results!.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home_off, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada property ditemukan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _search(page: 1),
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _results!.items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _results!.items.length) {
                                  if (_currentPage < _results!.totalPages) {
                                    _search(page: _currentPage + 1);
                                    return Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return SizedBox.shrink();
                                }
                                return _buildPropertyCard(_results!.items[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    // Same implementation as HomePage
    return Card(
      child: ListTile(
        leading: property.foto.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  property.foto[0].photoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.home, size: 40),
        title: Text(property.nama, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(property.formattedHarga),
        onTap: () => _navigateToDetail(property),
      ),
    );
  }

  void _navigateToDetail(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailPage(property: property),
      ),
    );
  }
}
```

---

#### Contoh 3: Filter Advanced dengan Multiple Criteria

Buat file `lib/screens/advanced_filter_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_api_service.dart';

class AdvancedFilterPage extends StatefulWidget {
  @override
  _AdvancedFilterPageState createState() => _AdvancedFilterPageState();
}

class _AdvancedFilterPageState extends State<AdvancedFilterPage> {
  final PropertyApiService _apiService = propertyApiService;

  // Filter State
  String? _listingType; // 'beli' or 'sewa'
  String? _propertyType; // 'rumah', 'apartemen', 'kavling'
  String? _furnishType; // 'furnish', 'semi_furnish', 'unfurnish'
  String? _certificateType; // 'SHM', 'SHGB', 'PPJB'
  String? _sortBy; // 'lowest-price', 'highest-price', 'newest'

  PaginatedProperties? _results;
  bool _isLoading = false;

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    try {
      PaginatedProperties result;

      // Priority: Use most specific filter
      if (_sortBy != null) {
        switch (_sortBy) {
          case 'lowest-price':
            result = await _apiService.getLowestPriceProperties();
            break;
          case 'highest-price':
            result = await _apiService.getHighestPriceProperties();
            break;
          case 'newest':
            result = await _apiService.getNewestProperties();
            break;
          default:
            result = await _apiService.getApprovedProperties();
        }
      } else if (_certificateType != null) {
        switch (_certificateType) {
          case 'SHM':
            result = await _apiService.getSHMProperties();
            break;
          case 'SHGB':
            result = await _apiService.getSHGBProperties();
            break;
          case 'PPJB':
            result = await _apiService.getPPJBProperties();
            break;
          default:
            result = await _apiService.getApprovedProperties();
        }
      } else if (_furnishType != null) {
        switch (_furnishType) {
          case 'furnish':
            result = await _apiService.getFurnishedProperties();
            break;
          case 'semi_furnish':
            result = await _apiService.getSemiFurnishedProperties();
            break;
          case 'unfurnish':
            result = await _apiService.getUnfurnishedProperties();
            break;
          default:
            result = await _apiService.getApprovedProperties();
        }
      } else if (_propertyType != null) {
        switch (_propertyType) {
          case 'rumah':
            result = await _apiService.getRumahProperties();
            break;
          case 'apartemen':
            result = await _apiService.getApartemenProperties();
            break;
          case 'kavling':
            result = await _apiService.getKavlingProperties();
            break;
          default:
            result = await _apiService.getApprovedProperties();
        }
      } else if (_listingType != null) {
        switch (_listingType) {
          case 'beli':
            result = await _apiService.getPropertiesForSale();
            break;
          case 'sewa':
            result = await _apiService.getPropertiesForRent();
            break;
          default:
            result = await _apiService.getApprovedProperties();
        }
      } else {
        result = await _apiService.getApprovedProperties();
      }

      setState(() {
        _results = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _listingType = null;
      _propertyType = null;
      _furnishType = null;
      _certificateType = null;
      _sortBy = null;
      _results = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Advanced'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          // Filter Panel (Left)
          Container(
            width: 250,
            color: Colors.grey[100],
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildFilterSection(
                  title: 'Listing Type',
                  options: {'beli': 'Beli', 'sewa': 'Sewa'},
                  selected: _listingType,
                  onSelected: (value) => setState(() => _listingType = value),
                ),
                Divider(),
                _buildFilterSection(
                  title: 'Property Type',
                  options: {'rumah': 'Rumah', 'apartemen': 'Apartemen', 'kavling': 'Kavling'},
                  selected: _propertyType,
                  onSelected: (value) => setState(() => _propertyType = value),
                ),
                Divider(),
                _buildFilterSection(
                  title: 'Furnishing',
                  options: {'furnish': 'Furnished', 'semi_furnish': 'Semi', 'unfurnish': 'Unfurnished'},
                  selected: _furnishType,
                  onSelected: (value) => setState(() => _furnishType = value),
                ),
                Divider(),
                _buildFilterSection(
                  title: 'Sertifikat',
                  options: {'SHM': 'SHM', 'SHGB': 'SHGB', 'PPJB': 'PPJB'},
                  selected: _certificateType,
                  onSelected: (value) => setState(() => _certificateType = value),
                ),
                Divider(),
                _buildFilterSection(
                  title: 'Sort By',
                  options: {
                    'lowest-price': 'Harga Terendah',
                    'highest-price': 'Harga Tertinggi',
                    'newest': 'Terbaru'
                  },
                  selected: _sortBy,
                  onSelected: (value) => setState(() => _sortBy = value),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _applyFilters,
                  child: Text('Terapkan Filter'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40)),
                ),
              ],
            ),
          ),

          // Results Panel (Right)
          Expanded(
            child: _results == null
                ? Center(child: Text('Pilih filter dan klik Terapkan'))
                : _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _results!.items.isEmpty
                        ? Center(child: Text('Tidak ada hasil'))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _results!.items.length,
                            itemBuilder: (context, index) =>
                                _buildPropertyCard(_results!.items[index]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Map<String, String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 8),
        ...options.entries.map((entry) => RadioListTile<String>(
              title: Text(entry.value, style: TextStyle(fontSize: 13)),
              value: entry.key,
              groupValue: selected,
              onChanged: (value) {
                onSelected(selected == value ? null : value);
              },
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )),
      ],
    );
  }

  Widget _buildPropertyCard(Property property) {
    // Same card implementation
    return Card(
      child: ListTile(
        leading: property.foto.isNotEmpty
            ? Image.network(property.foto[0].photoUrl, width: 60, height: 60, fit: BoxFit.cover)
            : Icon(Icons.home),
        title: Text(property.nama),
        subtitle: Text(property.formattedHarga),
        onTap: () {},
      ),
    );
  }
}
```

---

### Step 5: Setup Routes

Di `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/search_page.dart';
import 'screens/advanced_filter_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitra Property',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/search': (context) => SearchPage(),
        '/advanced-filter': (context) => AdvancedFilterPage(),
      },
    );
  }
}
```

---

### Step 6: Add HTTP Dependency

Di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  # Optional: for better state management
  provider: ^6.0.0
```

Run:
```bash
flutter pub get
```

---

## Testing API dengan cURL

### Test Approved Properties
```bash
curl -X GET "http://localhost:3000/api/property/approved?page=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test Filter Rumah
```bash
curl -X GET "http://localhost:3000/api/property/rumah?page=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test Filter Furnished
```bash
curl -X GET "http://localhost:3000/api/property/furnished?page=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test Search
```bash
curl -X GET "http://localhost:3000/api/property/search/Rumah%20Minimalis?page=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Tips & Best Practices

### 1. **Caching**
Implement caching untuk mengurangi API calls:

```dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final cacheManager = CacheManager(
  Config(
    'property_cache',
    stalePeriod: Duration(hours: 1),
    maxNrOfCacheObjects: 100,
  ),
);
```

### 2. **Error Handling**
Selalu handle error dengan baik:

```dart
try {
  final result = await _apiService.getApprovedProperties();
} on SocketException {
  // No internet
  showError('Tidak ada koneksi internet');
} on TimeoutException {
  // Request timeout
  showError('Request timeout');
} catch (e) {
  showError('Error: $e');
}
```

### 3. **Pagination**
Implement infinite scroll untuk UX yang lebih baik:

```dart
ScrollController _scrollController;

_scrollController.addListener(() {
  if (_scrollController.position.pixels == 
      _scrollController.position.maxScrollExtent) {
    // Load more
    _loadMore();
  }
});
```

### 4. **Pull to Refresh**
Gunakan `RefreshIndicator` untuk pull-to-refresh:

```dart
RefreshIndicator(
  onRefresh: () => _loadProperties(page: 1),
  child: ListView(...),
)
```

### 5. **Loading States**
Tampilkan loading indicator yang jelas:

```dart
if (_isLoading) return CircularProgressIndicator();
if (_error != null) return ErrorWidget(_error);
if (_data.isEmpty) return EmptyState();
return ContentWidget();
```

---

## Troubleshooting

### Error: "Unauthorized"
- Pastikan token JWT valid dan belum expired
- Set token dengan `_apiService.setAuthToken(token)`

### Error: "Connection refused"
- Untuk emulator Android, gunakan `10.0.2.2` bukan `localhost`
- Untuk iOS simulator, gunakan `localhost`
- Untuk device fisik, gunakan IP komputer Anda

### Error: "Certificate not found"
- Pastikan data sertifikat ada di database
- Check enum values di Prisma schema

---

## Summary

| Fitur | Endpoint | Method |
|-------|----------|--------|
| Approved Properties | `/api/property/approved` | GET |
| For Sale | `/api/property/for-sale` | GET |
| For Rent | `/api/property/for-rent` | GET |
| Rumah | `/api/property/rumah` | GET |
| Apartemen | `/api/property/apartemen` | GET |
| Kavling | `/api/property/kavling` | GET |
| Furnished | `/api/property/furnished` | GET |
| Semi-Furnished | `/api/property/semi-furnished` | GET |
| Unfurnished | `/api/property/unfurnished` | GET |
| SHM | `/api/property/shm` | GET |
| SHGB | `/api/property/shgb` | GET |
| PPJB | `/api/property/ppjb` | GET |
| Lowest Price | `/api/property/lowest-price` | GET |
| Highest Price | `/api/property/highest-price` | GET |
| Newest | `/api/property/newest` | GET |
| Search | `/api/property/search/:query` | GET |

Semua endpoint mendukung pagination dengan parameter `?page=1`.
