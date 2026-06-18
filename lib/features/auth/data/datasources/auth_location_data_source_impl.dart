import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_location_data_source.dart';

class AuthLocationDataSourceImpl implements AuthLocationDataSource {
  @override
  Future<CustomerAddressInput> getCurrentLocationAddress() async {
   loc.Location location =  loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
      if (!serviceEnabled) {
      throw Failures(
        message: 'Location services are turned off on this device.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Failures(message: 'Location permissions are denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Failures(
        message:
            'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final placemark = placemarks.isNotEmpty ? placemarks.first : null;

    return CustomerAddressInput(
      addressLine1: _composeAddressLine1(placemark),
      addressLine2: _composeAddressLine2(placemark),
      city: placemark?.locality ?? placemark?.subAdministrativeArea ?? '',
      state: placemark?.administrativeArea ?? '',
      postalCode: placemark?.postalCode ?? '',
      country: placemark?.country ?? '',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _composeAddressLine1(Placemark? placemark) {
    final parts = <String>[
      if ((placemark?.street ?? '').trim().isNotEmpty)
        placemark!.street!.trim(),
      if ((placemark?.subLocality ?? '').trim().isNotEmpty)
        placemark!.subLocality!.trim(),
    ];

    return parts.isEmpty ? 'Current location' : parts.join(', ');
  }

  String _composeAddressLine2(Placemark? placemark) {
    final parts = <String>[
      if ((placemark?.thoroughfare ?? '').trim().isNotEmpty)
        placemark!.thoroughfare!.trim(),
      if ((placemark?.subThoroughfare ?? '').trim().isNotEmpty)
        placemark!.subThoroughfare!.trim(),
    ];

    return parts.join(', ');
  }
}
