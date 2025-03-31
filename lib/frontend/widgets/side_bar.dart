import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/dialogs/edit_library_dialog.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:inkger/l10n/app_localizations.dart';

class Sidebar extends StatelessWidget {
  final Function(String)
  onItemSelected; // Callback para manejar la selección de opciones

  const Sidebar({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey, // Color de fondo
        border: Border.all(
          color: Colors.black, // Color del borde
          width: 2, // Grosor del borde
        ),
      ),
      width: 250, // Ancho fijo
      child: SingleChildScrollView(
        // Se usa para evitar problemas de espacio
        child: Column(
          children: [
            _buildMenuItem(Icons.home, 'Inicio', 'Home'),
            _buildLibraryMenu(context),
            _buildMenuItem(Icons.category, 'Categorías', 'categories'),
            _buildMenuItem(Icons.list, 'Listas de lectura', 'lists'),
            _buildMenuItem(Icons.collections_bookmark, 'Series', 'series'),
            _buildMenuItem(Icons.book, 'Estanterías', 'shelves'),
            _buildMenuItem(Icons.help_center, 'Tests', 'Tests'),
          ],
        ),
      ),
    );
  }

  // Método para construir el menú desplegable de "Bibliotecas"
  Widget _buildLibraryMenu(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        Icons.library_books,
        color: Colors.white,
      ), // Ícono de Bibliotecas
      title: Text('Bibliotecas', style: TextStyle(color: Colors.white)),
      children: [
        // Elementos anidados
        _buildNestedMenuItem(context, 'Comics', 'comics'),
        _buildNestedMenuItem(
          context,
          AppLocalizations.of(context)!.books,
          'books',
        ),
        _buildNestedMenuItem(
          context,
          AppLocalizations.of(context)!.audiobooks,
          'audiobooks',
        ),
      ],
    );
  }

  // Método para construir elementos anidados
  Widget _buildNestedMenuItem(
    BuildContext context,
    String title,
    String libraryId,
  ) {
    IconData leadingIcon;
    switch (libraryId) {
      case 'comics':
        leadingIcon = Icons.question_answer; // Icono para comic
        break;
      case 'books':
        leadingIcon = Icons.menu_book; // Icono para libro
        break;
      case 'audiobooks':
        leadingIcon = Icons.headphones; // Icono para audiolibro
        break;
      default:
        leadingIcon = Icons.bubble_chart; // Icono por defecto si no se encuentra un tipo válido
    }
    return Padding(
      padding: EdgeInsets.only(left: 30), // Sangría para los elementos anidados
      child: ListTile(
        leading: Icon(leadingIcon,color: Colors.white),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white), // Ícono de menú
          onSelected: (String value) {
            // Acciones al seleccionar una opción del menú
            switch (value) {
              case 'edit':
                _showEditDialog(context, title, libraryId);
                ; // Mostrar diálogo de edición
                break;
              case 'scan':
                Constants.logger.info('Scan $title');
                break;
              case 'update_metadata':
                Constants.logger.info('Update metadata of $title');
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'scan',
                child: Row(
                  children: [
                    Icon(Icons.scanner, color: Colors.black),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.scan),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'update_metadata',
                child: Row(
                  children: [
                    Icon(Icons.update, color: Colors.black),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.updateMetadata),
                  ],
                ),
              ),
            ];
          },
        ),
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {
          context.go(
            '/${libraryId.toLowerCase()}',
          ); // Path dinámico basado en el tipo
        },
      ),
    );
  }

  // Método para mostrar el diálogo de edición
  void _showEditDialog(BuildContext context, String title, String libraryId) {
    showDialog(
      context: context,
      builder: (context) {
        return EditLibraryDialog(
          libraryTitle: title,
          libraryId: libraryId, // Pasar el ID de la biblioteca
        );
      },
    );
  }

  // Método para construir cada opción del menú
  Widget _buildMenuItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ), // Eliminamos SizedBox innecesario
      title: Text(title, style: TextStyle(color: Colors.white)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 10,
      ), // Reducimos el padding
      minLeadingWidth: 30, // Evita que el icono consuma todo el espacio
      onTap: () {
        onItemSelected(value);
      },
    );
  }
}
