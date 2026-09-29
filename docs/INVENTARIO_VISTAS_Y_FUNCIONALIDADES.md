# Vecindario — Inventario de vistas y funcionalidades

Fecha de revisión: 25 de septiembre de 2026  
Dispositivo: Samsung SM-G998U, aplicación Android instalada en modo release  
Comunidad observada: Torres del Parque

## Evidencia capturada — residente

| # | Vista | Funcionalidad principal | Evidencia |
|---|---|---|---|
| 00 | Inicio de sesión | Acceso por correo y contraseña, recuperación de contraseña, registro y acceso con Google. | `screenshots/00_estado_actual.png` |
| 01 | Noticias | Muestra publicaciones de la comunidad, fijados, autor, fecha, reacciones, comentarios y compartir; permite abrir el detalle y crear publicaciones. | `screenshots/residente/01_inicio.png` |
| 02 | Vecinos | Catálogo de servicios ofrecidos por residentes, filtros por categoría, ordenamiento y opción para ofrecer un servicio. | `screenshots/residente/02_vecinos.png` |
| 03 | Tiendas | Lista de tiendas y productos de la comunidad; permite consultar comercio, catálogo y proceso de pedido. | `screenshots/residente/03_tiendas.png` |
| 04 | Servicios | Directorio de proveedores externos recomendados, filtros por oficio, reputación y llamada directa. | `screenshots/residente/04_servicios.png` |
| 05 | Administración del conjunto | Centro principal del residente: QR, solicitudes, reservas, información financiera, documentos y transparencia. | `screenshots/residente/05_administracion.png` |
| 06 | Mi QR | Identifica al residente para el ingreso a zonas comunes; genera un QR temporal de un solo uso que debe validarse en línea. | `screenshots/residente/06_mi_qr.png` |
| 07 | Presentar una queja | Formulario para radicar una PQRS o queja ante la administración y realizar seguimiento posterior. | `screenshots/residente/07_presentar_queja.png` |
| 08 | Solicitar una cita | Formulario para pedir una cita con la administración. | `screenshots/residente/08_solicitar_cita.png` |
| 09 | Zonas sociales | Lista de zonas disponibles con descripción, capacidad, horario, precio y depósito. | `screenshots/residente/09_reservar_zona.png` |
| 10 | Calendario de zona | Consulta de disponibilidad y selección de fecha/horario para reservar una zona social. | `screenshots/residente/10_calendario_zona.png` |
| 11 | Estado de cuenta | Consulta de cuotas, pagos, movimientos y saldo del residente. En la cuenta observada no había datos disponibles. | `screenshots/residente/11_saldo_estado_cuenta.png` |
| 12 | Mis multas | Consulta de sanciones, estado de cada multa y acceso a descargos. | `screenshots/residente/12_multas.png` |
| 13 | Mis solicitudes | Historial de radicados, respuestas y estado de seguimiento. | `screenshots/residente/13_mis_solicitudes.png` |
| 14 | Administración — sección inferior | Acceso a presupuesto, reglamentos, circulares y asambleas. | `screenshots/residente/14_administracion_inferior.png` |
| 15 | Presupuesto y gastos | Transparencia financiera: ingresos, egresos y ejecución presupuestal del conjunto. | `screenshots/residente/15_presupuesto_gastos.png` |
| 16 | Manuales y reglamentos | Consulta del manual de convivencia y documentos normativos. | `screenshots/residente/16_manuales_reglamentos.png` |
| 17 | Circulares | Consulta de avisos y comunicaciones oficiales emitidas por la administración. | `screenshots/residente/17_circulares.png` |
| 18 | Asambleas y actas | Consulta de reuniones, decisiones, convocatorias y documentos de asamblea. | `screenshots/residente/18_asambleas_actas.png` |

## Inventario funcional completo encontrado en el proyecto

### Acceso y vinculación

- Onboarding inicial.
- Inicio de sesión con correo/contraseña y Google.
- Recuperación de contraseña.
- Registro de usuario y verificación telefónica.
- Unión a una comunidad mediante código de edificio.
- Estado de solicitud pendiente de aprobación.

### Comunidad y comunicación

- Feed de noticias, detalle de publicación y creación de publicaciones.
- Reacciones, comentarios y opción de compartir.
- Notificaciones.
- Perfil, edición de perfil, privacidad, términos y política de privacidad.

### Comercio y servicios

- Tiendas, detalle de tienda, panel de tienda y catálogo.
- Seguimiento de pedidos, historial de pedidos y calificación de pedidos.
- Servicios de vecinos, detalle, creación y reseñas.
- Servicios externos recomendados y formulario de recomendación.

### Administración y funciones premium

- Centro de administración del conjunto.
- PQRS, creación y seguimiento.
- Zonas sociales y reservas.
- Estado de cuenta y finanzas.
- Multas, detalle y descargos.
- Manuales y reglamentos.
- Circulares oficiales.
- Asambleas y actas.
- Planes de suscripción.

### Acceso por QR y empleados

- QR temporal del residente para zonas comunes.
- Lector/validación de acceso para empleados.
- Gestión del ingreso, tipo de persona y control relacionado con el estado administrativo.

### Administración, tienda y superadministración

- Aprobaciones pendientes de residentes.
- Configuración de comunidad.
- Creación y administración de multas, finanzas, zonas, circulares y asambleas.
- Panel del comercio para catálogo y pedidos.
- Panel de superadministración, creación de comunidades y detalle administrativo de cada comunidad.

## Estado de esta entrega

La carpeta contiene la evidencia completa del recorrido visible con la sesión residente que estaba activa en el teléfono. Para producir un paquete literalmente exhaustivo de todos los roles todavía se necesita una segunda ronda autenticada como administrador, tienda, empleado y superadministrador. Las vistas exclusivas de esos roles sí existen en el código, pero no se deben presentar como evidencia visual hasta abrirlas en el dispositivo y verificar su estado real.

