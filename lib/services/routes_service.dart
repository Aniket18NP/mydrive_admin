import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

class RoutesService {
  static Future<Map<String, dynamic>?> getRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final url = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': ApiKeys.googleRoutesApiKey,
        'X-Goog-FieldMask':
            'routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration',
      },
      body: jsonEncode({
        "origin": {
          "location": {
            "latLng": {
              "latitude": originLat,
              "longitude": originLng,
            }
          }
        },
        "destination": {
          "location": {
            "latLng": {
              "latitude": destinationLat,
              "longitude": destinationLng,
            }
          }
        },
        "travelMode": "DRIVE",
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    print(response.body);
    return null;
  }
}