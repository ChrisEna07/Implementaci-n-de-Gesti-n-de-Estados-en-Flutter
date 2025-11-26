import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  // Permitimos acciones opcionales para botones en la AppBar (ej. botón "Agregar")
  final List<Widget>? actions;

  // Implementamos PreferredSizeWidget para que pueda ser usado como AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions, // Los actions pueden ser nulos si no se necesitan botones extra
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      // Centra el título en todas las plataformas
      centerTitle: true,
      // Estilo de color consistente
      backgroundColor: Colors.blue.shade700,
      // Se pasan las acciones que la pantalla que lo llama requiera
      actions: actions,
    );
  }
}
