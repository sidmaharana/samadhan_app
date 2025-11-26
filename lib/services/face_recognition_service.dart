import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

class FaceRecognitionService {
  final String _baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> _handleResponse(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(responseBody);
    } else {
      String errorMessage;
      switch (response.statusCode) {
        case 404:
          errorMessage = 'API endpoint not found.';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          break;
        default:
          errorMessage = 'Failed with status code: ${response.statusCode}';
      }
      return {'error': errorMessage, 'details': responseBody};
    }
  }

  Future<Map<String, dynamic>> recognizeFaces(List<File> imageFiles) async {
    final uri = Uri.parse('$_baseUrl/recognize/');
    final request = http.MultipartRequest('POST', uri);

    for (var imageFile in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath('files', imageFile.path));
    }

    try {
      final response = await request.send().timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      return {'error': 'Network error. Please check your connection and ensure the server is running.'};
    } on TimeoutException {
      return {'error': 'Request timed out. The server might be busy.'};
    } catch (e) {
      return {'error': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> trainFace(int personId, String name, List<File> imageFiles) async {
    final uri = Uri.parse('$_baseUrl/train/');
    final request = http.MultipartRequest('POST', uri);

    request.fields['person_id'] = personId.toString();
    request.fields['name'] = name;

    for (var imageFile in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath('files', imageFile.path));
    }

    try {
      final response = await request.send().timeout(const Duration(seconds: 30));
      return await _handleResponse(response);
    } on SocketException {
      return {'error': 'Network error. Please check your connection and ensure the server is running.'};
    } on TimeoutException {
      return {'error': 'Request timed out. The server might be busy.'};
    } catch (e) {
      return {'error': 'An unexpected error occurred: $e'};
    }
  }
}
