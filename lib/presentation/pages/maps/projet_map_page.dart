import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../domain/entities/projet.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/troncon_provider.dart';

class ProjetMapPage extends ConsumerStatefulWidget {
  final Projet projet;

  const ProjetMapPage({
    super.key,
    required this.projet,
  });

  @override
  ConsumerState<ProjetMapPage> createState() => _ProjetMapPageState();
}

class _ProjetMapPageState extends ConsumerState<ProjetMapPage> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  LatLng? _center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tronconsAsyncValue = ref.watch(tronconsByProjetProvider(widget.projet.id!));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Carte - ${widget.projet.nom}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: tronconsAsyncValue.when(
        loading: () => _buildLoadingView(theme),
        error: (error, stackTrace) => _buildErrorView(theme, error),
        data: (troncons) {
          final coordinates = _extractCoordinatesFromTroncons(troncons);
          
          if (coordinates.isEmpty) {
            return _buildNoDataView(theme);
          }

          _buildMapData(coordinates);
          
          return GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Ajuster la caméra pour inclure tous les points
              if (coordinates.length > 1) {
                _fitBounds(coordinates);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _center ?? const LatLng(0, 0),
              zoom: 14.0,
            ),
            polylines: _polylines,
            markers: _markers,
            mapType: MapType.hybrid,
          );
        },
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement de la carte...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune coordonnée disponible',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune image avec coordonnées GPS n\'a été trouvée pour ce projet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<LatLng> _extractCoordinatesFromTroncons(List<Troncon> troncons) {
    List<LatLng> coordinates = [];
    
    for (final troncon in troncons) {
      for (final image in troncon.images) {
        if (image.latitude != null && image.longitude != null) {
          coordinates.add(LatLng(image.latitude!, image.longitude!));
        }
      }
    }
    
    return coordinates;
  }

  void _buildMapData(List<LatLng> coordinates) {
    if (coordinates.isEmpty) return;

    // Regrouper les points proches (dans un rayon de 50 mètres)
    final groupedCoordinates = _groupNearbyCoordinates(coordinates, 50.0);
    
    // Calculer le centre de la carte
    _center = _calculateCenter(groupedCoordinates);
    
    // Créer la polyligne
    _polylines = {
      Polyline(
        polylineId: const PolylineId('projet_route'),
        points: groupedCoordinates,
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
    
    // Créer les marqueurs pour les points groupés
    _markers = {};
    for (int i = 0; i < groupedCoordinates.length; i++) {
      final coordinate = groupedCoordinates[i];
      _markers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: coordinate,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : 
            i == groupedCoordinates.length - 1 ? BitmapDescriptor.hueRed : 
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: i == 0 ? 'Début' : 
                   i == groupedCoordinates.length - 1 ? 'Fin' : 
                   'Point ${i + 1}',
            snippet: 'Lat: ${coordinate.latitude.toStringAsFixed(6)}, Lng: ${coordinate.longitude.toStringAsFixed(6)}',
          ),
        ),
      );
    }
  }

  List<LatLng> _groupNearbyCoordinates(List<LatLng> coordinates, double radiusInMeters) {
    if (coordinates.isEmpty) return [];
    
    List<LatLng> grouped = [];
    List<bool> used = List.filled(coordinates.length, false);
    
    for (int i = 0; i < coordinates.length; i++) {
      if (used[i]) continue;
      
      List<LatLng> group = [coordinates[i]];
      used[i] = true;
      
      // Trouver tous les points proches
      for (int j = i + 1; j < coordinates.length; j++) {
        if (used[j]) continue;
        
        double distance = _calculateDistance(coordinates[i], coordinates[j]);
        if (distance <= radiusInMeters) {
          group.add(coordinates[j]);
          used[j] = true;
        }
      }
      
      // Calculer la moyenne des coordonnées du groupe
      double avgLat = group.map((c) => c.latitude).reduce((a, b) => a + b) / group.length;
      double avgLng = group.map((c) => c.longitude).reduce((a, b) => a + b) / group.length;
      
      grouped.add(LatLng(avgLat, avgLng));
    }
    
    return grouped;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Rayon de la Terre en mètres
    
    double lat1Rad = point1.latitude * math.pi / 180;
    double lat2Rad = point2.latitude * math.pi / 180;
    double deltaLatRad = (point2.latitude - point1.latitude) * math.pi / 180;
    double deltaLngRad = (point2.longitude - point1.longitude) * math.pi / 180;
    
    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
               math.cos(lat1Rad) * math.cos(lat2Rad) *
               math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  LatLng _calculateCenter(List<LatLng> coordinates) {
    if (coordinates.isEmpty) return const LatLng(0, 0);
    
    double avgLat = coordinates.map((c) => c.latitude).reduce((a, b) => a + b) / coordinates.length;
    double avgLng = coordinates.map((c) => c.longitude).reduce((a, b) => a + b) / coordinates.length;
    
    return LatLng(avgLat, avgLng);
  }

  void _fitBounds(List<LatLng> coordinates) {
    if (_mapController == null || coordinates.isEmpty) return;

    double minLat = coordinates.map((c) => c.latitude).reduce(math.min);
    double maxLat = coordinates.map((c) => c.latitude).reduce(math.max);
    double minLng = coordinates.map((c) => c.longitude).reduce(math.min);
    double maxLng = coordinates.map((c) => c.longitude).reduce(math.max);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0), // 100.0 est le padding
    );
  }
} 