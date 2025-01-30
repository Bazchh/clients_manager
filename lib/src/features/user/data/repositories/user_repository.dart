import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

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
      await _client
          .from('user_profiles')
          .delete()
          .eq('id', id); 

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
          throw Exception('Serviço de localização desabilitado.');
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('Permissão de localização negada.');
        }
      }

      locationData = await location.getLocation();
    } catch (e) {
      throw Exception('Erro ao obter localização: $e');
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Informações do Usuário',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('ID: ${user.id}'),
            pw.Text('Email: ${user.email}'),
            pw.Text('Telefone: ${user.phone ?? "N/A"}'),
            pw.Text(
                'Endereço: ${user.street ?? "N/A"}, ${user.locality ?? "N/A"}, ${user.country ?? "N/A"}'),
            pw.Text('CEP: ${user.postalCode ?? "N/A"}'),
            pw.Text('Status: ${user.status.name}'),
            pw.Spacer(),
            pw.Text(
              'Gerado em: ${DateTime.now()} | Coordenadas: ${locationData.latitude}, ${locationData.longitude}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/user_${user.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
