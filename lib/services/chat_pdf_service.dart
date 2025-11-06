import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPdfService {
  // Replace with your actual API endpoint
  static const String baseUrl = 'https://your-api-server.com/api';

  Future<String> uploadPdf({
    required String filePath,
    required String documentId,
    required String userId,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-pdf'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['documentId'] = documentId;
      request.fields['userId'] = userId;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return data['documentId'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload PDF failed: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String documentId,
    required String userId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'documentId': documentId,
          'userId': userId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Chat failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Send message failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory({
    required String documentId,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/chat-history?documentId=$documentId&userId=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Get history failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get chat history failed: $e');
    }
  }
}
