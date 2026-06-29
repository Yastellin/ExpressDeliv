import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/socket_service.dart';

class SuiviCartePage extends StatefulWidget {
  final String livraisonId;
  final String adresseLivraison;
  final double? initialLat;
  final double? initialLng;

  const SuiviCartePage({
    super.key,
    required this.livraisonId,
    required this.adresseLivraison,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<SuiviCartePage> createState() => _SuiviCartePageState();
}

class _SuiviCartePageState extends State<SuiviCartePage> {
  late LatLng _livreurPosition;
  LatLng? _destinationPosition;
  bool _isConnected = false;

  // Position de départ (si fournie, sinon on simule)
  @override
  void initState() {
    super.initState();
    // Position initiale du livreur (ou simulation)
    _livreurPosition = LatLng(
      widget.initialLat ?? -18.8792, // Latitude Fianarantsoa par défaut
      widget.initialLng ?? 47.5079,  // Longitude Fianarantsoa par défaut
    );

    // Point de livraison (simulé à 500m de là)
    _destinationPosition = LatLng(
      _livreurPosition.latitude + 0.005,
      _livreurPosition.longitude + 0.005,
    );

    // Rejoindre la room pour recevoir les positions GPS
    SocketService.joinRoom(widget.livraisonId);

    // Écouter les mises à jour GPS
    SocketService.listenToGpsUpdates((data) {
      if (data['livraison_id'] == widget.livraisonId) {
        setState(() {
          final lat = data['lat'];
          final lng = data['lng'];
          _livreurPosition = LatLng(
            lat is double ? lat : (lat is int ? lat.toDouble() : double.parse(lat.toString())),
            lng is double ? lng : (lng is int ? lng.toDouble() : double.parse(lng.toString())),
          );
        });
      }
    });

    // Simuler des positions si pas de GPS réel (pour la démo)
    _simulateGps();
  }

  void _simulateGps() {
    // Simule un déplacement toutes les 2 secondes pendant 30 secondes
    int step = 0;
    final maxSteps = 15;

    Future.delayed(Duration(seconds: 2), () {
      _moveLivreur(step, maxSteps);
    });
  }

  void _moveLivreur(int step, int maxSteps) {
    if (step >= maxSteps || !mounted) return;

    // Calculer la progression vers la destination
    final progress = step / maxSteps;
    if (_destinationPosition != null) {
      final baseLat = widget.initialLat ?? _livreurPosition.latitude;
      final baseLng = widget.initialLng ?? _livreurPosition.longitude;
      final lat = baseLat + (_destinationPosition!.latitude - baseLat) * progress;
      final lng = baseLng + (_destinationPosition!.longitude - baseLng) * progress;

      setState(() {
        _livreurPosition = LatLng(lat, lng);
      });

      // Envoyer la position simulée via Socket (pour que les clients connectés la reçoivent)
      SocketService.sendGpsUpdate(widget.livraisonId, lat, lng);
    }

    // Continuer le déplacement
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) _moveLivreur(step + 1, maxSteps);
    });
  }

  @override
  void dispose() {
    SocketService.leaveRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi en direct'),
        backgroundColor: AppColors.card,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Carte
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _livreurPosition,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.expressdeliv.app',
                ),
                // Marqueur du livreur
                MarkerLayer(
                  markers: [
                    // Marqueur du livreur
                    Marker(
                      point: _livreurPosition,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(LucideIcons.truck, color: Colors.white, size: 20),
                      ),
                    ),
                    // Marqueur de destination
                    if (_destinationPosition != null)
                      Marker(
                        point: _destinationPosition!,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(LucideIcons.mapPin, color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Informations en bas
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.truck, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Livreur en mouvement',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            'Position mise à jour en temps réel',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.adresseLivraison,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}