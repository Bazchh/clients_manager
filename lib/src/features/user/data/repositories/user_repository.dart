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
        await _client.from('users').insert(user.toMap()).select().single();

    if (userResponse == null) {
      throw Exception('Error creating user: Response is null');
    }

    final profileResponse = await _client
        .from('user_profiles')
        .insert(user.toProfileMap())
        .select()
        .single();

    if (profileResponse == null) {
      throw Exception('Error creating user profile: Response is null');
    }
  }

  Future<List<ExtendedUser>> getAllUsers() async {
    final List<dynamic> response =
        await _client.from('users').select('*, user_profiles(*)');

    if (response.isEmpty) {
      throw Exception('Error fetching users: No data returned');
    }

    return response.map((data) {
      final profileData = data['user_profiles'] ?? {};
      final user = User.fromJson(data);
      if (user == null) {
        throw Exception('Error parsing user data');
      }
      return ExtendedUser.fromMap(profileData, user);
    }).toList();
  }

  Future<ExtendedUser?> getUserById(String id) async {
    final response = await _client
        .from('users')
        .select('*, user_profiles(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final profileData = response['user_profiles'] ?? {};
    final user = User.fromJson(response);
    if (user == null) {
      throw Exception('Error parsing user data');
    }
    return ExtendedUser.fromMap(profileData, user);
  }

  Future<void> updateUser(ExtendedUser updatedUser) async {
    final userResponse = await _client
        .from('users')
        .update(updatedUser.toMap())
        .eq('id', updatedUser.supabaseUser.id)
        .select()
        .single();

    if (userResponse == null) {
      throw Exception('Error updating user: No data returned');
    }

    final profileResponse = await _client
        .from('user_profiles')
        .update(updatedUser.toProfileMap())
        .eq('id', updatedUser.supabaseUser.id)
        .select()
        .single();

    if (profileResponse == null) {
      throw Exception('Error updating user profile: No data returned');
    }
  }

  Future<void> deleteUser(String id) async {
    final profileResponse = await _client
        .from('user_profiles')
        .delete()
        .eq('id', id)
        .select()
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('Error deleting user profile: No data returned');
    }

    final userResponse = await _client
        .from('users')
        .delete()
        .eq('id', id)
        .select()
        .maybeSingle();

    if (userResponse == null) {
      throw Exception('Error deleting user: No data returned');
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
