import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';

class StylistMapView extends StatelessWidget {
  const StylistMapView({super.key, required this.stylists, this.onStylistTap});

  final List<StylistCardModel> stylists;
  final ValueChanged<StylistCardModel>? onStylistTap;

  @override
  Widget build(BuildContext context) {
    final initial = stylists.isNotEmpty
        ? LatLng(stylists.first.latitude, stylists.first.longitude)
        : const LatLng(9.0192, 38.7525);

    final markers = stylists.map((stylist) {
      return Marker(
        markerId: MarkerId(stylist.stylistId),
        position: LatLng(stylist.latitude, stylist.longitude),
        infoWindow: InfoWindow(
          title: stylist.businessName,
          snippet:
              '${stylist.distanceDisplay} - ETB ${stylist.servicePrice.toStringAsFixed(0)}',
          onTap: onStylistTap == null ? null : () => onStylistTap!(stylist),
        ),
      );
    }).toSet();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: initial, zoom: 13),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}
