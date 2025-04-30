import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/user.dart';
import 'package:inkger/frontend/services/user_services.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de importar tu modelo de usuario

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  List<String> roles = [];
  User? user;

  final _passwordFormKey = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();

  bool _isPasswordChanging = false;

  @override
  void initState() {
    super.initState();
    loadUserDetails();
    loadRoles();
  }

  Future<void> loadRoles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String rolesString =
        prefs.getString('role') ?? ''; // Obtén el string de roles
    setState(() {
      roles = rolesString.isNotEmpty
          ? rolesString.split(',')
          : []; // Convierte el string en una lista
    });
  }

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    final fetchedUser = await UserServices.getUserDetails(userId!);

    setState(() {
      user = fetchedUser;
      _usernameController.text = user!.username;
      _emailController.text = user!.email;
      _nameController.text = user!.name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Lógica para editar perfil
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildUserInfoSection(),
          const SizedBox(height: 24),
          _buildAccountInfoSection(),
          const SizedBox(height: 24),
          _buildPasswordChangeSection(),
          const SizedBox(height: 24),
          _buildProfileEditSection(), // Sección para editar username, email y nombre
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _getSafeAvatarImage(widget.user.avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.name ?? widget.user.username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (widget.user.name != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '@${widget.user.username}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  ImageProvider _getSafeAvatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const AssetImage('images/avatars/avatar_01.png');
    }

    try {
      if (!avatarUrl.startsWith('http')) {
        throw Exception('Invalid URL');
      }

      if (avatarUrl.contains('<!DOCTYPE') ||
          avatarUrl.startsWith('<html') ||
          avatarUrl.length < 20) {
        throw Exception('Non-image URL');
      }

      return NetworkImage(avatarUrl);
    } catch (e) {
      debugPrint('Error loading avatar: $e');
      return const AssetImage('images/avatars/avatar_01.png');
    }
  }

  Widget _buildUserInfoSection() {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.email, 'Email:', user!.email),
            _buildInfoRow(Icons.person, 'Username:', user!.username),
            if (user!.name != null && user!.name!.isNotEmpty)
              _buildInfoRow(Icons.badge, 'Nombre completo:', user!.name!),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              'Miembro desde:',
              widget.user.createdAt != null
                  ? DateFormat('dd MMM yyyy').format(widget.user.createdAt!)
                  : 'Fecha no disponible',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.update,
              'Última actualización:',
              widget.user.updatedAt != null
                  ? DateFormat(
                      'dd MMM yyyy - HH:mm',
                    ).format(widget.user.updatedAt!)
                  : 'No actualizado',
            ),
            _buildInfoRow(
              Icons.update,
              'Última conexion:',
              widget.user.lastLogin != null
                  ? DateFormat(
                      'dd MMM yyyy - HH:mm',
                    ).format(widget.user.lastLogin!)
                  : 'No actualizado',
            ),
            const SizedBox(height: 8),
            _buildRoleChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent.withOpacity(0.2);
      case 'moderator':
        return Colors.blueAccent.withOpacity(0.2);
      default:
        return Colors.greenAccent.withOpacity(0.2);
    }
  }

  Widget _buildRoleChips() {
    return Wrap(
      spacing: 8.0,
      children: roles.map((role) {
        return Chip(
          label: Text(role.toUpperCase()),
          backgroundColor: _getRoleColor(role),
        );
      }).toList(),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar Contraseña',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _passwordFormKey, // Use unique key for password form
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      hintText: 'Introduce tu nueva contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña no puede estar vacía';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Guardar Contraseña'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileEditSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _profileFormKey, // Use unique key for profile edit form
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo nombre de usuario',
                      hintText: 'Introduce un nuevo nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre de usuario no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo correo electrónico',
                      hintText: 'Introduce un nuevo correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El correo electrónico no puede estar vacío';
                      }
                      if (!RegExp(
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                      ).hasMatch(value)) {
                        return 'Por favor ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo nombre completo',
                      hintText: 'Introduce tu nombre completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre completo no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProfileChanges,
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');
      bool success = await UserServices.updatePassword(
        userId!,
        _passwordController.text,
      );
      if (success) {
        // Manejo seguro de fechas
        CustomSnackBar.show(
          context,
          AppLocalizations.of(context)!.profileSaved,
          Colors.green,
          duration: Duration(seconds: 4),
        );
      } else {
        CustomSnackBar.show(
          context,
          AppLocalizations.of(context)!.profileSavedError,
          Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _saveProfileChanges() async {
    if (_profileFormKey.currentState!.validate()) {
      final username = _usernameController.text;
      final email = _emailController.text;
      final name = _nameController.text;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      // Llamar al servicio para actualizar el perfil
      bool success = await UserServices.updateUserData(
        userId!,
        username,
        email,
        name,
      );

      if (success) {
        await prefs.setString('name', name);
        await prefs.setString('username', username);
        await prefs.setString('email', email);
        // Manejo seguro de fechas
        CustomSnackBar.show(
          context,
          AppLocalizations.of(context)!.profileSaved,
          Colors.green,
          duration: Duration(seconds: 4),
        );
      } else {
        CustomSnackBar.show(
          context,
          AppLocalizations.of(context)!.profileSavedError,
          Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
