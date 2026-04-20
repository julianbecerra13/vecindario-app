import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad y Tratamiento de Datos Personales',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'En cumplimiento de la Ley 1581 de 2012 y el Decreto 1377 de 2013',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: AppSizes.lg),
            _Section(
              title: '1. Responsable del Tratamiento',
              body:
                  'Vecindario App es responsable del tratamiento de los datos personales recopilados a través de la aplicación. Los datos son almacenados en servidores de Google Cloud Platform (Firebase) con encriptación en tránsito y en reposo.',
            ),
            _Section(
              title: '2. Datos Recopilados',
              body:
                  'Recopilamos: nombre completo, correo electrónico, número de teléfono, torre/apartamento (obligatorios); foto de perfil (opcional); documento de verificación (solo si el administrador lo solicita, eliminado automáticamente a los 30 días). NO recopilamos datos de ubicación ni geolocalización.',
            ),
            _Section(
              title: '3. Finalidad del Tratamiento',
              body:
                  'Sus datos personales se utilizan para: identificación dentro de la comunidad, verificación de residencia, gestión de pedidos y entregas, comunicaciones oficiales de la administración, y mejora del servicio mediante analytics agregados.',
            ),
            _Section(
              title: '4. Derechos del Titular (ARCO)',
              body:
                  'Usted tiene derecho a:\n• Acceder a sus datos personales\n• Rectificar información inexacta\n• Cancelar/suprimir sus datos (eliminación de cuenta)\n• Oponerse al tratamiento de datos opcionales\n\nEjerza estos derechos desde la sección "Mi Privacidad" en su perfil.',
            ),
            _Section(
              title: '5. Descarga de Datos',
              body:
                  'Puede solicitar una copia de todos sus datos personales en formato JSON. La solicitud se procesa en un máximo de 48 horas y se entrega por correo electrónico.',
            ),
            _Section(
              title: '6. Eliminación de Cuenta',
              body:
                  'Al solicitar eliminación, se aplica un período de gracia de 15 días durante el cual puede reactivar su cuenta. Después de 15 días:\n• Se eliminan: perfil, foto, documentos, tokens\n• Se anonimizan: posts, reseñas y pedidos (se cambia el nombre a "Usuario eliminado")',
            ),
            _Section(
              title: '7. Retención de Datos',
              body:
                  'Los datos personales se conservan mientras la cuenta esté activa. El historial de pedidos se anonimiza después de 12 meses. Los documentos de verificación se eliminan 30 días después de la aprobación.',
            ),
            _Section(
              title: '8. Consentimientos',
              body:
                  'El tratamiento de datos requiere autorización previa, expresa e informada. Puede revocar el consentimiento de notificaciones push, email de novedades y datos de uso (analytics) de forma independiente desde "Mi Privacidad".',
            ),
            _Section(
              title: '9. Seguridad',
              body:
                  'Implementamos medidas de seguridad que incluyen: encriptación TLS en tránsito, encriptación en reposo (Firebase), autenticación con tokens JWT, reglas de seguridad en base de datos, y logs de auditoría para acciones administrativas.',
            ),
            _Section(
              title: '10. Cambios en la Política',
              body:
                  'Cualquier cambio en esta política será notificado a los usuarios y requerirá nueva aceptación antes de continuar usando la App.',
            ),
            _Section(
              title: '11. Contacto',
              body:
                  'Para consultas sobre el tratamiento de sus datos personales, contáctenos a través de la sección PQRS de la aplicación o al correo electrónico de soporte.',
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
