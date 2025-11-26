import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class HorariosScreen extends StatelessWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(title: 'Gestión de Horarios'),
      ),
      body: Center(
        child: Text('Contenido de la Gestión de Horarios de Trabajo'),
      ),
    );
  }
}
