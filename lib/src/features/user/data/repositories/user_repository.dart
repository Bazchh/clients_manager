import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:location/location.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<File> generateUniqueFileName(
      Directory downloadsDir, String baseName, String extension) async {
    int counter = 1;
    String fileName = '$baseName$extension';
    File file = File('${downloadsDir.path}/$fileName');

    while (file.existsSync()) {
      fileName = '$baseName ($counter)$extension';
      file = File('${downloadsDir.path}/$fileName');
      counter++;
    }

    return file;
  }

  Future<void> createUser(ExtendedUser user, String password) async {
    try {
      await _client.from('user_profiles').insert({
        'id': user.id,
        'name': user.name,
        'phone': user.phone,
        'street': user.street,
        'locality': user.locality,
        'postal_code': user.postalCode,
        'country': user.country,
        'status': user.status.toString(),
      });

      print("Usuário e perfil criados com sucesso!");
    } catch (error) {
      print("Erro ao criar usuário: $error");
    }
  }

  Future<List<ExtendedUser>> getAllUsers() async {
    try {
      final List<dynamic> response =
          await _client.rpc('get_users_with_profiles');

      if (response.isEmpty) {
        throw Exception('Error fetching users: No data returned');
      }

      return response.map((data) {
        return ExtendedUser.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error in getAllUsers: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<ExtendedUser?> getUserById(String id) async {
    final response = await _client
        .from('auth.users')
        .select('*, user_profiles(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final profileData = response['user_profiles'] ?? {};
    final user = User.fromJson(response);
    if (user == null) {
      throw Exception('Error parsing user data');
    }
    return ExtendedUser.fromMap(profileData);
  }

  Future<void> updateUser(ExtendedUser updatedUser) async {
    try {
      print('Attempting to update user profile for user_id: ${updatedUser.id}');

      await _client.from('user_profiles').update({
        'name': updatedUser.name,
        'phone': updatedUser.phone,
        'street': updatedUser.street,
        'locality': updatedUser.locality,
        'postal_code': updatedUser.postalCode,
        'country': updatedUser.country,
        'status': updatedUser.status.name,
      }).eq('id', updatedUser.id);

      print('User profile updated successfully for user_id: ${updatedUser.id}');
    } catch (e) {
      print('Error updating user profile: $e');
      if (e.toString().contains('404')) {
        throw Exception('User profile not found. Please check the user ID.');
      } else if (e.toString().contains('permission denied')) {
        throw Exception(
            'You do not have permission to update this user profile.');
      } else {
        throw Exception('Failed to update user profile: $e');
      }
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _client.from('user_profiles').delete().eq('id', id);

      await _client.auth.admin.deleteUser(id);

      print('User and profile deleted successfully for user_id: $id');
    } catch (e) {
      print('Error deleting user: $e');
      if (e.toString().contains('406')) {
        throw Exception(
            'Error 406: Not Acceptable. Check your delete operation.');
      } else if (e.toString().contains('permission denied')) {
        throw Exception('You do not have permission to delete this user.');
      } else {
        throw Exception('Failed to delete user: $e');
      }
    }
  }

  Future<File> generateUserPdf(ExtendedUser user) async {
    final pdf = pw.Document();
    final location = Location();
    LocationData locationData;

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location service disabled.');
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('Location permission denied.');
        }
      }

      locationData = await location.getLocation();
    } catch (e) {
      throw Exception('$e');
    }

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Client Profile',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Email: ${user.email}'),
                    pw.Text('Phone: ${user.phone ?? "N/A"}'),
                    pw.Text(
                      'Address: ${user.street ?? "N/A"}, ${user.locality ?? "N/A"}, ${user.country ?? "N/A"}',
                    ),
                    pw.Text('Postal Code: ${user.postalCode ?? "N/A"}'),
                    pw.Text('Status: ${user.status.name}'),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated at: ${DateTime.now()}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                  pw.Text(
                    'Coordinates: ${locationData.latitude}, ${locationData.longitude}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }

    final baseName = user.name ?? 'user_${user.id}';
    final extension = '.pdf';
    final file =
        await generateUniqueFileName(downloadsDir, baseName, extension);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
