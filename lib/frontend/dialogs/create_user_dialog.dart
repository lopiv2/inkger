import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/l10n/app_localizations.dart';

class CreateUserDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createUser),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.user,
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
            ),
            obscureText: true,
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            final username = usernameController.text.trim();
            final password = passwordController.text.trim();
            final email = emailController.text.trim();

            if (username.isNotEmpty && password.isNotEmpty) {
              try {
                await CommonServices.createUser(username, password, email);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.userCreated),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.userCreatedError),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.create),
        ),
      ],
    );
  }
}