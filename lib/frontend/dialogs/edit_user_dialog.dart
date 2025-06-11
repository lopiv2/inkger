import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/user_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';

class EditUserDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const EditUserDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final usernameController = TextEditingController(text: user['username']);
    final roleController = ValueNotifier<String>(
      user['role']?.toLowerCase() == 'admin' ? 'Admin' : 'User',
    );

    return AlertDialog(
      title: const Text('Editar Usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            ValueListenableBuilder<String>(
              valueListenable: roleController,
              builder: (context, value, child) {
                return DropdownButtonFormField<String>(
                  value: value,
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'User', child: Text('User')),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      roleController.value = newValue;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            final updatedUser = {
              'id': user['id'],
              'name': nameController.text,
              'email': emailController.text,
              'username': usernameController.text,
              'role': roleController.value.toUpperCase(),
            };

            try {
              bool success = await UserServices.updateUserData(
                user['id'],
                usernameController.text,
                emailController.text,
                nameController.text,
                role: roleController.value.toUpperCase(),
              );
              if (success) {
                CustomSnackBar.show(
                  context,
                  AppLocalizations.of(context)!.userUpdated,
                  Colors.green,
                  duration: const Duration(seconds: 2),
                );
              } else {
                CustomSnackBar.show(
                  context,
                  AppLocalizations.of(context)!.userUpdatedError,
                  Colors.red,
                  duration: const Duration(seconds: 2),
                );
              }
              Navigator.of(context).pop(updatedUser);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al actualizar usuario: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
