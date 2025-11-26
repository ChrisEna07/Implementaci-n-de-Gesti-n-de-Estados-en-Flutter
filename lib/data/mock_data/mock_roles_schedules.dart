// Definición de Roles
const List<String> availableRoles = [
  'Administrador',
  'Mecánico',
  'Vendedor',
  'Gerente',
  'Recepcionista'
];

// Definición de Horarios (Ejemplo de rangos de trabajo por día)
const Map<String, List<String>> availableSchedules = {
  'Lunes': ['08:00-12:00', '14:00-18:00'],
  'Martes': ['08:00-12:00', '14:00-18:00'],
  'Miércoles': ['08:00-12:00', '14:00-18:00'],
  'Jueves': ['08:00-12:00', '14:00-18:00'],
  'Viernes': ['08:00-12:00', '14:00-17:00'],
  'Sábado': ['09:00-13:00'],
  'Domingo': ['Cerrado'],
};
