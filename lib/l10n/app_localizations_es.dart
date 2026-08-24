// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Vecindario';

  @override
  String get appSlogan => 'Tu comunidad, conectada';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get name => 'Nombre completo';

  @override
  String get phone => 'Teléfono';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get joinCommunity => 'Unirse a comunidad';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get tower => 'Torre / Bloque';

  @override
  String get apartment => 'Apartamento';

  @override
  String get requestJoin => 'Solicitar ingreso';

  @override
  String get pendingApproval => 'Tu solicitud está en revisión';

  @override
  String get news => 'Noticias';

  @override
  String get neighbors => 'Vecinos';

  @override
  String get services => 'Servicios';

  @override
  String get profile => 'Perfil';

  @override
  String get publish => 'Publicar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get retry => 'Reintentar';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get search => 'Buscar';

  @override
  String get allCategories => 'Todas';

  @override
  String get contactWhatsApp => 'Contactar por WhatsApp';

  @override
  String get privacyTitle => 'Mi Privacidad';

  @override
  String get downloadData => 'Descargar mis datos';

  @override
  String get deleteAccount => 'Eliminar mi cuenta';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get authOrContinueWith => 'o continúa con';

  @override
  String get authContinueWithApple => 'Continuar con Apple';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authSignUpAction => 'Regístrate';

  @override
  String get create => 'Crear';

  @override
  String get edit => 'Editar';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String errorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String errorGeneric(Object message) {
    return 'Error: $message';
  }

  @override
  String errorUnexpected(Object message) {
    return 'Error inesperado: $message';
  }

  @override
  String get savingEllipsis => 'Guardando...';

  @override
  String get errorCommunityNotAvailable => 'Comunidad no disponible';

  @override
  String get errorUserOrCommunityUnavailable =>
      'Usuario o comunidad no disponibles';

  @override
  String get formBasicInfo => 'Información básica';

  @override
  String get formDescriptionLabel => 'Descripción';

  @override
  String get authForgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get authForgotPasswordDesc =>
      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get authForgotPasswordSent =>
      'Se envió un enlace de recuperación a tu correo';

  @override
  String get authSendLink => 'Enviar enlace';

  @override
  String get authCheckEmail => '¡Revisa tu correo!';

  @override
  String authRecoveryLinkSentTo(String email) {
    return 'Te enviamos un enlace de recuperación a $email';
  }

  @override
  String get authBackToLogin => 'Volver al inicio de sesión';

  @override
  String get authJoinCommunityTitle => 'Únete a tu comunidad';

  @override
  String get authJoinCommunityDesc =>
      'Ingresa el código de invitación que te dieron en la administración de tu conjunto.';

  @override
  String get authEnterFullCode => 'Ingresa el código completo';

  @override
  String get authFillTowerAndApartment => 'Completa torre y apartamento';

  @override
  String get authInvalidInviteCode => 'Código de invitación inválido';

  @override
  String get authJoinCommunityError => 'Error al unirse a la comunidad';

  @override
  String get authVerifyPhoneTitle => 'Verificar teléfono';

  @override
  String get authVerificationCodeTitle => 'Código de verificación';

  @override
  String authSmsCodeSentTo(String phone) {
    return 'Enviamos un código SMS al\n+57 $phone';
  }

  @override
  String get authVerify => 'Verificar';

  @override
  String get authResendCode => 'Reenviar código';

  @override
  String get authVerifyLater => 'Verificar después';

  @override
  String get authLegalConsentPrefix => 'Al registrarte aceptas nuestra ';

  @override
  String get authLegalConsentSuffix =>
      ' y autorizas el tratamiento de tus datos personales según la Ley 1581 de 2012.';

  @override
  String get externalRecommendedNotice =>
      'Estos servicios son recomendados por vecinos — no son residentes del conjunto.';

  @override
  String get externalNoServicesYet => 'Sin servicios aún';

  @override
  String get externalNoServicesSubtitle =>
      'Recomienda un profesional de confianza a tu comunidad';

  @override
  String get externalErrorLoading => 'Error al cargar servicios';

  @override
  String get externalRecommendCta => 'Recomendar';

  @override
  String externalRecommendedByName(String name) {
    return 'Rec. por $name';
  }

  @override
  String externalCallWithPhone(String phone) {
    return 'Llamar · $phone';
  }

  @override
  String get externalCompleteNameDesc => 'Completa nombre y descripción';

  @override
  String get externalNoUserOrCommunity => 'No hay usuario o comunidad';

  @override
  String get externalServiceRecommended => 'Servicio recomendado';

  @override
  String get externalErrorRecommending => 'Error al recomendar servicio';

  @override
  String get externalRecommendTitle => 'Recomendar Servicio';

  @override
  String get externalRecommendDesc =>
      'Recomienda un servicio externo a tu comunidad';

  @override
  String get externalServiceNameLabel => 'Nombre del servicio *';

  @override
  String get externalDescriptionLabel => 'Descripción *';

  @override
  String get externalDescriptionHint => 'Qué ofrece este servicio';

  @override
  String get externalWebsiteLabel => 'Sitio web';

  @override
  String get externalWebsiteHint => 'https://ejemplo.com';

  @override
  String get externalSendRecommendation => 'Enviar Recomendación';

  @override
  String get externalErrorRecommendingShort => 'Error al recomendar';

  @override
  String get externalProfessionalNameLabel =>
      'Nombre del profesional o empresa';

  @override
  String get externalCategoryLabel => 'Categoría';

  @override
  String get externalDescribeExperienceLabel =>
      'Describe tu experiencia con este servicio';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifMarkAll => 'Marcar todas';

  @override
  String get notifEmpty => 'Sin notificaciones';

  @override
  String get notifEmptySubtitle =>
      'Aquí aparecerán las novedades de tu comunidad';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingPage1Title => 'Tu comunidad, conectada';

  @override
  String get onboardingPage1Desc =>
      'Noticias, alertas y comunicados de tu conjunto en un solo lugar. Sin perderse nada en el chat.';

  @override
  String get onboardingPage2Title => 'Compra a tus vecinos';

  @override
  String get onboardingPage2Desc =>
      'Descubre emprendimientos y servicios de tu comunidad. Apoya a quien vive al lado.';

  @override
  String get onboardingPage3Title => 'Servicios de confianza';

  @override
  String get onboardingPage3Desc =>
      'Directorio de profesionales recomendados por tus vecinos. Electricistas, plomeros y más.';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get feedWriteSomething => 'Escribe algo para publicar';

  @override
  String get feedAddAtLeast2Options => 'Agrega al menos 2 opciones';

  @override
  String get feedPublished => 'Publicado';

  @override
  String get feedAlertHint => '¿Qué quieres alertar a tu comunidad?';

  @override
  String get feedShareHint => '¿Qué quieres compartir con tu comunidad?';

  @override
  String get feedPollOptionsTitle => 'Opciones de la encuesta';

  @override
  String feedPollOptionHint(int n) {
    return 'Opción $n';
  }

  @override
  String get feedAddOption => 'Agregar opción';

  @override
  String get feedPostTitle => 'Post';

  @override
  String get feedPostNotFound => 'Post no encontrado';

  @override
  String get feedPinned => 'Fijado';

  @override
  String feedLikesCount(int count) {
    return '$count Me gusta';
  }

  @override
  String feedCommentsCount(int count) {
    return '$count comentarios';
  }

  @override
  String get feedLikeAction => 'Me gusta';

  @override
  String get feedCommentAction => 'Comentar';

  @override
  String get feedCouldNotLike => 'No se pudo registrar tu like';

  @override
  String get feedPollTitle => 'Encuesta';

  @override
  String get feedAlertBadge => 'ALERTA';

  @override
  String get feedCouldNotPin => 'No se pudo fijar la publicación';

  @override
  String get feedUnpin => 'Desfijar';

  @override
  String get feedPinToTop => 'Fijar arriba';

  @override
  String get feedReport => 'Reportar';

  @override
  String get feedReportDialogTitle => 'Reportar publicación';

  @override
  String get feedReportReasonInappropriate => 'Contenido inapropiado';

  @override
  String get feedReportReasonSpam => 'Spam o publicidad';

  @override
  String get feedReportReasonFalseInfo => 'Información falsa';

  @override
  String get feedReportReasonHarassment => 'Acoso o intimidación';

  @override
  String get feedReportReasonOther => 'Otro';

  @override
  String get feedReportSent => 'Reporte enviado';

  @override
  String get feedCouldNotSendReport => 'No se pudo enviar el reporte';

  @override
  String get serviceFillAllFields => 'Completa todos los campos';

  @override
  String get serviceNoUserOrCommunity => 'No hay usuario o comunidad';

  @override
  String get serviceCreated => 'Servicio creado';

  @override
  String get serviceCreateError => 'Error al crear servicio';

  @override
  String get serviceOfferTitle => 'Ofrecer Servicio';

  @override
  String get serviceCategoryLabel => 'Categoría';

  @override
  String get serviceTitleLabel => 'Título del servicio';

  @override
  String get serviceDescriptionLabel => 'Descripción';

  @override
  String get servicePriceLabel => 'Precio (COP) - Opcional';

  @override
  String get servicePublishButton => 'Publicar Servicio';

  @override
  String get serviceDetailTitle => 'Detalle del Servicio';

  @override
  String get serviceNotFound => 'Servicio no encontrado';

  @override
  String serviceOrdersCount(int count) {
    return '$count órdenes';
  }

  @override
  String get servicePriceHeading => 'Precio';

  @override
  String get serviceProviderLabel => 'Prestador de servicio';

  @override
  String get serviceSearchHint => 'Buscar servicio...';

  @override
  String get serviceScreenTitle => 'Servicios Vecinales';

  @override
  String get serviceSortRecent => 'Más recientes';

  @override
  String get serviceSortRating => 'Mejor calificación';

  @override
  String get serviceSortPopular => 'Más populares';

  @override
  String get serviceEmptyTitle => 'Sin servicios aún';

  @override
  String get serviceEmptySubtitle =>
      'Ofrece tus productos o servicios a tu comunidad';

  @override
  String get serviceLoadError => 'Error al cargar servicios';

  @override
  String get serviceOfferFab => 'Ofrecer';

  @override
  String get storeMyOrdersTitle => 'Mis Pedidos';

  @override
  String get storeNoOrdersTitle => 'Sin pedidos';

  @override
  String get storeNoOrdersSubtitle =>
      'Tus pedidos a tiendas del barrio aparecerán aquí';

  @override
  String get storeLoadOrdersError => 'Error al cargar pedidos';

  @override
  String get storeOrderTrackingTitle => 'Estado del Pedido';

  @override
  String get storeOrderNotFound => 'Pedido no encontrado';

  @override
  String storeOrderNumber(String code) {
    return 'Pedido #$code';
  }

  @override
  String get storeOrderCancelledMessage => 'Este pedido fue cancelado';

  @override
  String get storeOrderSummaryLabel => 'Resumen';

  @override
  String get storeServiceFeeLabel => 'Servicio';

  @override
  String get storeTotalLabel => 'Total';

  @override
  String get storeRateOrderButton => 'Calificar pedido';

  @override
  String get storeSelectRatingError => 'Selecciona una calificación';

  @override
  String get storeRatingSubmitted => 'Calificación enviada';

  @override
  String get storeRatingSubmitError => 'Error al enviar calificación';

  @override
  String storeRateOrderQuestion(String storeName) {
    return '¿Cómo fue tu pedido en $storeName?';
  }

  @override
  String get storeCommentHint => 'Comentario opcional...';

  @override
  String get storeSubmitRatingButton => 'Enviar calificación';

  @override
  String get storeRatingVeryBad => 'Muy malo';

  @override
  String get storeRatingBad => 'Malo';

  @override
  String get storeRatingRegular => 'Regular';

  @override
  String get storeRatingGood => 'Bueno';

  @override
  String get storeRatingExcellent => 'Excelente';

  @override
  String get storeOrderCreated => 'Pedido creado';

  @override
  String get storeOrderCreateError => 'Error al crear el pedido';

  @override
  String get storeDefaultTitle => 'Tienda';

  @override
  String get storeNoItemsMessage => 'Esta tienda no tiene productos aún';

  @override
  String get storePaymentMethodLabel => 'Método de pago';

  @override
  String get storeCashOnDeliveryTitle => 'Contra entrega';

  @override
  String get storeCashOnDeliverySubtitle => 'Paga al recibir tu pedido';

  @override
  String get storeOnlinePaymentTitle => 'Pago en línea';

  @override
  String get storeOnlinePaymentSubtitle => 'PSE, tarjeta o Nequi via Wompi';

  @override
  String get storePayOnlineLabel => 'Pagar en línea';

  @override
  String get storeOrderCashLabel => 'Pedir (contra entrega)';

  @override
  String get storePanelTitle => 'Mi Tienda';

  @override
  String get storeCreatePrompt =>
      'Crea tu tienda para empezar a vender productos a tu comunidad';

  @override
  String get storeCreateMyStoreButton => 'Crear mi tienda';

  @override
  String get storeCreateDialogTitle => 'Crear tienda';

  @override
  String get storeNameLabel => 'Nombre de la tienda';

  @override
  String get storeDeliveryTimeLabel => 'Tiempo de entrega';

  @override
  String get storeMinOrderLabel => 'Pedido mínimo';

  @override
  String get storeNoCommunityAssigned => 'No hay comunidad asignada';

  @override
  String get storeCreated => 'Tienda creada';

  @override
  String get storePanelNoOrdersTitle => 'Sin pedidos';

  @override
  String get storePanelNoOrdersSubtitle =>
      'Los pedidos de tus clientes aparecerán aquí';

  @override
  String get storePendingLabel => 'Pendientes';

  @override
  String get storeActiveLabel => 'Activos';

  @override
  String get storeTodayLabel => 'Hoy';

  @override
  String storeNewOrdersCount(int count) {
    return 'Nuevos pedidos ($count)';
  }

  @override
  String storeInProgressCount(int count) {
    return 'En proceso ($count)';
  }

  @override
  String get storeCompletedLabel => 'Completados';

  @override
  String get storeNewItemFab => 'Nuevo';

  @override
  String get storeNoItemsTitle => 'Sin productos';

  @override
  String get storeNoItemsSubtitle => 'Agrega tu primer producto con el botón +';

  @override
  String get storeDeleteProductTitle => 'Eliminar producto';

  @override
  String storeDeleteProductConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get storeHideLabel => 'Ocultar';

  @override
  String get storeActivateLabel => 'Activar';

  @override
  String get storeNewProductTitle => 'Nuevo producto';

  @override
  String get storeEditProductTitle => 'Editar producto';

  @override
  String get storeItemNameLabel => 'Nombre';

  @override
  String get storeItemPriceLabel => 'Precio (COP)';

  @override
  String get storeProductCreated => 'Producto creado';

  @override
  String get storeProductUpdated => 'Producto actualizado';

  @override
  String get storeStatusLabel => 'Estado';

  @override
  String get storeActiveStatus => 'Activa';

  @override
  String get storeInactiveStatus => 'Inactiva';

  @override
  String get storeRatingLabel => 'Calificación';

  @override
  String get storeCompletedOrdersLabel => 'Pedidos completados';

  @override
  String get storeEditInfoButton => 'Editar información';

  @override
  String get storePauseStoreButton => 'Pausar tienda';

  @override
  String get storeReactivateStoreButton => 'Reactivar tienda';

  @override
  String get storeEditDialogTitle => 'Editar tienda';

  @override
  String get storeUpdated => 'Actualizado';

  @override
  String get storeRejectButton => 'Rechazar';

  @override
  String get storeMarkOnWayButton => 'Marcar en camino';

  @override
  String get storeMarkDeliveredButton => 'Marcar entregado';

  @override
  String get storeScreenTitle => 'Tiendas del Barrio';

  @override
  String get storeBannerTitle => 'Pide sin salir de casa';

  @override
  String get storeBannerSubtitle => 'Entrega directa en tu puerta';

  @override
  String get storeEmptyTitle => 'Sin tiendas aún';

  @override
  String get storeEmptySubtitle => 'Las tiendas de tu barrio aparecerán aquí';

  @override
  String get storeLoadError => 'Error al cargar tiendas';

  @override
  String get amenityScreenTitle => 'Zonas Sociales';

  @override
  String get amenityNewButton => 'Nueva';

  @override
  String get amenityEmptyTitle => 'Sin zonas configuradas';

  @override
  String get amenityEmptySubtitle =>
      'Las zonas sociales de tu conjunto aparecerán aquí';

  @override
  String amenityCapacityLabel(int count) {
    return '$count personas';
  }

  @override
  String amenityDepositLabel(String amount) {
    return 'Depósito reembolsable: $amount';
  }

  @override
  String amenityCapacityColon(int count) {
    return 'Capacidad: $count personas';
  }

  @override
  String amenityRateColon(String amount) {
    return 'Tarifa: $amount';
  }

  @override
  String amenityDepositColon(String amount) {
    return 'Depósito: $amount (reembolsable)';
  }

  @override
  String get amenityAvailable => 'Disponible';

  @override
  String get amenityReserved => 'Reservado';

  @override
  String get amenitySelected => 'Seleccionado';

  @override
  String amenityScheduleColon(String hours) {
    return 'Horario: $hours';
  }

  @override
  String get amenityRentalPlusDeposit => 'Alquiler + depósito';

  @override
  String get amenityPayAndBook => 'Pagar y Reservar';

  @override
  String get amenityBookingCreated => 'Reserva creada';

  @override
  String get amenityCreateTitle => 'Nueva zona social';

  @override
  String get amenityCreated => 'Zona creada';

  @override
  String get amenityNameLabel => 'Nombre';

  @override
  String get amenityNameHint => 'Ej: Salón social, BBQ, Piscina';

  @override
  String get amenityCapacityFeesSection => 'Capacidad y tarifas';

  @override
  String get amenityCapacityFieldLabel => 'Capacidad (personas)';

  @override
  String get amenityHourlyRateLabel => 'Tarifa por hora (COP)';

  @override
  String get amenityDepositOptionalLabel => 'Depósito reembolsable (opcional)';

  @override
  String get amenityDepositHelper => 'Se retiene y devuelve si no hay daños';

  @override
  String get amenityScheduleRulesSection => 'Horario y reglas';

  @override
  String get amenityHoursLabel => 'Horario';

  @override
  String get amenityRulesLabel => 'Reglas (opcional)';

  @override
  String get amenityRulesHint =>
      'Ej: Aforo máximo 15, no música después de 22h';

  @override
  String get amenityCreateSubmit => 'Crear zona';

  @override
  String get assemblyScreenTitle => 'Asambleas';

  @override
  String get assemblyConvene => 'Convocar';

  @override
  String get assemblyEmptyTitle => 'Sin asambleas';

  @override
  String get assemblyEmptySubtitle =>
      'Las convocatorias de asamblea aparecerán aquí';

  @override
  String get assemblyLive => 'EN VIVO';

  @override
  String assemblyAgendaCount(int count) {
    return 'Orden del día: $count puntos';
  }

  @override
  String assemblyAttendeesRegistered(int count) {
    return '$count asistentes registrados';
  }

  @override
  String get assemblyVoteRegistered => 'Voto registrado';

  @override
  String assemblyTotalVotes(int count) {
    return '$count votos';
  }

  @override
  String get assemblyAgendaRequired =>
      'Agrega al menos un punto al orden del día';

  @override
  String get assemblyConvened => 'Asamblea convocada';

  @override
  String get assemblyConveneTitle => 'Convocar asamblea';

  @override
  String get assemblyTitleLabel => 'Título';

  @override
  String get assemblyTitleHint => 'Ej: Asamblea ordinaria 2026';

  @override
  String get assemblyLocationLabel => 'Lugar (opcional)';

  @override
  String get assemblyLocationHint => 'Ej: Salón Social';

  @override
  String get assemblyVirtualLinkLabel => 'Link virtual (opcional)';

  @override
  String get assemblyAgendaTitle => 'Orden del día';

  @override
  String get assemblyAddAgendaItem => 'Agregar';

  @override
  String get assemblyAgendaItemHint => 'Punto del orden del día';

  @override
  String get assemblyConveneHelper =>
      'Al convocar, los residentes serán notificados y podrán confirmar asistencia. Las votaciones se pueden iniciar el día de la asamblea.';

  @override
  String get circularScreenTitle => 'Circulares';

  @override
  String get circularEmptyTitle => 'Sin circulares';

  @override
  String get circularEmptySubtitle =>
      'Los comunicados oficiales aparecerán aquí';

  @override
  String circularAttachmentsCount(int count) {
    return '$count adjunto(s)';
  }

  @override
  String circularReadPercentage(int pct) {
    return '$pct% leído';
  }

  @override
  String get circularSignAck => 'Firmar acuse de recibo';

  @override
  String get circularTitleRequired => 'Ingresa un título';

  @override
  String get circularBodyRequired => 'Ingresa el contenido';

  @override
  String get circularPublished => 'Circular publicada';

  @override
  String get circularCreateTitle => 'Nueva Circular';

  @override
  String get circularPriority => 'Prioridad';

  @override
  String get circularTitleLabel => 'Título de la circular';

  @override
  String get circularTitleHint => 'Ej: Corte de agua programado';

  @override
  String get circularContentLabel => 'Contenido';

  @override
  String get circularContentHint => 'Escribe el comunicado completo...';

  @override
  String get circularRequiresAck => 'Requiere firma de acuse';

  @override
  String get circularRequiresAckHelper =>
      'Los residentes deberán firmar que lo leyeron';

  @override
  String get financeStatementTitle => 'Mi Estado de Cuenta';

  @override
  String get financeStatementUnavailable =>
      'No hay estado de cuenta disponible';

  @override
  String get financeCurrentBalance => 'Saldo actual';

  @override
  String get financeUpToDate => 'Estás al día';

  @override
  String get financePendingBalance => 'Tienes saldo pendiente';

  @override
  String get financePayFee => 'Pagar cuota';

  @override
  String get financeHistory => 'Historial';

  @override
  String get financeNoMovements => 'Sin movimientos registrados';

  @override
  String get financePaid => 'Pagado';

  @override
  String get financePending => 'Pendiente';

  @override
  String get financeEntryRegistered => 'Movimiento registrado';

  @override
  String get financeNewEntryTitle => 'Nuevo movimiento';

  @override
  String get financeIncome => 'Ingreso';

  @override
  String get financeExpense => 'Egreso';

  @override
  String get financeCategoryLabel => 'Categoría';

  @override
  String get financeCategoryHint => 'Ej: Cuota administración, Mantenimiento';

  @override
  String get financeAmountLabel => 'Monto (COP)';

  @override
  String get financeDateLabel => 'Fecha';

  @override
  String get financeRegister => 'Registrar';

  @override
  String get financeDashboardTitle => 'Dashboard Financiero';

  @override
  String get financeExportPdf => 'Exportar PDF';

  @override
  String get financeGeneratingReport => 'Generando reporte PDF...';

  @override
  String get financeBalance => 'Saldo';

  @override
  String get financeBudgetVsExecution => 'Presupuesto vs. Ejecución';

  @override
  String get financeExecution => 'Ejecución';

  @override
  String get financeBudget => 'Presupuesto';

  @override
  String get financeExecuted => 'Ejecutado';

  @override
  String get financeConfigureBudgets =>
      'Configura presupuestos para comparar con la ejecución';

  @override
  String get financePortfolio => 'Cartera';

  @override
  String get financeNoStatements => 'Sin estados de cuenta cargados';

  @override
  String get financeCollectionRate => 'Tasa de recaudo';

  @override
  String get financeOverdueBalance => 'Cartera morosa';

  @override
  String get financeMovements => 'Movimientos';

  @override
  String get financeRegisterExpensesForChart =>
      'Registra egresos por categoría para ver el gráfico';

  @override
  String get financePayPendingFee => 'Pagar cuota pendiente';

  @override
  String get fineManagementTitle => 'Gestión de Multas';

  @override
  String get fineMyTitle => 'Mis Multas';

  @override
  String get fineEmptyAdminTitle => 'Sin multas registradas';

  @override
  String get fineEmptyResidentTitle => 'Sin multas';

  @override
  String get fineEmptyAdminSubtitle =>
      'Las multas que registres aparecerán aquí';

  @override
  String get fineEmptyResidentSubtitle => 'No tienes multas pendientes';

  @override
  String fineUnitLabel(String unit) {
    return 'Apto $unit';
  }

  @override
  String get fineResidentDefense => 'Descargo del residente';

  @override
  String fineDaysLeftForDefense(int days) {
    return '⏱ $days días para presentar descargo';
  }

  @override
  String get fineSubmitDefense => 'Presentar descargo';

  @override
  String get fineConfirm => 'Confirmar multa';

  @override
  String get fineVoid => 'Anular';

  @override
  String get fineDefenseHint => 'Escribe tu versión de los hechos...';

  @override
  String get fineDefenseSent => 'Descargo enviado';

  @override
  String get fineSend => 'Enviar';

  @override
  String get fineUnitRequired => 'Ingresa la unidad (ej: T2-801)';

  @override
  String get fineReasonRequired => 'Describe el motivo';

  @override
  String get fineAmountRequired => 'Ingresa un monto válido';

  @override
  String get fineRegistered => 'Multa registrada';

  @override
  String get fineCreateTitle => 'Registrar Multa';

  @override
  String get fineUnitFieldLabel => 'Unidad / Apartamento';

  @override
  String get fineReasonLabel => 'Motivo de la multa';

  @override
  String get fineReasonHint => 'Describe la infracción...';

  @override
  String get fineManualArticleLabel => 'Artículo del manual (opcional)';

  @override
  String get fineDefenseDeadline => 'Plazo para descargos';

  @override
  String fineDaysCount(int days) {
    return '$days días';
  }

  @override
  String get fineNotifyInfo =>
      'El residente será notificado y tendrá el plazo indicado para presentar descargos.';

  @override
  String get fineDetailTitle => 'Detalle de Multa';

  @override
  String get fineNotFound => 'Multa no encontrada';

  @override
  String fineNumber(String id) {
    return 'Multa #$id';
  }

  @override
  String get fineReasonTitle => 'Motivo';

  @override
  String get fineManualArticleTitle => 'Artículo del manual';

  @override
  String get fineEvidence => 'Evidencia';

  @override
  String get fineDefense => 'Descargo';

  @override
  String fineDaysRemaining(int days) {
    return '$days días restantes';
  }

  @override
  String get fineDefenseFieldHint => 'Escribe tu descargo aquí...';

  @override
  String get fineSendDefense => 'Enviar descargo';

  @override
  String get finePayFine => 'Pagar multa';

  @override
  String get fineWriteDefense => 'Escribe tu descargo';

  @override
  String fineConfirmMessage(int amount) {
    return '¿Confirmar la multa de \$$amount?';
  }

  @override
  String get fineVoidTitle => 'Anular multa';

  @override
  String get fineVoidMessage => '¿Estás seguro de anular esta multa?';

  @override
  String get manualScreenTitle => 'Manual de Convivencia';

  @override
  String get manualSearchHint => 'Buscar en el manual...';

  @override
  String manualLinkedFines(int count) {
    return '$count multas vinculadas';
  }

  @override
  String get pqrsScreenTitle => 'PQRS';

  @override
  String get pqrsEmptyAdminTitle => 'Sin PQRS';

  @override
  String get pqrsEmptyResidentTitle => 'Sin solicitudes';

  @override
  String get pqrsEmptyAdminSubtitle =>
      'Las solicitudes de residentes aparecerán aquí';

  @override
  String get pqrsEmptyResidentSubtitle =>
      'Envía peticiones, quejas o sugerencias';

  @override
  String get pqrsOpen => 'Abiertos';

  @override
  String get pqrsInProgress => 'En gestión';

  @override
  String get pqrsResolved => 'Resueltos';

  @override
  String pqrsResidentUnit(String name, String unit) {
    return '$name · $unit';
  }

  @override
  String get pqrsAdminResponse => 'Respuesta de la administración';

  @override
  String get pqrsSlaOverdue => 'SLA vencido';

  @override
  String get pqrsRespond => 'Responder';

  @override
  String get pqrsRespondTitle => 'Responder PQRS';

  @override
  String get pqrsResponseHint => 'Escribe la respuesta...';

  @override
  String get pqrsResponseSent => 'Respuesta enviada';

  @override
  String get pqrsDescribeRequest => 'Describe tu solicitud';

  @override
  String get pqrsSent => 'PQRS enviado';

  @override
  String get pqrsCreateTitle => 'Nuevo PQRS';

  @override
  String get pqrsRequestType => 'Tipo de solicitud';

  @override
  String get pqrsCategory => 'Categoría';

  @override
  String get pqrsDescriptionHint =>
      'Describe tu petición, queja, reclamo o sugerencia...';

  @override
  String get pqrsNotifyInfo =>
      'Tu solicitud será enviada al administrador del conjunto. Recibirás notificación cuando sea atendida.';

  @override
  String get premiumDashboardTitle => 'Vecindario Admin';

  @override
  String get premiumNotActive =>
      'Tu comunidad aún no tiene Vecindario Admin activo.';

  @override
  String get premiumViewPlans => 'Ver planes';

  @override
  String get premiumQuickActions => 'ACCIONES RÁPIDAS';

  @override
  String get premiumSendOfficialNotice => 'Enviar comunicado oficial';

  @override
  String get premiumCreateSanctionWithEvidence => 'Crear sanción con evidencia';

  @override
  String get premiumCreateConvocationWithAgenda =>
      'Crear convocatoria con agenda';

  @override
  String get premiumModules => 'MÓDULOS';

  @override
  String get premiumCircularsAdminSubtitle =>
      'Enviar comunicados con tracking de lectura';

  @override
  String get premiumCircularsResidentSubtitle =>
      'Comunicados oficiales de tu conjunto';

  @override
  String get premiumFinesAdminSubtitle => 'Registrar y gestionar sanciones';

  @override
  String get premiumFinesResidentSubtitle => 'Tus multas y descargos';

  @override
  String get premiumPqrsAdminSubtitle => 'Solicitudes de residentes con SLA';

  @override
  String get premiumPqrsResidentSubtitle =>
      'Envía peticiones, quejas o sugerencias';

  @override
  String get premiumManualSubtitle => 'Reglamento del conjunto por capítulos';

  @override
  String get premiumAmenitiesAdminSubtitle => 'Gestionar reservas y depósitos';

  @override
  String get premiumAmenitiesResidentSubtitle =>
      'Reservar salón, BBQ, cancha y más';

  @override
  String get premiumFinancesAdminSubtitle => 'Ingresos, egresos y presupuesto';

  @override
  String get premiumFinancesResidentSubtitle => 'Tu saldo, pagos y cuotas';

  @override
  String get premiumAssembliesAdminSubtitle =>
      'Convocar y gestionar votaciones';

  @override
  String get premiumAssembliesResidentSubtitle =>
      'Participar y votar en tiempo real';

  @override
  String get premiumResidents => 'Residentes';

  @override
  String get premiumOpenPqrs => 'PQRS abiertos';

  @override
  String get premiumMonthlyRevenue => 'Recaudo mes';

  @override
  String get subscriptionPlansTitle => 'Planes Vecindario Admin';

  @override
  String get subscriptionTagline => 'Digitaliza la gestión de tu conjunto';

  @override
  String get subscriptionFirstMonthFree => 'Primer mes gratis';

  @override
  String get subscriptionUnitsStarter => '1 - 50 unidades';

  @override
  String get subscriptionUnitsProfessional => '51 - 150 unidades';

  @override
  String get subscriptionUnitsEnterprise => '151+ unidades';

  @override
  String get subscriptionFeatureCircularsTracking => 'Circulares con tracking';

  @override
  String get subscriptionFeaturePqrsSla => 'PQRS con SLA';

  @override
  String get subscriptionFeatureManual => 'Manual de convivencia';

  @override
  String get subscriptionFeatureFineManagement => 'Gestión de multas';

  @override
  String get subscriptionFeatureAmenities => 'Zonas sociales';

  @override
  String get subscriptionFeatureFinances => 'Finanzas';

  @override
  String get subscriptionFeatureAllStarter => 'Todo de Starter';

  @override
  String get subscriptionFeatureAmenitiesBooking => 'Reserva zonas sociales';

  @override
  String get subscriptionFeatureOnlinePayments => 'Pagos en línea';

  @override
  String get subscriptionFeatureFinanceDashboard => 'Dashboard financiero';

  @override
  String get subscriptionFeatureIndividualStatement =>
      'Estado de cuenta individual';

  @override
  String get subscriptionFeatureAssemblies => 'Asambleas/votaciones';

  @override
  String get subscriptionFeatureAllProfessional => 'Todo de Profesional';

  @override
  String get subscriptionFeatureAssembliesVoting => 'Asambleas + votaciones';

  @override
  String get subscriptionFeaturePdfReports => 'Reportes PDF automáticos';

  @override
  String get subscriptionFeatureAccountingApi => 'API contable (Siigo)';

  @override
  String get subscriptionFeaturePrioritySupport => 'Soporte prioritario';

  @override
  String get subscriptionAnnualDiscount =>
      '20% descuento pago anual (2 meses gratis)';

  @override
  String subscriptionTrialActivated(String plan) {
    return 'Trial de 30 días activado: $plan';
  }

  @override
  String get subscriptionOnlyAdminsCanActivate =>
      'Solo administradores pueden activar el trial';

  @override
  String subscriptionActivationError(String message) {
    return 'Error al activar trial: $message';
  }

  @override
  String get subscriptionPopular => 'POPULAR';

  @override
  String get subscriptionPerMonth => '/mes';

  @override
  String get subscriptionTry30DaysFree => 'Probar gratis 30 días';

  @override
  String get adminSettingsTitle => 'Configuración de comunidad';

  @override
  String get adminCommunityNotFound => 'Comunidad no encontrada';

  @override
  String get adminGeneralData => 'Datos generales';

  @override
  String get adminNameLabel => 'Nombre';

  @override
  String get adminNameRequired => 'El nombre es obligatorio';

  @override
  String get adminAddressLabel => 'Dirección';

  @override
  String get adminCityLabel => 'Ciudad';

  @override
  String get adminEstratoLabel => 'Estrato';

  @override
  String adminEstratoOption(int n) {
    return 'Estrato $n';
  }

  @override
  String get adminSaveChanges => 'Guardar cambios';

  @override
  String adminGenericError(String message) {
    return 'Error: $message';
  }

  @override
  String get adminCodeCopied => 'Código copiado';

  @override
  String get adminRotateCodeTitle => 'Rotar código';

  @override
  String get adminRotateCodeMessage =>
      'El código actual dejará de funcionar y se generará uno nuevo. Los residentes que aún no se hayan unido deberán pedirlo de nuevo.';

  @override
  String get adminRotateAction => 'Rotar';

  @override
  String adminNewCodeMessage(String code) {
    return 'Nuevo código: $code';
  }

  @override
  String get adminCodeRotated => 'Código rotado';

  @override
  String adminRotateError(String statusCode) {
    return 'No se pudo rotar: $statusCode';
  }

  @override
  String adminSaveError(String message) {
    return 'Error al guardar: $message';
  }

  @override
  String get adminChangesSaved => 'Cambios guardados';

  @override
  String get adminResidentsLabel => 'Residentes';

  @override
  String get adminServiceLabel => 'Servicio';

  @override
  String get adminUnitsLabel => 'Unidades';

  @override
  String get adminPendingApprovalsTitle => 'Solicitudes pendientes';

  @override
  String get adminAllCaughtUp => 'Todo al día';

  @override
  String get adminNoPendingRequests => 'No hay solicitudes pendientes';

  @override
  String adminUserApproved(String name) {
    return '$name aprobado';
  }

  @override
  String adminApproveError(String error) {
    return 'Error al aprobar: $error';
  }

  @override
  String get adminRequestRejected => 'Solicitud rechazada';

  @override
  String adminRejectError(String error) {
    return 'Error al rechazar: $error';
  }

  @override
  String get superAdminCommunityDetailTitle => 'Detalle de comunidad';

  @override
  String get superAdminInfoTitle => 'Información';

  @override
  String get superAdminUnitTypeLabel => 'Tipo unidad';

  @override
  String get superAdminAdminUidLabel => 'Admin UID';

  @override
  String get superAdminUnassigned => 'Sin asignar';

  @override
  String get superAdminCommunityIdLabel => 'ID comunidad';

  @override
  String get superAdminCreatedLabel => 'Creada';

  @override
  String get superAdminSubscriptionTitle => 'Suscripción';

  @override
  String get superAdminNoActivePlanMessage =>
      'Sin Vecindario Admin activo. El admin puede activar el trial o tú puedes activar un plan aquí.';

  @override
  String get superAdminPlanLabel => 'Plan';

  @override
  String get superAdminStatusLabel => 'Estado';

  @override
  String get superAdminActionsTitle => 'Acciones';

  @override
  String get superAdminAssignAdminAction => 'Asignar administrador';

  @override
  String get superAdminAssignAdminSubtitle =>
      'Ingresa el UID del usuario que gestionará la comunidad';

  @override
  String get superAdminActivatePlanAction => 'Activar plan';

  @override
  String get superAdminActivatePlanSubtitle =>
      'Starter, Profesional o Enterprise (trial o activo)';

  @override
  String get superAdminDeleteCommunityAction => 'Eliminar comunidad';

  @override
  String get superAdminDeleteCommunitySubtitle =>
      'Acción irreversible. No borra usuarios.';

  @override
  String superAdminAssignAdminDialogTitle(String name) {
    return 'Asignar Admin — $name';
  }

  @override
  String get superAdminAssignAdminDialogMessage =>
      'Ingresa el UID del usuario que será administrador. Puedes encontrarlo en Firebase Auth.';

  @override
  String get superAdminUidLabel => 'UID del usuario';

  @override
  String get superAdminAssignAction => 'Asignar';

  @override
  String get superAdminAdminAssigned => 'Admin asignado';

  @override
  String superAdminActivatePlanDialogTitle(String name) {
    return 'Activar Plan — $name';
  }

  @override
  String get superAdminActivateTrialAction => 'Activar Trial';

  @override
  String superAdminPlanActivatedMessage(String plan) {
    return 'Plan $plan activado (trial 30 días gratis)';
  }

  @override
  String superAdminDeleteCommunityMessage(String name) {
    return '¿Seguro? Se eliminará el documento de \"$name\" y su suscripción. Los usuarios NO se eliminan (quedan sin comunidad).';
  }

  @override
  String get superAdminCommunityDeleted => 'Comunidad eliminada';

  @override
  String get superAdminAccessDeniedTitle => 'Acceso denegado';

  @override
  String get superAdminNoPermission => 'No tienes permisos de Super Admin';

  @override
  String get superAdminPanelTitle => 'Panel Global';

  @override
  String get superAdminCreateCommunityTooltip => 'Crear comunidad';

  @override
  String get superAdminLogoutConfirmMessage => '¿Seguro que quieres salir?';

  @override
  String get superAdminExitAction => 'Salir';

  @override
  String get superAdminNoCommunitiesMessage => 'No hay comunidades registradas';

  @override
  String get superAdminCreateFirstCommunity => 'Crear primera comunidad';

  @override
  String superAdminCommunitiesCountTitle(int count) {
    return 'COMUNIDADES ($count)';
  }

  @override
  String get superAdminGlobalStatsCommunities => 'Conjuntos';

  @override
  String get superAdminSubscriptionsLabel => 'Suscripciones';

  @override
  String superAdminMembersCount(int count) {
    return '$count residentes';
  }

  @override
  String get superAdminAssignAdminButton => 'Asignar Admin';

  @override
  String get superAdminPlanButton => 'Plan';

  @override
  String get superAdminPanelAssignAdminMessage =>
      'Ingresa el UID del usuario que será administrador del conjunto. Puedes encontrarlo en Firebase Auth.';

  @override
  String get superAdminNewCommunityTitle => 'Nueva comunidad';

  @override
  String get superAdminCreateCommunityHint =>
      'Después de crear la comunidad, se generará un código de invitación único para compartir con el administrador.';

  @override
  String get superAdminBasicInfoTitle => 'Información básica';

  @override
  String get superAdminCommunityNameLabel => 'Nombre del conjunto';

  @override
  String get superAdminCommunityNameHint => 'Ej: Pinares de Granada';

  @override
  String get superAdminAddressHint => 'Ej: Carrera 15 # 80-45';

  @override
  String get superAdminAddressRequired => 'La dirección es obligatoria';

  @override
  String get superAdminCityHint => 'Ej: Bogotá';

  @override
  String get superAdminCityRequired => 'La ciudad es obligatoria';

  @override
  String get superAdminCharacteristicsTitle => 'Características';

  @override
  String get superAdminEstratoSocioLabel => 'Estrato socioeconómico';

  @override
  String get superAdminUnitTypeFieldLabel => 'Tipo de unidad';

  @override
  String get superAdminCreatingAction => 'Creando...';

  @override
  String get superAdminCreateCommunityAction => 'Crear comunidad';

  @override
  String superAdminCommunityCreatedMessage(String name, String code) {
    return 'Comunidad \"$name\" creada. Código: $code';
  }

  @override
  String superAdminCreateError(String error) {
    return 'Error al crear: $error';
  }

  @override
  String get profileAccountSection => 'Cuenta';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profilePlatformSection => 'Plataforma';

  @override
  String get profileSuperAdminPanelTitle => 'Super Admin Panel';

  @override
  String get profileManageCommunitiesSubtitle =>
      'Gestionar comunidades y clientes';

  @override
  String get profileAdminSection => 'Administración';

  @override
  String get profileCommunityAdminTitle => 'Administración del conjunto';

  @override
  String get profileCommunityAdminSubtitle =>
      'Aprobaciones, circulares, multas, finanzas, PQRS y más';

  @override
  String get profileMyCommunitySection => 'Mi conjunto';

  @override
  String get profileCircularsTitle => 'Circulares';

  @override
  String get profileReserveZoneTitle => 'Reservar zona';

  @override
  String get profilePqrsTitle => 'PQRS';

  @override
  String get profileMyFinesTitle => 'Mis multas';

  @override
  String get profileAccountStatementTitle => 'Estado de cuenta';

  @override
  String get profileAssembliesTitle => 'Asambleas';

  @override
  String get profileManualTitle => 'Manual de convivencia';

  @override
  String get profileMyStoreSection => 'Mi Tienda';

  @override
  String get profileStorePanelTitle => 'Panel de tienda';

  @override
  String get profileManageOrdersSubtitle => 'Gestionar pedidos y catálogo';

  @override
  String get profileConfigSection => 'Configuración';

  @override
  String get profileNotificationsTitle => 'Notificaciones';

  @override
  String get profilePrivacySubtitle =>
      'Datos, derechos y eliminación de cuenta';

  @override
  String get profileAppearanceTitle => 'Apariencia';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Oscuro';

  @override
  String get profileThemeSystem => 'Automático (sistema)';

  @override
  String get profileLegalSection => 'Legal';

  @override
  String get profileLogoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get profilePostsLabel => 'Posts';

  @override
  String get profileOrdersLabel => 'Pedidos';

  @override
  String get profileMemberSinceLabel => 'Miembro desde';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profileStorageUnauthorized =>
      'No tienes permisos para subir fotos';

  @override
  String get profileStorageQuotaExceeded =>
      'La foto es demasiado grande (máx 5 MB)';

  @override
  String get profileStorageRetryLimit => 'Red inestable, intenta de nuevo';

  @override
  String get profileUploadCanceled => 'Subida cancelada';

  @override
  String get profilePermissionDenied => 'No tienes permisos. ¿Sesión expirada?';

  @override
  String get profileNoConnection =>
      'Sin conexión. Verifica tu internet e intenta de nuevo';

  @override
  String profileSaveErrorDetail(String detail) {
    return 'Error al guardar: $detail';
  }

  @override
  String profileUnexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String get profileEmailHelperText => 'No se puede modificar';

  @override
  String get profileLaw1581Title => 'Ley 1581 de 2012';

  @override
  String get profileLaw1581Description =>
      'Tienes derecho a conocer, actualizar, rectificar y suprimir tus datos personales.';

  @override
  String get profileMyDataSection => 'Mis Datos';

  @override
  String get profileDownloadDataSubtitle =>
      'Recibe un archivo con toda tu información';

  @override
  String get profileDataExportRequested =>
      'Solicitud enviada. Recibirás un email en máximo 48 horas.';

  @override
  String get profileEditPersonalInfoTitle => 'Editar información personal';

  @override
  String get profileEditPersonalInfoSubtitle =>
      'Nombre, teléfono, foto de perfil';

  @override
  String get profileConsentsSection => 'Consentimientos';

  @override
  String get profilePushNotificationsTitle => 'Notificaciones push';

  @override
  String get profileEmailNewsTitle => 'Email de novedades';

  @override
  String get profileAnalyticsTitle => 'Datos de uso (analytics)';

  @override
  String get profilePrivacyPolicySubtitle => 'Tratamiento de datos personales';

  @override
  String get profileTermsSubtitle => 'Condiciones del servicio';

  @override
  String get profileDangerZoneTitle => 'Zona de peligro';

  @override
  String get profileIrreversibleAction => 'Esta acción es irreversible';

  @override
  String get profileCannotRecoverAfter15Days =>
      'Después de 15 días no podrás recuperar tu cuenta.';

  @override
  String get profileWillBeDeletedLabel => 'Se eliminará:';

  @override
  String get profileProfileAndPhotoItem => 'Tu perfil y foto';

  @override
  String get profileVerificationDocsItem => 'Documentos de verificación';

  @override
  String get profileTokensSessionsItem => 'Tokens y sesiones';

  @override
  String get profileWillBeAnonymizedLabel => 'Se anonimizará:';

  @override
  String get profilePostsAnonymizedItem => 'Posts → \"Usuario eliminado\"';

  @override
  String get profileReviewsAnonymizedItem => 'Reseñas → \"Usuario eliminado\"';

  @override
  String get profileOrdersAnonymizedItem => 'Pedidos → uid → null';

  @override
  String get profileDeleteAccountButtonLabel =>
      'Eliminar mi cuenta (15 días de gracia)';

  @override
  String get profileDeleteAccountDialogTitle => 'Eliminar Cuenta';

  @override
  String get profileDeleteConfirmMessage =>
      '¿Estás seguro? Después de 15 días esta acción no se puede deshacer.';

  @override
  String get profileConfirmPasswordLabel => 'Confirma tu contraseña';

  @override
  String get profileEnterPasswordError => 'Ingresa tu contraseña';

  @override
  String get profileAccountDeletionScheduled =>
      'Tu cuenta será eliminada en 15 días. Puedes reactivarla iniciando sesión.';

  @override
  String get profileWrongPassword => 'Contraseña incorrecta';

  @override
  String get profileAuthError => 'Error de autenticación';

  @override
  String get profileUnexpectedErrorShort => 'Error inesperado';
}
