// File: lib/widgets/openstreetmap_address_picker.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenStreetMapAddressPicker extends StatefulWidget {
  final String initialAddress;
  final Function(String address, LatLng? coordinates) onAddressSelected;
  final Color primaryColor;

  const OpenStreetMapAddressPicker({
    Key? key,
    required this.initialAddress,
    required this.onAddressSelected,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<OpenStreetMapAddressPicker> createState() => _OpenStreetMapAddressPickerState();
}

class _OpenStreetMapAddressPickerState extends State<OpenStreetMapAddressPicker> {
  MapController? _mapController;
  LatLng _currentPosition = const LatLng(-6.2088, 106.8456); // Default Jakarta
  LatLng _selectedPosition = const LatLng(-6.2088, 106.8456);
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isGettingCurrentLocation = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedAddress = widget.initialAddress;
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);
    
    try {
      // Jika ada alamat awal, coba geocode
      if (widget.initialAddress.isNotEmpty) {
        await _geocodeAddress(widget.initialAddress);
      } else {
        // Jika tidak ada alamat, ambil lokasi saat ini
        await _getCurrentLocation();
      }
    } catch (e) {
      print('Error initializing location: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingCurrentLocation = true);
    
    try {
      // Check permission
      var permission = await Permission.location.request();
      if (permission.isDenied) {
        throw Exception('Location permission denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentPosition = newPosition;
        _selectedPosition = newPosition;
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.move(newPosition, 16.0);
      }

      // Get address from coordinates
      await _getAddressFromCoordinates(newPosition);
      
    } catch (e) {
      print('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tidak bisa mendapatkan lokasi: ${e.toString()}',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
    
    setState(() => _isGettingCurrentLocation = false);
  }

  // Geocoding menggunakan Nominatim (OpenStreetMap) - GRATIS!
  Future<void> _geocodeAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = 'https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress&limit=1&countrycodes=id';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TokoApp/1.0 (Flutter App)', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          LatLng newPosition = LatLng(
            double.parse(location['lat']),
            double.parse(location['lon']),
          );
          
          setState(() {
            _selectedPosition = newPosition;
            _selectedAddress = location['display_name'] ?? address;
          });

          if (_mapController != null) {
            _mapController!.move(newPosition, 16.0);
          }
        }
      }
    } catch (e) {
      print('Error geocoding address: $e');
      // Fallback ke geocoding package (jika tersedia)
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          LatLng newPosition = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          
          setState(() {
            _selectedPosition = newPosition;
            _selectedAddress = address;
          });

          if (_mapController != null) {
            _mapController!.move(newPosition, 16.0);
          }
        }
      } catch (e2) {
        print('Fallback geocoding also failed: $e2');
      }
    }
  }

  // Reverse Geocoding menggunakan Nominatim - GRATIS!
  Future<void> _getAddressFromCoordinates(LatLng position) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TokoApp/1.0 (Flutter App)',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            _selectedAddress = data['display_name'];
          });
          return;
        }
      }
    } catch (e) {
      print('Error getting address from Nominatim: $e');
    }

    // Fallback ke geocoding package
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += ', ${place.subLocality!}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += ', ${place.locality!}';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += ', ${place.administrativeArea!}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += ', ${place.country!}';
        }

        setState(() {
          _selectedAddress = address.isNotEmpty ? address : 'Alamat tidak ditemukan';
        });
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
      setState(() {
        _selectedAddress = 'Alamat tidak ditemukan';
      });
    }
  }

  Future<void> _searchAddress() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      await _geocodeAddress(query);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alamat tidak ditemukan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  // FIXED: Sesuaikan dengan flutter_map v5
  void _onMapTap(TapPosition tapPosition, LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _isLoading = true;
    });

    await _getAddressFromCoordinates(position);
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: widget.primaryColor,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Alamat',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // FIXED: OpenStreetMap dengan flutter_map v5 syntax
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedPosition,
              zoom: 16.0,
              onTap: _onMapTap,
              interactiveFlags: InteractiveFlag.pinchZoom |
                               InteractiveFlag.drag |
                               InteractiveFlag.doubleTapZoom,
            ),
            children: [
              // OpenStreetMap tiles (100% GRATIS!)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.toko_app',
                maxZoom: 19,
              ),
              
              // FIXED: MarkerLayer dengan syntax yang benar
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    builder: (ctx) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari alamat...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: widget.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: widget.primaryColor,
                    ),
                    onPressed: _searchAddress,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                onSubmitted: (_) => _searchAddress(),
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: _isGettingCurrentLocation
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.primaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.my_location_rounded,
                        color: widget.primaryColor,
                      ),
                onPressed: _isGettingCurrentLocation ? null : _getCurrentLocation,
              ),
            ),
          ),

          // Bottom Address Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16).copyWith(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected address
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: widget.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat Terpilih',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress.isNotEmpty
                                  ? _selectedAddress
                                  : 'Memuat alamat...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [Colors.grey[400]!, Colors.grey[300]!]
                              : [widget.primaryColor, widget.primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: _isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: widget.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading || _selectedAddress.isEmpty
                            ? null
                            : () {
                                widget.onAddressSelected(
                                  _selectedAddress,
                                  _selectedPosition,
                                );
                                Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pilih Alamat Ini',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}