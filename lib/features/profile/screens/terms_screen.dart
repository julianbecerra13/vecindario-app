import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Términos de Uso')),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Términos y Condiciones de Uso',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Última actualización: Abril 2026',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: AppSizes.lg),
            _Section(
              title: '1. Aceptación de los Términos',
              body:
                  'Al descargar, instalar o usar la aplicación Vecindario ("la App"), usted acepta estos Términos de Uso. Si no está de acuerdo, no use la App.',
            ),
            _Section(
              title: '2. Descripción del Servicio',
              body:
                  'Vecindario es una plataforma para comunidades residenciales que permite comunicación, comercio entre vecinos, gestión de servicios y administración de propiedad horizontal.',
            ),
            _Section(
              title: '3. Registro y Cuenta',
              body:
                  'Para usar la App debe crear una cuenta con información veraz. La verificación de residencia es obligatoria mediante código de invitación y aprobación del administrador del conjunto. Usted es responsable de mantener la confidencialidad de su cuenta.',
            ),
            _Section(
              title: '4. Uso Aceptable',
              body:
                  'Se compromete a usar la App de forma legal y respetuosa. Está prohibido: publicar contenido ofensivo, spam, información falsa, suplantar identidad, o intentar acceder a comunidades donde no reside.',
            ),
            _Section(
              title: '5. Comercio y Pagos',
              body:
                  'Las transacciones entre vecinos y tiendas son responsabilidad de las partes involucradas. Vecindario cobra una comisión de servicio por cada pedido. Los pagos en línea son procesados por Wompi, un proveedor de pagos regulado.',
            ),
            _Section(
              title: '6. Contenido del Usuario',
              body:
                  'Usted conserva la propiedad de su contenido pero otorga a Vecindario una licencia para mostrarlo dentro de la App. Nos reservamos el derecho de moderar y eliminar contenido que viole estos términos.',
            ),
            _Section(
              title: '7. Privacidad',
              body:
                  'El tratamiento de sus datos personales se rige por nuestra Política de Privacidad, en cumplimiento de la Ley 1581 de 2012 (Habeas Data). Consulte la sección "Mi Privacidad" para ejercer sus derechos.',
            ),
            _Section(
              title: '8. Limitación de Responsabilidad',
              body:
                  'Vecindario no es responsable por la calidad de productos o servicios ofrecidos por terceros a través de la App, ni por daños indirectos derivados del uso de la plataforma.',
            ),
            _Section(
              title: '9. Modificaciones',
              body:
                  'Podemos modificar estos términos en cualquier momento. Se le notificará de cambios significativos y se requerirá nueva aceptación.',
            ),
            _Section(
              title: '10. Legislación Aplicable',
              body:
                  'Estos términos se rigen por las leyes de la República de Colombia. Cualquier disputa será resuelta ante los tribunales de la ciudad de Bogotá.',
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
