import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createUser(ExtendedUser user) async {
    final userResponse =
        await _client.from('users').insert(user.toMap()).execute();
    if (userResponse.error != null) {
      throw Exception('Error creating user: ${userResponse.error!.message}');
    }

    final profileResponse = await _client
        .from('user_profiles')
        .insert(user.toProfileMap())
        .execute();
    if (profileResponse.error != null) {
      throw Exception(
          'Error creating user profile: ${profileResponse.error!.message}');
    }
  }

  Future<List<ExtendedUser>> getAllUsers() async {
    final response =
        await _client.from('users').select('*, user_profiles(*)').execute();

    if (response.error != null) {
      throw Exception('Error fetching users: ${response.error!.message}');
    }

    final List<dynamic> dataList = response.data as List<dynamic>;

    return dataList.map((data) {
      final profileData = data['user_profiles'] ?? {};
      return ExtendedUser.fromMap(profileData, User.fromJson(data));
    }).toList();
  }

  Future<ExtendedUser?> getUserById(String id) async {
    final response = await _client
        .from('users')
        .select('*, user_profiles(*)')
        .eq('id', id)
        .single()
        .execute();

    if (response.error != null) {
      throw Exception('Error fetching user: ${response.error!.message}');
    }

    final data = response.data;
    if (data == null) return null;

    final profileData = data['user_profiles'] ?? {};
    return ExtendedUser.fromMap(profileData, User.fromJson(data));
  }

  Future<void> updateUser(ExtendedUser updatedUser) async {
    final userResponse = await _client
        .from('users')
        .update(updatedUser.toMap())
        .eq('id', updatedUser.supabaseUser.id)
        .execute();

    if (userResponse.error != null) {
      throw Exception('Error updating user: ${userResponse.error!.message}');
    }

    final profileResponse = await _client
        .from('user_profiles')
        .update(updatedUser.toProfileMap())
        .eq('id', updatedUser.supabaseUser.id)
        .execute();

    if (profileResponse.error != null) {
      throw Exception(
          'Error updating user profile: ${profileResponse.error!.message}');
    }
  }

  Future<void> deleteUser(String id) async {
    final profileResponse =
        await _client.from('user_profiles').delete().eq('id', id).execute();
    if (profileResponse.error != null) {
      throw Exception(
          'Error deleting user profile: ${profileResponse.error!.message}');
    }

    final userResponse =
        await _client.from('users').delete().eq('id', id).execute();
    if (userResponse.error != null) {
      throw Exception('Error deleting user: ${userResponse.error!.message}');
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
            pw.Text('ID: ${user.supabaseUser.id}'),
            pw.Text('Email: ${user.supabaseUser.email}'),
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
    final file = File('${output.path}/user_${user.supabaseUser.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
