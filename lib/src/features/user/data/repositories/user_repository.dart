import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createUser(String email, String password) async {
    try {
      
      // Inserir perfil na tabela user_profiles
      final response = await Supabase.instance.client.auth.signUp(
              email: email,
              password: password,
            );

            if (response.session == null) {
              String errorMessage = 'Unknown error';
              if (response.session != 200) {
                errorMessage =
                    'Failed to create user. Status: ${response.session}';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
              return;
            }

      final user = ExtendedUser(
              id: response.user!.id, // Agora passamos apenas o ID
              email: response.user!.email ?? '', // Garantindo que não seja nulo
              name: _nameController.text,
              phone: _phoneController.text,
              street: _streetController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
              status: _selectedStatus,
            );
      
      await _client.from('user_profiles').insert({
        'id': user.id, // ID do usuário criado no auth
        'name': user.name,
        'phone': user.phone,
        'street': user.street,
        'locality': user.locality,
        'postal_code': user.postalCode,
        'country': user.country,
        'status': user.status.toString(),
        'created_at': DateTime.now().toIso8601String(),
      });

      print("sucess on creating user!");
    } catch (error) {
      print("Erro ao criar usuário: $error");
    }
  }

  Future<List<ExtendedUser>> getAllUsers() async {
    final List<dynamic> response =
        await _client.from('auth.users').select('*, user_profiles(*)');

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
    return ExtendedUser.fromMap(profileData, user);
  }

  Future<void> updateUser(ExtendedUser updatedUser) async {
    final userResponse = await _client
        .from('auth.users')
        .update(updatedUser.toProfileMap())
        .eq('id', updatedUser.id)
        .select()
        .single();

    if (userResponse == null) {
      throw Exception('Error updating user: No data returned');
    }

    final profileResponse = await _client
        .from('user_profiles')
        .update(updatedUser.toProfileMap())
        .eq('id', updatedUser.id)
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
        .from('auth.users')
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
