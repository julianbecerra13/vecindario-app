import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:vecindario_app/core/utils/logger.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

class CloudFunctionsService {
  final FirebaseAuth _auth;

  // URL base de Cloud Functions (cambiar en producción)
  static const _baseUrl =
      'https://us-central1-vecindario-app-a746b.cloudfunctions.net';

  CloudFunctionsService(this._auth);

  Future<Map<String, dynamic>> callFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final url = Uri.parse('$_baseUrl/$functionName');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      AppLogger.error(
        'Cloud Function $functionName failed: ${response.statusCode}',
        response.body,
      );
      throw CloudFunctionException(
        functionName,
        response.statusCode,
        response.body,
      );
    }
  }

  // --- Funciones específicas ---

  Future<Map<String, dynamic>> approveResident(
      String uid, String communityId) {
    return callFunction('ApproveResident', {
      'uid': uid,
      'communityId': communityId,
    });
  }

  Future<Map<String, dynamic>> rejectResident(
      String uid, String communityId) {
    return callFunction('RejectResident', {
      'uid': uid,
      'communityId': communityId,
    });
  }

  Future<Map<String, dynamic>> rotateInviteCode(String communityId) {
    return callFunction('RotateInviteCode', {
      'communityId': communityId,
    });
  }

  Future<Map<String, dynamic>> createOrder(
      String storeId, List<Map<String, dynamic>> items) {
    return callFunction('CreateOrder', {
      'storeId': storeId,
      'items': items,
    });
  }
}

class CloudFunctionException implements Exception {
  final String functionName;
  final int statusCode;
  final String body;

  CloudFunctionException(this.functionName, this.statusCode, this.body);

  @override
  String toString() => 'CloudFunctionException($functionName): $statusCode';
}

final cloudFunctionsProvider = Provider<CloudFunctionsService>((ref) {
  return CloudFunctionsService(ref.watch(firebaseAuthProvider));
});
