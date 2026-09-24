# Control de acceso a zonas comunes

Primera implementación: ruta /community-access, entrada desde el centro comunitario.
El residente emite un token de cinco minutos, sin información personal en el QR.
El empleado debe estar verificado y tener access_staff/{uid}.active=true,
asignado exclusivamente por el administrador de su comunidad.
El registro consume el token y crea access_logs/{token} en una transacción.
El operario introduce zona, residentes y visitantes. Estos conteos son declarados,
no identifican individualmente al visitante. No se permite validación sin conexión.

Estado de administración: access_status/{residentUid}.status puede ser current,
overdue o unknown. Solo administración lo modifica. No hay sincronización automática
con contabilidad todavía; sin documento se muestra Sin información. Nunca bloquea
el ingreso por deuda. No sustituye documento de identidad ni evita que alguien comparta
un QR vigente; el operario debe verificar la identidad presencialmente.

La administración ya dispone de gestión visual de operarios y puede registrar el
estado informativo de cada residente. Las reglas fueron desplegadas en Firebase.

Pendiente antes de una operación real: sincronización contable automática,
QR individual de visitantes, registro de salidas y ocupación, historial visible,
limpieza de tokens vencidos y pruebas del flujo entre dos teléfonos físicos.
