import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/create_user_dialog.dart';
import 'package:inkger/frontend/dialogs/edit_user_dialog.dart';
import 'package:inkger/frontend/services/user_services.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await UserServices.fetchUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addUser() async {
    final newUser = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateUserDialog(),
    );

    if (newUser != null) {
      setState(() {
        _users.add(newUser);
      });
    }
  }

  void _editUser(int id) async {
    final userToEdit = _users.firstWhere((user) => user['id'] == id);

    final updatedUser = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditUserDialog(user: userToEdit),
    );

    if (updatedUser != null) {
      setState(() {
        final index = _users.indexWhere((user) => user['id'] == id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });
    }
  }

  void _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas eliminar este usuario?'),
            const Text(
              'Se eliminaran todos los datos asociados a este usuario:\n - Libros creados\n - Fuentes\n - Configuraciones',
              style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await UserServices.deleteUser(id);
        if (success) {
          setState(() {
            _users.removeWhere((user) => user['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return 'Formato inválido';
    }
  }

  Future<String> _getLoggedStatus(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final loggedUsername = prefs.getString('username');
    final loggedEmail = prefs.getString('email');

    if (username == loggedUsername && email == loggedEmail) {
      return AppLocalizations.of(context)!.loggedIn;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          Tooltip(
            message: 'Agregar Usuario',
            child: IconButton(icon: const Icon(Icons.add), onPressed: _addUser),
          ),
        ],
      ),
      body: _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : DataTable(
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.name)),
                DataColumn(label: Text(AppLocalizations.of(context)!.email)),
                DataColumn(label: Text(AppLocalizations.of(context)!.user)),
                DataColumn(label: Text(AppLocalizations.of(context)!.role)),
                DataColumn(
                  label: Text(AppLocalizations.of(context)!.creationDate),
                ),
                DataColumn(
                  label: Text(AppLocalizations.of(context)!.lastLogin),
                ),
                DataColumn(label: Text(AppLocalizations.of(context)!.loggedIn)),
                DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
              ],
              rows: _users
                  .map(
                    (user) => DataRow(
                      cells: [
                        DataCell(Text(user['name'])),
                        DataCell(Text(user['email'])),
                        DataCell(Text(user['username'] ?? 'N/A')),
                        DataCell(Text(user['role'] ?? 'N/A')),
                        DataCell(Text(_formatDate(user['createdAt']))),
                        DataCell(Text(_formatDate(user['lastLogin']))),
                        DataCell(
                          FutureBuilder<String>(
                            future: _getLoggedStatus(
                              user['username'],
                              user['email'],
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('');
                              }
                              return Text(
                                snapshot.data ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editUser(user['id']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteUser(user['id']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
