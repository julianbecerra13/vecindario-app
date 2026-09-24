# Plan de acción — feedback de prueba física

## P0 — Bloqueadores de uso

- [x] Habilitar acceso del residente al centro administrativo.
- [x] Agregar botón central permanente para comunicarse con administración.
- [x] Conectar quejas, citas y reservas con flujos persistidos en Firebase.
- [x] Reparar y probar comentarios en noticias.
- [x] Validar Me gusta en noticias con pruebas de repositorio y reglas.
- [x] Mantener acceso visible a Mis pedidos y su seguimiento.

## P1 — Transparencia administrativa

- [x] Exponer al residente saldos, multas, PQRS, finanzas, manuales, circulares y asambleas.
- [ ] Completar datos demostrativos de presupuesto, gastos, estados de cuenta y documentos.
- [ ] Añadir agenda real de citas con disponibilidad, reprogramación y cancelación.
- [ ] Añadir radicado visible, historial de respuestas y notificaciones de PQRS.
- [ ] Validar permisos de cada módulo con pruebas de reglas de Firebase.

## P1 — Multimedia y compartir

- [ ] Inicializar Firebase Storage en producción.
- [ ] Adjuntar imágenes, documentos, audios y videos a noticias y solicitudes.
- [x] Generar enlaces profundos para compartir publicaciones, no copiar solo el texto.
- [ ] Agregar visor/descarga y límites de tamaño y formato.

## P2 — Servicios, catálogo y reputación

- [ ] Fotografías para servicios y productos.
- [x] Precio fijo, rango, consultar precio o sin precio.
- [ ] Importar catálogo mediante Excel y agruparlo por negocio.
- [x] Mostrar responsable, conjunto y contacto del servicio.
- [x] Solicitar por WhatsApp desde el detalle del servicio.
- [x] Crear calificaciones y reseñas firmadas o anónimas.

## P2 — Tienda, pedidos y fiados

- [x] Sustituir pago en línea por pedido con método de transferencia.
- [x] Permitir cancelar pedidos antes de estar en camino.
- [ ] Permitir rehacer pedidos cancelados conservando sus productos.
- [ ] Mejorar historial y seguimiento de pedidos.
- [ ] Diseñar fiados con cupo, movimientos, saldo y código por residente.

## P1 — Acceso QR a zonas comunes

- [x] Generar QR temporal de un solo uso para el residente.
- [x] Permitir lectura únicamente a administradores y operarios autorizados.
- [x] Registrar zona, residentes, visitantes, operario y fecha.
- [x] Mostrar estado informativo de administración sin bloquear por deuda.
- [x] Permitir al administrador gestionar operarios y estado de administración.
- [x] Probar aislamiento entre conjuntos, suplantación y reutilización del token.
- [x] Desplegar reglas de seguridad en Firebase.
- [ ] Realizar prueba física de cámara y flujo entre dos celulares.

## Criterio de entrega

Cada bloque se entrega únicamente después de análisis estático, pruebas automatizadas,
prueba de reglas Firebase y recorrido físico o emulado del flujo completo.
