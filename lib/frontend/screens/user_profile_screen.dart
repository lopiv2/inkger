import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/user.dart';
import 'package:intl/intl.dart'; // Asegúrate de importar tu modelo de usuario

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

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
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _getSafeAvatarImage(user.avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          user.name ?? user.username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (user.name != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '@${user.username}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  // Helper method
  ImageProvider _getSafeAvatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const AssetImage('images/avatars/avatar_01.png');
    }

    try {
      // Basic URL validation
      if (!avatarUrl.startsWith('http')) {
        throw Exception('Invalid URL');
      }

      // Check if it might be an HTML response
      if (avatarUrl.contains('<!DOCTYPE') ||
          avatarUrl.startsWith('<html') ||
          avatarUrl.length < 20) {
        // Very short URLs are suspicious
        throw Exception('Non-image URL');
      }

      return NetworkImage(avatarUrl);
    } catch (e) {
      debugPrint('Error loading avatar: $e');
      return const AssetImage('images/avatars/avatar_01.png');
    }
  }

  Widget _buildUserInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.email, 'Email:', user.email),
            _buildInfoRow(Icons.person, 'Username:', user.username),
            if (user.name != null)
              _buildInfoRow(Icons.badge, 'Nombre completo:', user.name!),
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
              user.createdAt != null
                  ? DateFormat('dd MMM yyyy').format(user.createdAt!)
                  : 'Fecha no disponible',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.update,
              'Última actualización:',
              user.updatedAt != null
                  ? DateFormat('dd MMM yyyy - HH:mm').format(user.updatedAt!)
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

  Widget _buildRoleChips() {
    return Wrap(
      spacing: 8,
      children:
          user.roles
              .map(
                (role) => Chip(
                  label: Text(
                    role.toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getRoleColor(role),
                ),
              )
              .toList(),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent.withOpacity(0.2);
      case 'moderator':
        return Colors.blueAccent.withOpacity(0.2);
      default: // user
        return Colors.greenAccent.withOpacity(0.2);
    }
  }
}
