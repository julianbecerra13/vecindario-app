import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Vecindario'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In es, this message translates to:
  /// **'Tu comunidad, conectada'**
  String get appSlogan;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @joinCommunity.
  ///
  /// In es, this message translates to:
  /// **'Unirse a comunidad'**
  String get joinCommunity;

  /// No description provided for @inviteCode.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación'**
  String get inviteCode;

  /// No description provided for @tower.
  ///
  /// In es, this message translates to:
  /// **'Torre / Bloque'**
  String get tower;

  /// No description provided for @apartment.
  ///
  /// In es, this message translates to:
  /// **'Apartamento'**
  String get apartment;

  /// No description provided for @requestJoin.
  ///
  /// In es, this message translates to:
  /// **'Solicitar ingreso'**
  String get requestJoin;

  /// No description provided for @pendingApproval.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud está en revisión'**
  String get pendingApproval;

  /// No description provided for @news.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get news;

  /// No description provided for @neighbors.
  ///
  /// In es, this message translates to:
  /// **'Vecinos'**
  String get neighbors;

  /// No description provided for @services.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get services;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @publish.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publish;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @noResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get noResults;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @allCategories.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get allCategories;

  /// No description provided for @contactWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'Contactar por WhatsApp'**
  String get contactWhatsApp;

  /// No description provided for @privacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Privacidad'**
  String get privacyTitle;

  /// No description provided for @downloadData.
  ///
  /// In es, this message translates to:
  /// **'Descargar mis datos'**
  String get downloadData;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get deleteAccount;

  /// No description provided for @termsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @authOrContinueWith.
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get authOrContinueWith;

  /// No description provided for @authContinueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get authContinueWithApple;

  /// No description provided for @authNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get authNoAccount;

  /// No description provided for @authSignUpAction.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get authSignUpAction;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @sortTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sortTooltip;

  /// No description provided for @errorWithDetail.
  ///
  /// In es, this message translates to:
  /// **'Error: {detail}'**
  String errorWithDetail(String detail);

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String errorGeneric(Object message);

  /// No description provided for @errorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado: {message}'**
  String errorUnexpected(Object message);

  /// No description provided for @savingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get savingEllipsis;

  /// No description provided for @errorCommunityNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Comunidad no disponible'**
  String get errorCommunityNotAvailable;

  /// No description provided for @errorUserOrCommunityUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Usuario o comunidad no disponibles'**
  String get errorUserOrCommunityUnavailable;

  /// No description provided for @formBasicInfo.
  ///
  /// In es, this message translates to:
  /// **'Información básica'**
  String get formBasicInfo;

  /// No description provided for @formDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get formDescriptionLabel;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordDesc.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.'**
  String get authForgotPasswordDesc;

  /// No description provided for @authForgotPasswordSent.
  ///
  /// In es, this message translates to:
  /// **'Se envió un enlace de recuperación a tu correo'**
  String get authForgotPasswordSent;

  /// No description provided for @authSendLink.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get authSendLink;

  /// No description provided for @authCheckEmail.
  ///
  /// In es, this message translates to:
  /// **'¡Revisa tu correo!'**
  String get authCheckEmail;

  /// No description provided for @authRecoveryLinkSentTo.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un enlace de recuperación a {email}'**
  String authRecoveryLinkSentTo(String email);

  /// No description provided for @authBackToLogin.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio de sesión'**
  String get authBackToLogin;

  /// No description provided for @authJoinCommunityTitle.
  ///
  /// In es, this message translates to:
  /// **'Únete a tu comunidad'**
  String get authJoinCommunityTitle;

  /// No description provided for @authJoinCommunityDesc.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de invitación que te dieron en la administración de tu conjunto.'**
  String get authJoinCommunityDesc;

  /// No description provided for @authEnterFullCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código completo'**
  String get authEnterFullCode;

  /// No description provided for @authFillTowerAndApartment.
  ///
  /// In es, this message translates to:
  /// **'Completa torre y apartamento'**
  String get authFillTowerAndApartment;

  /// No description provided for @authInvalidInviteCode.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación inválido'**
  String get authInvalidInviteCode;

  /// No description provided for @authJoinCommunityError.
  ///
  /// In es, this message translates to:
  /// **'Error al unirse a la comunidad'**
  String get authJoinCommunityError;

  /// No description provided for @authVerifyPhoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificar teléfono'**
  String get authVerifyPhoneTitle;

  /// No description provided for @authVerificationCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get authVerificationCodeTitle;

  /// No description provided for @authSmsCodeSentTo.
  ///
  /// In es, this message translates to:
  /// **'Enviamos un código SMS al\n+57 {phone}'**
  String authSmsCodeSentTo(String phone);

  /// No description provided for @authVerify.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get authVerify;

  /// No description provided for @authResendCode.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get authResendCode;

  /// No description provided for @authVerifyLater.
  ///
  /// In es, this message translates to:
  /// **'Verificar después'**
  String get authVerifyLater;

  /// No description provided for @authLegalConsentPrefix.
  ///
  /// In es, this message translates to:
  /// **'Al registrarte aceptas nuestra '**
  String get authLegalConsentPrefix;

  /// No description provided for @authLegalConsentSuffix.
  ///
  /// In es, this message translates to:
  /// **' y autorizas el tratamiento de tus datos personales según la Ley 1581 de 2012.'**
  String get authLegalConsentSuffix;

  /// No description provided for @externalRecommendedNotice.
  ///
  /// In es, this message translates to:
  /// **'Estos servicios son recomendados por vecinos — no son residentes del conjunto.'**
  String get externalRecommendedNotice;

  /// No description provided for @externalNoServicesYet.
  ///
  /// In es, this message translates to:
  /// **'Sin servicios aún'**
  String get externalNoServicesYet;

  /// No description provided for @externalNoServicesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recomienda un profesional de confianza a tu comunidad'**
  String get externalNoServicesSubtitle;

  /// No description provided for @externalErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar servicios'**
  String get externalErrorLoading;

  /// No description provided for @externalRecommendCta.
  ///
  /// In es, this message translates to:
  /// **'Recomendar'**
  String get externalRecommendCta;

  /// No description provided for @externalRecommendedByName.
  ///
  /// In es, this message translates to:
  /// **'Rec. por {name}'**
  String externalRecommendedByName(String name);

  /// No description provided for @externalCallWithPhone.
  ///
  /// In es, this message translates to:
  /// **'Llamar · {phone}'**
  String externalCallWithPhone(String phone);

  /// No description provided for @externalCompleteNameDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa nombre y descripción'**
  String get externalCompleteNameDesc;

  /// No description provided for @externalNoUserOrCommunity.
  ///
  /// In es, this message translates to:
  /// **'No hay usuario o comunidad'**
  String get externalNoUserOrCommunity;

  /// No description provided for @externalServiceRecommended.
  ///
  /// In es, this message translates to:
  /// **'Servicio recomendado'**
  String get externalServiceRecommended;

  /// No description provided for @externalErrorRecommending.
  ///
  /// In es, this message translates to:
  /// **'Error al recomendar servicio'**
  String get externalErrorRecommending;

  /// No description provided for @externalRecommendTitle.
  ///
  /// In es, this message translates to:
  /// **'Recomendar Servicio'**
  String get externalRecommendTitle;

  /// No description provided for @externalRecommendDesc.
  ///
  /// In es, this message translates to:
  /// **'Recomienda un servicio externo a tu comunidad'**
  String get externalRecommendDesc;

  /// No description provided for @externalServiceNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del servicio *'**
  String get externalServiceNameLabel;

  /// No description provided for @externalDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción *'**
  String get externalDescriptionLabel;

  /// No description provided for @externalDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Qué ofrece este servicio'**
  String get externalDescriptionHint;

  /// No description provided for @externalWebsiteLabel.
  ///
  /// In es, this message translates to:
  /// **'Sitio web'**
  String get externalWebsiteLabel;

  /// No description provided for @externalWebsiteHint.
  ///
  /// In es, this message translates to:
  /// **'https://ejemplo.com'**
  String get externalWebsiteHint;

  /// No description provided for @externalSendRecommendation.
  ///
  /// In es, this message translates to:
  /// **'Enviar Recomendación'**
  String get externalSendRecommendation;

  /// No description provided for @externalErrorRecommendingShort.
  ///
  /// In es, this message translates to:
  /// **'Error al recomendar'**
  String get externalErrorRecommendingShort;

  /// No description provided for @externalProfessionalNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del profesional o empresa'**
  String get externalProfessionalNameLabel;

  /// No description provided for @externalCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get externalCategoryLabel;

  /// No description provided for @externalDescribeExperienceLabel.
  ///
  /// In es, this message translates to:
  /// **'Describe tu experiencia con este servicio'**
  String get externalDescribeExperienceLabel;

  /// No description provided for @notifTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifTitle;

  /// No description provided for @notifMarkAll.
  ///
  /// In es, this message translates to:
  /// **'Marcar todas'**
  String get notifMarkAll;

  /// No description provided for @notifEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin notificaciones'**
  String get notifEmpty;

  /// No description provided for @notifEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aquí aparecerán las novedades de tu comunidad'**
  String get notifEmptySubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingSkip;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In es, this message translates to:
  /// **'Tu comunidad, conectada'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Desc.
  ///
  /// In es, this message translates to:
  /// **'Noticias, alertas y comunicados de tu conjunto en un solo lugar. Sin perderse nada en el chat.'**
  String get onboardingPage1Desc;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In es, this message translates to:
  /// **'Compra a tus vecinos'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Desc.
  ///
  /// In es, this message translates to:
  /// **'Descubre emprendimientos y servicios de tu comunidad. Apoya a quien vive al lado.'**
  String get onboardingPage2Desc;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In es, this message translates to:
  /// **'Servicios de confianza'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Desc.
  ///
  /// In es, this message translates to:
  /// **'Directorio de profesionales recomendados por tus vecinos. Electricistas, plomeros y más.'**
  String get onboardingPage3Desc;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingStart;

  /// No description provided for @feedWriteSomething.
  ///
  /// In es, this message translates to:
  /// **'Escribe algo para publicar'**
  String get feedWriteSomething;

  /// No description provided for @feedAddAtLeast2Options.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos 2 opciones'**
  String get feedAddAtLeast2Options;

  /// No description provided for @feedPublished.
  ///
  /// In es, this message translates to:
  /// **'Publicado'**
  String get feedPublished;

  /// No description provided for @feedAlertHint.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres alertar a tu comunidad?'**
  String get feedAlertHint;

  /// No description provided for @feedShareHint.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres compartir con tu comunidad?'**
  String get feedShareHint;

  /// No description provided for @feedPollOptionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Opciones de la encuesta'**
  String get feedPollOptionsTitle;

  /// No description provided for @feedPollOptionHint.
  ///
  /// In es, this message translates to:
  /// **'Opción {n}'**
  String feedPollOptionHint(int n);

  /// No description provided for @feedAddOption.
  ///
  /// In es, this message translates to:
  /// **'Agregar opción'**
  String get feedAddOption;

  /// No description provided for @feedPostTitle.
  ///
  /// In es, this message translates to:
  /// **'Post'**
  String get feedPostTitle;

  /// No description provided for @feedPostNotFound.
  ///
  /// In es, this message translates to:
  /// **'Post no encontrado'**
  String get feedPostNotFound;

  /// No description provided for @feedPinned.
  ///
  /// In es, this message translates to:
  /// **'Fijado'**
  String get feedPinned;

  /// No description provided for @feedLikesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} Me gusta'**
  String feedLikesCount(int count);

  /// No description provided for @feedCommentsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} comentarios'**
  String feedCommentsCount(int count);

  /// No description provided for @feedLikeAction.
  ///
  /// In es, this message translates to:
  /// **'Me gusta'**
  String get feedLikeAction;

  /// No description provided for @feedCommentAction.
  ///
  /// In es, this message translates to:
  /// **'Comentar'**
  String get feedCommentAction;

  /// No description provided for @feedCouldNotLike.
  ///
  /// In es, this message translates to:
  /// **'No se pudo registrar tu like'**
  String get feedCouldNotLike;

  /// No description provided for @feedPollTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuesta'**
  String get feedPollTitle;

  /// No description provided for @feedAlertBadge.
  ///
  /// In es, this message translates to:
  /// **'ALERTA'**
  String get feedAlertBadge;

  /// No description provided for @feedCouldNotPin.
  ///
  /// In es, this message translates to:
  /// **'No se pudo fijar la publicación'**
  String get feedCouldNotPin;

  /// No description provided for @feedUnpin.
  ///
  /// In es, this message translates to:
  /// **'Desfijar'**
  String get feedUnpin;

  /// No description provided for @feedPinToTop.
  ///
  /// In es, this message translates to:
  /// **'Fijar arriba'**
  String get feedPinToTop;

  /// No description provided for @feedReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar'**
  String get feedReport;

  /// No description provided for @feedReportDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar publicación'**
  String get feedReportDialogTitle;

  /// No description provided for @feedReportReasonInappropriate.
  ///
  /// In es, this message translates to:
  /// **'Contenido inapropiado'**
  String get feedReportReasonInappropriate;

  /// No description provided for @feedReportReasonSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o publicidad'**
  String get feedReportReasonSpam;

  /// No description provided for @feedReportReasonFalseInfo.
  ///
  /// In es, this message translates to:
  /// **'Información falsa'**
  String get feedReportReasonFalseInfo;

  /// No description provided for @feedReportReasonHarassment.
  ///
  /// In es, this message translates to:
  /// **'Acoso o intimidación'**
  String get feedReportReasonHarassment;

  /// No description provided for @feedReportReasonOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get feedReportReasonOther;

  /// No description provided for @feedReportSent.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado'**
  String get feedReportSent;

  /// No description provided for @feedCouldNotSendReport.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el reporte'**
  String get feedCouldNotSendReport;

  /// No description provided for @serviceFillAllFields.
  ///
  /// In es, this message translates to:
  /// **'Completa todos los campos'**
  String get serviceFillAllFields;

  /// No description provided for @serviceNoUserOrCommunity.
  ///
  /// In es, this message translates to:
  /// **'No hay usuario o comunidad'**
  String get serviceNoUserOrCommunity;

  /// No description provided for @serviceCreated.
  ///
  /// In es, this message translates to:
  /// **'Servicio creado'**
  String get serviceCreated;

  /// No description provided for @serviceCreateError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear servicio'**
  String get serviceCreateError;

  /// No description provided for @serviceOfferTitle.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer Servicio'**
  String get serviceOfferTitle;

  /// No description provided for @serviceCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get serviceCategoryLabel;

  /// No description provided for @serviceTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título del servicio'**
  String get serviceTitleLabel;

  /// No description provided for @serviceDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get serviceDescriptionLabel;

  /// No description provided for @servicePriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio (COP) - Opcional'**
  String get servicePriceLabel;

  /// No description provided for @servicePublishButton.
  ///
  /// In es, this message translates to:
  /// **'Publicar Servicio'**
  String get servicePublishButton;

  /// No description provided for @serviceDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del Servicio'**
  String get serviceDetailTitle;

  /// No description provided for @serviceNotFound.
  ///
  /// In es, this message translates to:
  /// **'Servicio no encontrado'**
  String get serviceNotFound;

  /// No description provided for @serviceOrdersCount.
  ///
  /// In es, this message translates to:
  /// **'{count} órdenes'**
  String serviceOrdersCount(int count);

  /// No description provided for @servicePriceHeading.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get servicePriceHeading;

  /// No description provided for @serviceProviderLabel.
  ///
  /// In es, this message translates to:
  /// **'Prestador de servicio'**
  String get serviceProviderLabel;

  /// No description provided for @serviceSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar servicio...'**
  String get serviceSearchHint;

  /// No description provided for @serviceScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Servicios Vecinales'**
  String get serviceScreenTitle;

  /// No description provided for @serviceSortRecent.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get serviceSortRecent;

  /// No description provided for @serviceSortRating.
  ///
  /// In es, this message translates to:
  /// **'Mejor calificación'**
  String get serviceSortRating;

  /// No description provided for @serviceSortPopular.
  ///
  /// In es, this message translates to:
  /// **'Más populares'**
  String get serviceSortPopular;

  /// No description provided for @serviceEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin servicios aún'**
  String get serviceEmptyTitle;

  /// No description provided for @serviceEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ofrece tus productos o servicios a tu comunidad'**
  String get serviceEmptySubtitle;

  /// No description provided for @serviceLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar servicios'**
  String get serviceLoadError;

  /// No description provided for @serviceOfferFab.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer'**
  String get serviceOfferFab;

  /// No description provided for @storeMyOrdersTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Pedidos'**
  String get storeMyOrdersTitle;

  /// No description provided for @storeNoOrdersTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin pedidos'**
  String get storeNoOrdersTitle;

  /// No description provided for @storeNoOrdersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus pedidos a tiendas del barrio aparecerán aquí'**
  String get storeNoOrdersSubtitle;

  /// No description provided for @storeLoadOrdersError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar pedidos'**
  String get storeLoadOrdersError;

  /// No description provided for @storeOrderTrackingTitle.
  ///
  /// In es, this message translates to:
  /// **'Estado del Pedido'**
  String get storeOrderTrackingTitle;

  /// No description provided for @storeOrderNotFound.
  ///
  /// In es, this message translates to:
  /// **'Pedido no encontrado'**
  String get storeOrderNotFound;

  /// No description provided for @storeOrderNumber.
  ///
  /// In es, this message translates to:
  /// **'Pedido #{code}'**
  String storeOrderNumber(String code);

  /// No description provided for @storeOrderCancelledMessage.
  ///
  /// In es, this message translates to:
  /// **'Este pedido fue cancelado'**
  String get storeOrderCancelledMessage;

  /// No description provided for @storeOrderSummaryLabel.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get storeOrderSummaryLabel;

  /// No description provided for @storeServiceFeeLabel.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get storeServiceFeeLabel;

  /// No description provided for @storeTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get storeTotalLabel;

  /// No description provided for @storeRateOrderButton.
  ///
  /// In es, this message translates to:
  /// **'Calificar pedido'**
  String get storeRateOrderButton;

  /// No description provided for @storeSelectRatingError.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una calificación'**
  String get storeSelectRatingError;

  /// No description provided for @storeRatingSubmitted.
  ///
  /// In es, this message translates to:
  /// **'Calificación enviada'**
  String get storeRatingSubmitted;

  /// No description provided for @storeRatingSubmitError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar calificación'**
  String get storeRatingSubmitError;

  /// No description provided for @storeRateOrderQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo fue tu pedido en {storeName}?'**
  String storeRateOrderQuestion(String storeName);

  /// No description provided for @storeCommentHint.
  ///
  /// In es, this message translates to:
  /// **'Comentario opcional...'**
  String get storeCommentHint;

  /// No description provided for @storeSubmitRatingButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar calificación'**
  String get storeSubmitRatingButton;

  /// No description provided for @storeRatingVeryBad.
  ///
  /// In es, this message translates to:
  /// **'Muy malo'**
  String get storeRatingVeryBad;

  /// No description provided for @storeRatingBad.
  ///
  /// In es, this message translates to:
  /// **'Malo'**
  String get storeRatingBad;

  /// No description provided for @storeRatingRegular.
  ///
  /// In es, this message translates to:
  /// **'Regular'**
  String get storeRatingRegular;

  /// No description provided for @storeRatingGood.
  ///
  /// In es, this message translates to:
  /// **'Bueno'**
  String get storeRatingGood;

  /// No description provided for @storeRatingExcellent.
  ///
  /// In es, this message translates to:
  /// **'Excelente'**
  String get storeRatingExcellent;

  /// No description provided for @storeOrderCreated.
  ///
  /// In es, this message translates to:
  /// **'Pedido creado'**
  String get storeOrderCreated;

  /// No description provided for @storeOrderCreateError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el pedido'**
  String get storeOrderCreateError;

  /// No description provided for @storeDefaultTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get storeDefaultTitle;

  /// No description provided for @storeNoItemsMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta tienda no tiene productos aún'**
  String get storeNoItemsMessage;

  /// No description provided for @storePaymentMethodLabel.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get storePaymentMethodLabel;

  /// No description provided for @storeCashOnDeliveryTitle.
  ///
  /// In es, this message translates to:
  /// **'Contra entrega'**
  String get storeCashOnDeliveryTitle;

  /// No description provided for @storeCashOnDeliverySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Paga al recibir tu pedido'**
  String get storeCashOnDeliverySubtitle;

  /// No description provided for @storeOnlinePaymentTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago en línea'**
  String get storeOnlinePaymentTitle;

  /// No description provided for @storeOnlinePaymentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'PSE, tarjeta o Nequi via Wompi'**
  String get storeOnlinePaymentSubtitle;

  /// No description provided for @storePayOnlineLabel.
  ///
  /// In es, this message translates to:
  /// **'Pagar en línea'**
  String get storePayOnlineLabel;

  /// No description provided for @storeOrderCashLabel.
  ///
  /// In es, this message translates to:
  /// **'Pedir (contra entrega)'**
  String get storeOrderCashLabel;

  /// No description provided for @storePanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Tienda'**
  String get storePanelTitle;

  /// No description provided for @storeCreatePrompt.
  ///
  /// In es, this message translates to:
  /// **'Crea tu tienda para empezar a vender productos a tu comunidad'**
  String get storeCreatePrompt;

  /// No description provided for @storeCreateMyStoreButton.
  ///
  /// In es, this message translates to:
  /// **'Crear mi tienda'**
  String get storeCreateMyStoreButton;

  /// No description provided for @storeCreateDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear tienda'**
  String get storeCreateDialogTitle;

  /// No description provided for @storeNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la tienda'**
  String get storeNameLabel;

  /// No description provided for @storeDeliveryTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de entrega'**
  String get storeDeliveryTimeLabel;

  /// No description provided for @storeMinOrderLabel.
  ///
  /// In es, this message translates to:
  /// **'Pedido mínimo'**
  String get storeMinOrderLabel;

  /// No description provided for @storeNoCommunityAssigned.
  ///
  /// In es, this message translates to:
  /// **'No hay comunidad asignada'**
  String get storeNoCommunityAssigned;

  /// No description provided for @storeCreated.
  ///
  /// In es, this message translates to:
  /// **'Tienda creada'**
  String get storeCreated;

  /// No description provided for @storePanelNoOrdersTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin pedidos'**
  String get storePanelNoOrdersTitle;

  /// No description provided for @storePanelNoOrdersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los pedidos de tus clientes aparecerán aquí'**
  String get storePanelNoOrdersSubtitle;

  /// No description provided for @storePendingLabel.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get storePendingLabel;

  /// No description provided for @storeActiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get storeActiveLabel;

  /// No description provided for @storeTodayLabel.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get storeTodayLabel;

  /// No description provided for @storeNewOrdersCount.
  ///
  /// In es, this message translates to:
  /// **'Nuevos pedidos ({count})'**
  String storeNewOrdersCount(int count);

  /// No description provided for @storeInProgressCount.
  ///
  /// In es, this message translates to:
  /// **'En proceso ({count})'**
  String storeInProgressCount(int count);

  /// No description provided for @storeCompletedLabel.
  ///
  /// In es, this message translates to:
  /// **'Completados'**
  String get storeCompletedLabel;

  /// No description provided for @storeNewItemFab.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get storeNewItemFab;

  /// No description provided for @storeNoItemsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin productos'**
  String get storeNoItemsTitle;

  /// No description provided for @storeNoItemsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agrega tu primer producto con el botón +'**
  String get storeNoItemsSubtitle;

  /// No description provided for @storeDeleteProductTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar producto'**
  String get storeDeleteProductTitle;

  /// No description provided for @storeDeleteProductConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String storeDeleteProductConfirm(String name);

  /// No description provided for @storeHideLabel.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get storeHideLabel;

  /// No description provided for @storeActivateLabel.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get storeActivateLabel;

  /// No description provided for @storeNewProductTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo producto'**
  String get storeNewProductTitle;

  /// No description provided for @storeEditProductTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get storeEditProductTitle;

  /// No description provided for @storeItemNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get storeItemNameLabel;

  /// No description provided for @storeItemPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio (COP)'**
  String get storeItemPriceLabel;

  /// No description provided for @storeProductCreated.
  ///
  /// In es, this message translates to:
  /// **'Producto creado'**
  String get storeProductCreated;

  /// No description provided for @storeProductUpdated.
  ///
  /// In es, this message translates to:
  /// **'Producto actualizado'**
  String get storeProductUpdated;

  /// No description provided for @storeStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get storeStatusLabel;

  /// No description provided for @storeActiveStatus.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get storeActiveStatus;

  /// No description provided for @storeInactiveStatus.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get storeInactiveStatus;

  /// No description provided for @storeRatingLabel.
  ///
  /// In es, this message translates to:
  /// **'Calificación'**
  String get storeRatingLabel;

  /// No description provided for @storeCompletedOrdersLabel.
  ///
  /// In es, this message translates to:
  /// **'Pedidos completados'**
  String get storeCompletedOrdersLabel;

  /// No description provided for @storeEditInfoButton.
  ///
  /// In es, this message translates to:
  /// **'Editar información'**
  String get storeEditInfoButton;

  /// No description provided for @storePauseStoreButton.
  ///
  /// In es, this message translates to:
  /// **'Pausar tienda'**
  String get storePauseStoreButton;

  /// No description provided for @storeReactivateStoreButton.
  ///
  /// In es, this message translates to:
  /// **'Reactivar tienda'**
  String get storeReactivateStoreButton;

  /// No description provided for @storeEditDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar tienda'**
  String get storeEditDialogTitle;

  /// No description provided for @storeUpdated.
  ///
  /// In es, this message translates to:
  /// **'Actualizado'**
  String get storeUpdated;

  /// No description provided for @storeRejectButton.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get storeRejectButton;

  /// No description provided for @storeMarkOnWayButton.
  ///
  /// In es, this message translates to:
  /// **'Marcar en camino'**
  String get storeMarkOnWayButton;

  /// No description provided for @storeMarkDeliveredButton.
  ///
  /// In es, this message translates to:
  /// **'Marcar entregado'**
  String get storeMarkDeliveredButton;

  /// No description provided for @storeScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Tiendas del Barrio'**
  String get storeScreenTitle;

  /// No description provided for @storeBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Pide sin salir de casa'**
  String get storeBannerTitle;

  /// No description provided for @storeBannerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entrega directa en tu puerta'**
  String get storeBannerSubtitle;

  /// No description provided for @storeEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin tiendas aún'**
  String get storeEmptyTitle;

  /// No description provided for @storeEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las tiendas de tu barrio aparecerán aquí'**
  String get storeEmptySubtitle;

  /// No description provided for @storeLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar tiendas'**
  String get storeLoadError;

  /// No description provided for @amenityScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Zonas Sociales'**
  String get amenityScreenTitle;

  /// No description provided for @amenityNewButton.
  ///
  /// In es, this message translates to:
  /// **'Nueva'**
  String get amenityNewButton;

  /// No description provided for @amenityEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin zonas configuradas'**
  String get amenityEmptyTitle;

  /// No description provided for @amenityEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las zonas sociales de tu conjunto aparecerán aquí'**
  String get amenityEmptySubtitle;

  /// No description provided for @amenityCapacityLabel.
  ///
  /// In es, this message translates to:
  /// **'{count} personas'**
  String amenityCapacityLabel(int count);

  /// No description provided for @amenityDepositLabel.
  ///
  /// In es, this message translates to:
  /// **'Depósito reembolsable: {amount}'**
  String amenityDepositLabel(String amount);

  /// No description provided for @amenityCapacityColon.
  ///
  /// In es, this message translates to:
  /// **'Capacidad: {count} personas'**
  String amenityCapacityColon(int count);

  /// No description provided for @amenityRateColon.
  ///
  /// In es, this message translates to:
  /// **'Tarifa: {amount}'**
  String amenityRateColon(String amount);

  /// No description provided for @amenityDepositColon.
  ///
  /// In es, this message translates to:
  /// **'Depósito: {amount} (reembolsable)'**
  String amenityDepositColon(String amount);

  /// No description provided for @amenityAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get amenityAvailable;

  /// No description provided for @amenityReserved.
  ///
  /// In es, this message translates to:
  /// **'Reservado'**
  String get amenityReserved;

  /// No description provided for @amenitySelected.
  ///
  /// In es, this message translates to:
  /// **'Seleccionado'**
  String get amenitySelected;

  /// No description provided for @amenityScheduleColon.
  ///
  /// In es, this message translates to:
  /// **'Horario: {hours}'**
  String amenityScheduleColon(String hours);

  /// No description provided for @amenityRentalPlusDeposit.
  ///
  /// In es, this message translates to:
  /// **'Alquiler + depósito'**
  String get amenityRentalPlusDeposit;

  /// No description provided for @amenityPayAndBook.
  ///
  /// In es, this message translates to:
  /// **'Pagar y Reservar'**
  String get amenityPayAndBook;

  /// No description provided for @amenityBookingCreated.
  ///
  /// In es, this message translates to:
  /// **'Reserva creada'**
  String get amenityBookingCreated;

  /// No description provided for @amenityCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva zona social'**
  String get amenityCreateTitle;

  /// No description provided for @amenityCreated.
  ///
  /// In es, this message translates to:
  /// **'Zona creada'**
  String get amenityCreated;

  /// No description provided for @amenityNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get amenityNameLabel;

  /// No description provided for @amenityNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Salón social, BBQ, Piscina'**
  String get amenityNameHint;

  /// No description provided for @amenityCapacityFeesSection.
  ///
  /// In es, this message translates to:
  /// **'Capacidad y tarifas'**
  String get amenityCapacityFeesSection;

  /// No description provided for @amenityCapacityFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Capacidad (personas)'**
  String get amenityCapacityFieldLabel;

  /// No description provided for @amenityHourlyRateLabel.
  ///
  /// In es, this message translates to:
  /// **'Tarifa por hora (COP)'**
  String get amenityHourlyRateLabel;

  /// No description provided for @amenityDepositOptionalLabel.
  ///
  /// In es, this message translates to:
  /// **'Depósito reembolsable (opcional)'**
  String get amenityDepositOptionalLabel;

  /// No description provided for @amenityDepositHelper.
  ///
  /// In es, this message translates to:
  /// **'Se retiene y devuelve si no hay daños'**
  String get amenityDepositHelper;

  /// No description provided for @amenityScheduleRulesSection.
  ///
  /// In es, this message translates to:
  /// **'Horario y reglas'**
  String get amenityScheduleRulesSection;

  /// No description provided for @amenityHoursLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get amenityHoursLabel;

  /// No description provided for @amenityRulesLabel.
  ///
  /// In es, this message translates to:
  /// **'Reglas (opcional)'**
  String get amenityRulesLabel;

  /// No description provided for @amenityRulesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Aforo máximo 15, no música después de 22h'**
  String get amenityRulesHint;

  /// No description provided for @amenityCreateSubmit.
  ///
  /// In es, this message translates to:
  /// **'Crear zona'**
  String get amenityCreateSubmit;

  /// No description provided for @assemblyScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Asambleas'**
  String get assemblyScreenTitle;

  /// No description provided for @assemblyConvene.
  ///
  /// In es, this message translates to:
  /// **'Convocar'**
  String get assemblyConvene;

  /// No description provided for @assemblyEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin asambleas'**
  String get assemblyEmptyTitle;

  /// No description provided for @assemblyEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las convocatorias de asamblea aparecerán aquí'**
  String get assemblyEmptySubtitle;

  /// No description provided for @assemblyLive.
  ///
  /// In es, this message translates to:
  /// **'EN VIVO'**
  String get assemblyLive;

  /// No description provided for @assemblyAgendaCount.
  ///
  /// In es, this message translates to:
  /// **'Orden del día: {count} puntos'**
  String assemblyAgendaCount(int count);

  /// No description provided for @assemblyAttendeesRegistered.
  ///
  /// In es, this message translates to:
  /// **'{count} asistentes registrados'**
  String assemblyAttendeesRegistered(int count);

  /// No description provided for @assemblyVoteRegistered.
  ///
  /// In es, this message translates to:
  /// **'Voto registrado'**
  String get assemblyVoteRegistered;

  /// No description provided for @assemblyTotalVotes.
  ///
  /// In es, this message translates to:
  /// **'{count} votos'**
  String assemblyTotalVotes(int count);

  /// No description provided for @assemblyAgendaRequired.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un punto al orden del día'**
  String get assemblyAgendaRequired;

  /// No description provided for @assemblyConvened.
  ///
  /// In es, this message translates to:
  /// **'Asamblea convocada'**
  String get assemblyConvened;

  /// No description provided for @assemblyConveneTitle.
  ///
  /// In es, this message translates to:
  /// **'Convocar asamblea'**
  String get assemblyConveneTitle;

  /// No description provided for @assemblyTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get assemblyTitleLabel;

  /// No description provided for @assemblyTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Asamblea ordinaria 2026'**
  String get assemblyTitleHint;

  /// No description provided for @assemblyLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar (opcional)'**
  String get assemblyLocationLabel;

  /// No description provided for @assemblyLocationHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Salón Social'**
  String get assemblyLocationHint;

  /// No description provided for @assemblyVirtualLinkLabel.
  ///
  /// In es, this message translates to:
  /// **'Link virtual (opcional)'**
  String get assemblyVirtualLinkLabel;

  /// No description provided for @assemblyAgendaTitle.
  ///
  /// In es, this message translates to:
  /// **'Orden del día'**
  String get assemblyAgendaTitle;

  /// No description provided for @assemblyAddAgendaItem.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get assemblyAddAgendaItem;

  /// No description provided for @assemblyAgendaItemHint.
  ///
  /// In es, this message translates to:
  /// **'Punto del orden del día'**
  String get assemblyAgendaItemHint;

  /// No description provided for @assemblyConveneHelper.
  ///
  /// In es, this message translates to:
  /// **'Al convocar, los residentes serán notificados y podrán confirmar asistencia. Las votaciones se pueden iniciar el día de la asamblea.'**
  String get assemblyConveneHelper;

  /// No description provided for @circularScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Circulares'**
  String get circularScreenTitle;

  /// No description provided for @circularEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin circulares'**
  String get circularEmptyTitle;

  /// No description provided for @circularEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los comunicados oficiales aparecerán aquí'**
  String get circularEmptySubtitle;

  /// No description provided for @circularAttachmentsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} adjunto(s)'**
  String circularAttachmentsCount(int count);

  /// No description provided for @circularReadPercentage.
  ///
  /// In es, this message translates to:
  /// **'{pct}% leído'**
  String circularReadPercentage(int pct);

  /// No description provided for @circularSignAck.
  ///
  /// In es, this message translates to:
  /// **'Firmar acuse de recibo'**
  String get circularSignAck;

  /// No description provided for @circularTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un título'**
  String get circularTitleRequired;

  /// No description provided for @circularBodyRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el contenido'**
  String get circularBodyRequired;

  /// No description provided for @circularPublished.
  ///
  /// In es, this message translates to:
  /// **'Circular publicada'**
  String get circularPublished;

  /// No description provided for @circularCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva Circular'**
  String get circularCreateTitle;

  /// No description provided for @circularPriority.
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get circularPriority;

  /// No description provided for @circularTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título de la circular'**
  String get circularTitleLabel;

  /// No description provided for @circularTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Corte de agua programado'**
  String get circularTitleHint;

  /// No description provided for @circularContentLabel.
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get circularContentLabel;

  /// No description provided for @circularContentHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe el comunicado completo...'**
  String get circularContentHint;

  /// No description provided for @circularRequiresAck.
  ///
  /// In es, this message translates to:
  /// **'Requiere firma de acuse'**
  String get circularRequiresAck;

  /// No description provided for @circularRequiresAckHelper.
  ///
  /// In es, this message translates to:
  /// **'Los residentes deberán firmar que lo leyeron'**
  String get circularRequiresAckHelper;

  /// No description provided for @financeStatementTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Estado de Cuenta'**
  String get financeStatementTitle;

  /// No description provided for @financeStatementUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No hay estado de cuenta disponible'**
  String get financeStatementUnavailable;

  /// No description provided for @financeCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get financeCurrentBalance;

  /// No description provided for @financeUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Estás al día'**
  String get financeUpToDate;

  /// No description provided for @financePendingBalance.
  ///
  /// In es, this message translates to:
  /// **'Tienes saldo pendiente'**
  String get financePendingBalance;

  /// No description provided for @financePayFee.
  ///
  /// In es, this message translates to:
  /// **'Pagar cuota'**
  String get financePayFee;

  /// No description provided for @financeHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get financeHistory;

  /// No description provided for @financeNoMovements.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos registrados'**
  String get financeNoMovements;

  /// No description provided for @financePaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get financePaid;

  /// No description provided for @financePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get financePending;

  /// No description provided for @financeEntryRegistered.
  ///
  /// In es, this message translates to:
  /// **'Movimiento registrado'**
  String get financeEntryRegistered;

  /// No description provided for @financeNewEntryTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get financeNewEntryTitle;

  /// No description provided for @financeIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get financeIncome;

  /// No description provided for @financeExpense.
  ///
  /// In es, this message translates to:
  /// **'Egreso'**
  String get financeExpense;

  /// No description provided for @financeCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get financeCategoryLabel;

  /// No description provided for @financeCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Cuota administración, Mantenimiento'**
  String get financeCategoryHint;

  /// No description provided for @financeAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto (COP)'**
  String get financeAmountLabel;

  /// No description provided for @financeDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get financeDateLabel;

  /// No description provided for @financeRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get financeRegister;

  /// No description provided for @financeDashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Dashboard Financiero'**
  String get financeDashboardTitle;

  /// No description provided for @financeExportPdf.
  ///
  /// In es, this message translates to:
  /// **'Exportar PDF'**
  String get financeExportPdf;

  /// No description provided for @financeGeneratingReport.
  ///
  /// In es, this message translates to:
  /// **'Generando reporte PDF...'**
  String get financeGeneratingReport;

  /// No description provided for @financeBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo'**
  String get financeBalance;

  /// No description provided for @financeBudgetVsExecution.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto vs. Ejecución'**
  String get financeBudgetVsExecution;

  /// No description provided for @financeExecution.
  ///
  /// In es, this message translates to:
  /// **'Ejecución'**
  String get financeExecution;

  /// No description provided for @financeBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get financeBudget;

  /// No description provided for @financeExecuted.
  ///
  /// In es, this message translates to:
  /// **'Ejecutado'**
  String get financeExecuted;

  /// No description provided for @financeConfigureBudgets.
  ///
  /// In es, this message translates to:
  /// **'Configura presupuestos para comparar con la ejecución'**
  String get financeConfigureBudgets;

  /// No description provided for @financePortfolio.
  ///
  /// In es, this message translates to:
  /// **'Cartera'**
  String get financePortfolio;

  /// No description provided for @financeNoStatements.
  ///
  /// In es, this message translates to:
  /// **'Sin estados de cuenta cargados'**
  String get financeNoStatements;

  /// No description provided for @financeCollectionRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa de recaudo'**
  String get financeCollectionRate;

  /// No description provided for @financeOverdueBalance.
  ///
  /// In es, this message translates to:
  /// **'Cartera morosa'**
  String get financeOverdueBalance;

  /// No description provided for @financeMovements.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get financeMovements;

  /// No description provided for @financeRegisterExpensesForChart.
  ///
  /// In es, this message translates to:
  /// **'Registra egresos por categoría para ver el gráfico'**
  String get financeRegisterExpensesForChart;

  /// No description provided for @financePayPendingFee.
  ///
  /// In es, this message translates to:
  /// **'Pagar cuota pendiente'**
  String get financePayPendingFee;

  /// No description provided for @fineManagementTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Multas'**
  String get fineManagementTitle;

  /// No description provided for @fineMyTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Multas'**
  String get fineMyTitle;

  /// No description provided for @fineEmptyAdminTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin multas registradas'**
  String get fineEmptyAdminTitle;

  /// No description provided for @fineEmptyResidentTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin multas'**
  String get fineEmptyResidentTitle;

  /// No description provided for @fineEmptyAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las multas que registres aparecerán aquí'**
  String get fineEmptyAdminSubtitle;

  /// No description provided for @fineEmptyResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes multas pendientes'**
  String get fineEmptyResidentSubtitle;

  /// No description provided for @fineUnitLabel.
  ///
  /// In es, this message translates to:
  /// **'Apto {unit}'**
  String fineUnitLabel(String unit);

  /// No description provided for @fineResidentDefense.
  ///
  /// In es, this message translates to:
  /// **'Descargo del residente'**
  String get fineResidentDefense;

  /// No description provided for @fineDaysLeftForDefense.
  ///
  /// In es, this message translates to:
  /// **'⏱ {days} días para presentar descargo'**
  String fineDaysLeftForDefense(int days);

  /// No description provided for @fineSubmitDefense.
  ///
  /// In es, this message translates to:
  /// **'Presentar descargo'**
  String get fineSubmitDefense;

  /// No description provided for @fineConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar multa'**
  String get fineConfirm;

  /// No description provided for @fineVoid.
  ///
  /// In es, this message translates to:
  /// **'Anular'**
  String get fineVoid;

  /// No description provided for @fineDefenseHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu versión de los hechos...'**
  String get fineDefenseHint;

  /// No description provided for @fineDefenseSent.
  ///
  /// In es, this message translates to:
  /// **'Descargo enviado'**
  String get fineDefenseSent;

  /// No description provided for @fineSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get fineSend;

  /// No description provided for @fineUnitRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la unidad (ej: T2-801)'**
  String get fineUnitRequired;

  /// No description provided for @fineReasonRequired.
  ///
  /// In es, this message translates to:
  /// **'Describe el motivo'**
  String get fineReasonRequired;

  /// No description provided for @fineAmountRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido'**
  String get fineAmountRequired;

  /// No description provided for @fineRegistered.
  ///
  /// In es, this message translates to:
  /// **'Multa registrada'**
  String get fineRegistered;

  /// No description provided for @fineCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar Multa'**
  String get fineCreateTitle;

  /// No description provided for @fineUnitFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Unidad / Apartamento'**
  String get fineUnitFieldLabel;

  /// No description provided for @fineReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la multa'**
  String get fineReasonLabel;

  /// No description provided for @fineReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Describe la infracción...'**
  String get fineReasonHint;

  /// No description provided for @fineManualArticleLabel.
  ///
  /// In es, this message translates to:
  /// **'Artículo del manual (opcional)'**
  String get fineManualArticleLabel;

  /// No description provided for @fineDefenseDeadline.
  ///
  /// In es, this message translates to:
  /// **'Plazo para descargos'**
  String get fineDefenseDeadline;

  /// No description provided for @fineDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String fineDaysCount(int days);

  /// No description provided for @fineNotifyInfo.
  ///
  /// In es, this message translates to:
  /// **'El residente será notificado y tendrá el plazo indicado para presentar descargos.'**
  String get fineNotifyInfo;

  /// No description provided for @fineDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Multa'**
  String get fineDetailTitle;

  /// No description provided for @fineNotFound.
  ///
  /// In es, this message translates to:
  /// **'Multa no encontrada'**
  String get fineNotFound;

  /// No description provided for @fineNumber.
  ///
  /// In es, this message translates to:
  /// **'Multa #{id}'**
  String fineNumber(String id);

  /// No description provided for @fineReasonTitle.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get fineReasonTitle;

  /// No description provided for @fineManualArticleTitle.
  ///
  /// In es, this message translates to:
  /// **'Artículo del manual'**
  String get fineManualArticleTitle;

  /// No description provided for @fineEvidence.
  ///
  /// In es, this message translates to:
  /// **'Evidencia'**
  String get fineEvidence;

  /// No description provided for @fineDefense.
  ///
  /// In es, this message translates to:
  /// **'Descargo'**
  String get fineDefense;

  /// No description provided for @fineDaysRemaining.
  ///
  /// In es, this message translates to:
  /// **'{days} días restantes'**
  String fineDaysRemaining(int days);

  /// No description provided for @fineDefenseFieldHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu descargo aquí...'**
  String get fineDefenseFieldHint;

  /// No description provided for @fineSendDefense.
  ///
  /// In es, this message translates to:
  /// **'Enviar descargo'**
  String get fineSendDefense;

  /// No description provided for @finePayFine.
  ///
  /// In es, this message translates to:
  /// **'Pagar multa'**
  String get finePayFine;

  /// No description provided for @fineWriteDefense.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu descargo'**
  String get fineWriteDefense;

  /// No description provided for @fineConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar la multa de \${amount}?'**
  String fineConfirmMessage(int amount);

  /// No description provided for @fineVoidTitle.
  ///
  /// In es, this message translates to:
  /// **'Anular multa'**
  String get fineVoidTitle;

  /// No description provided for @fineVoidMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de anular esta multa?'**
  String get fineVoidMessage;

  /// No description provided for @manualScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Manual de Convivencia'**
  String get manualScreenTitle;

  /// No description provided for @manualSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar en el manual...'**
  String get manualSearchHint;

  /// No description provided for @manualLinkedFines.
  ///
  /// In es, this message translates to:
  /// **'{count} multas vinculadas'**
  String manualLinkedFines(int count);

  /// No description provided for @pqrsScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'PQRS'**
  String get pqrsScreenTitle;

  /// No description provided for @pqrsEmptyAdminTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin PQRS'**
  String get pqrsEmptyAdminTitle;

  /// No description provided for @pqrsEmptyResidentTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin solicitudes'**
  String get pqrsEmptyResidentTitle;

  /// No description provided for @pqrsEmptyAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las solicitudes de residentes aparecerán aquí'**
  String get pqrsEmptyAdminSubtitle;

  /// No description provided for @pqrsEmptyResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Envía peticiones, quejas o sugerencias'**
  String get pqrsEmptyResidentSubtitle;

  /// No description provided for @pqrsOpen.
  ///
  /// In es, this message translates to:
  /// **'Abiertos'**
  String get pqrsOpen;

  /// No description provided for @pqrsInProgress.
  ///
  /// In es, this message translates to:
  /// **'En gestión'**
  String get pqrsInProgress;

  /// No description provided for @pqrsResolved.
  ///
  /// In es, this message translates to:
  /// **'Resueltos'**
  String get pqrsResolved;

  /// No description provided for @pqrsResidentUnit.
  ///
  /// In es, this message translates to:
  /// **'{name} · {unit}'**
  String pqrsResidentUnit(String name, String unit);

  /// No description provided for @pqrsAdminResponse.
  ///
  /// In es, this message translates to:
  /// **'Respuesta de la administración'**
  String get pqrsAdminResponse;

  /// No description provided for @pqrsSlaOverdue.
  ///
  /// In es, this message translates to:
  /// **'SLA vencido'**
  String get pqrsSlaOverdue;

  /// No description provided for @pqrsRespond.
  ///
  /// In es, this message translates to:
  /// **'Responder'**
  String get pqrsRespond;

  /// No description provided for @pqrsRespondTitle.
  ///
  /// In es, this message translates to:
  /// **'Responder PQRS'**
  String get pqrsRespondTitle;

  /// No description provided for @pqrsResponseHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe la respuesta...'**
  String get pqrsResponseHint;

  /// No description provided for @pqrsResponseSent.
  ///
  /// In es, this message translates to:
  /// **'Respuesta enviada'**
  String get pqrsResponseSent;

  /// No description provided for @pqrsDescribeRequest.
  ///
  /// In es, this message translates to:
  /// **'Describe tu solicitud'**
  String get pqrsDescribeRequest;

  /// No description provided for @pqrsSent.
  ///
  /// In es, this message translates to:
  /// **'PQRS enviado'**
  String get pqrsSent;

  /// No description provided for @pqrsCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo PQRS'**
  String get pqrsCreateTitle;

  /// No description provided for @pqrsRequestType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de solicitud'**
  String get pqrsRequestType;

  /// No description provided for @pqrsCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get pqrsCategory;

  /// No description provided for @pqrsDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe tu petición, queja, reclamo o sugerencia...'**
  String get pqrsDescriptionHint;

  /// No description provided for @pqrsNotifyInfo.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud será enviada al administrador del conjunto. Recibirás notificación cuando sea atendida.'**
  String get pqrsNotifyInfo;

  /// No description provided for @premiumDashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Vecindario Admin'**
  String get premiumDashboardTitle;

  /// No description provided for @premiumNotActive.
  ///
  /// In es, this message translates to:
  /// **'Tu comunidad aún no tiene Vecindario Admin activo.'**
  String get premiumNotActive;

  /// No description provided for @premiumViewPlans.
  ///
  /// In es, this message translates to:
  /// **'Ver planes'**
  String get premiumViewPlans;

  /// No description provided for @premiumQuickActions.
  ///
  /// In es, this message translates to:
  /// **'ACCIONES RÁPIDAS'**
  String get premiumQuickActions;

  /// No description provided for @premiumSendOfficialNotice.
  ///
  /// In es, this message translates to:
  /// **'Enviar comunicado oficial'**
  String get premiumSendOfficialNotice;

  /// No description provided for @premiumCreateSanctionWithEvidence.
  ///
  /// In es, this message translates to:
  /// **'Crear sanción con evidencia'**
  String get premiumCreateSanctionWithEvidence;

  /// No description provided for @premiumCreateConvocationWithAgenda.
  ///
  /// In es, this message translates to:
  /// **'Crear convocatoria con agenda'**
  String get premiumCreateConvocationWithAgenda;

  /// No description provided for @premiumModules.
  ///
  /// In es, this message translates to:
  /// **'MÓDULOS'**
  String get premiumModules;

  /// No description provided for @premiumCircularsAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar comunicados con tracking de lectura'**
  String get premiumCircularsAdminSubtitle;

  /// No description provided for @premiumCircularsResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comunicados oficiales de tu conjunto'**
  String get premiumCircularsResidentSubtitle;

  /// No description provided for @premiumFinesAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar y gestionar sanciones'**
  String get premiumFinesAdminSubtitle;

  /// No description provided for @premiumFinesResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus multas y descargos'**
  String get premiumFinesResidentSubtitle;

  /// No description provided for @premiumPqrsAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes de residentes con SLA'**
  String get premiumPqrsAdminSubtitle;

  /// No description provided for @premiumPqrsResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Envía peticiones, quejas o sugerencias'**
  String get premiumPqrsResidentSubtitle;

  /// No description provided for @premiumManualSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reglamento del conjunto por capítulos'**
  String get premiumManualSubtitle;

  /// No description provided for @premiumAmenitiesAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar reservas y depósitos'**
  String get premiumAmenitiesAdminSubtitle;

  /// No description provided for @premiumAmenitiesResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reservar salón, BBQ, cancha y más'**
  String get premiumAmenitiesResidentSubtitle;

  /// No description provided for @premiumFinancesAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresos, egresos y presupuesto'**
  String get premiumFinancesAdminSubtitle;

  /// No description provided for @premiumFinancesResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu saldo, pagos y cuotas'**
  String get premiumFinancesResidentSubtitle;

  /// No description provided for @premiumAssembliesAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Convocar y gestionar votaciones'**
  String get premiumAssembliesAdminSubtitle;

  /// No description provided for @premiumAssembliesResidentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Participar y votar en tiempo real'**
  String get premiumAssembliesResidentSubtitle;

  /// No description provided for @premiumResidents.
  ///
  /// In es, this message translates to:
  /// **'Residentes'**
  String get premiumResidents;

  /// No description provided for @premiumOpenPqrs.
  ///
  /// In es, this message translates to:
  /// **'PQRS abiertos'**
  String get premiumOpenPqrs;

  /// No description provided for @premiumMonthlyRevenue.
  ///
  /// In es, this message translates to:
  /// **'Recaudo mes'**
  String get premiumMonthlyRevenue;

  /// No description provided for @subscriptionPlansTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes Vecindario Admin'**
  String get subscriptionPlansTitle;

  /// No description provided for @subscriptionTagline.
  ///
  /// In es, this message translates to:
  /// **'Digitaliza la gestión de tu conjunto'**
  String get subscriptionTagline;

  /// No description provided for @subscriptionFirstMonthFree.
  ///
  /// In es, this message translates to:
  /// **'Primer mes gratis'**
  String get subscriptionFirstMonthFree;

  /// No description provided for @subscriptionUnitsStarter.
  ///
  /// In es, this message translates to:
  /// **'1 - 50 unidades'**
  String get subscriptionUnitsStarter;

  /// No description provided for @subscriptionUnitsProfessional.
  ///
  /// In es, this message translates to:
  /// **'51 - 150 unidades'**
  String get subscriptionUnitsProfessional;

  /// No description provided for @subscriptionUnitsEnterprise.
  ///
  /// In es, this message translates to:
  /// **'151+ unidades'**
  String get subscriptionUnitsEnterprise;

  /// No description provided for @subscriptionFeatureCircularsTracking.
  ///
  /// In es, this message translates to:
  /// **'Circulares con tracking'**
  String get subscriptionFeatureCircularsTracking;

  /// No description provided for @subscriptionFeaturePqrsSla.
  ///
  /// In es, this message translates to:
  /// **'PQRS con SLA'**
  String get subscriptionFeaturePqrsSla;

  /// No description provided for @subscriptionFeatureManual.
  ///
  /// In es, this message translates to:
  /// **'Manual de convivencia'**
  String get subscriptionFeatureManual;

  /// No description provided for @subscriptionFeatureFineManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de multas'**
  String get subscriptionFeatureFineManagement;

  /// No description provided for @subscriptionFeatureAmenities.
  ///
  /// In es, this message translates to:
  /// **'Zonas sociales'**
  String get subscriptionFeatureAmenities;

  /// No description provided for @subscriptionFeatureFinances.
  ///
  /// In es, this message translates to:
  /// **'Finanzas'**
  String get subscriptionFeatureFinances;

  /// No description provided for @subscriptionFeatureAllStarter.
  ///
  /// In es, this message translates to:
  /// **'Todo de Starter'**
  String get subscriptionFeatureAllStarter;

  /// No description provided for @subscriptionFeatureAmenitiesBooking.
  ///
  /// In es, this message translates to:
  /// **'Reserva zonas sociales'**
  String get subscriptionFeatureAmenitiesBooking;

  /// No description provided for @subscriptionFeatureOnlinePayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos en línea'**
  String get subscriptionFeatureOnlinePayments;

  /// No description provided for @subscriptionFeatureFinanceDashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard financiero'**
  String get subscriptionFeatureFinanceDashboard;

  /// No description provided for @subscriptionFeatureIndividualStatement.
  ///
  /// In es, this message translates to:
  /// **'Estado de cuenta individual'**
  String get subscriptionFeatureIndividualStatement;

  /// No description provided for @subscriptionFeatureAssemblies.
  ///
  /// In es, this message translates to:
  /// **'Asambleas/votaciones'**
  String get subscriptionFeatureAssemblies;

  /// No description provided for @subscriptionFeatureAllProfessional.
  ///
  /// In es, this message translates to:
  /// **'Todo de Profesional'**
  String get subscriptionFeatureAllProfessional;

  /// No description provided for @subscriptionFeatureAssembliesVoting.
  ///
  /// In es, this message translates to:
  /// **'Asambleas + votaciones'**
  String get subscriptionFeatureAssembliesVoting;

  /// No description provided for @subscriptionFeaturePdfReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes PDF automáticos'**
  String get subscriptionFeaturePdfReports;

  /// No description provided for @subscriptionFeatureAccountingApi.
  ///
  /// In es, this message translates to:
  /// **'API contable (Siigo)'**
  String get subscriptionFeatureAccountingApi;

  /// No description provided for @subscriptionFeaturePrioritySupport.
  ///
  /// In es, this message translates to:
  /// **'Soporte prioritario'**
  String get subscriptionFeaturePrioritySupport;

  /// No description provided for @subscriptionAnnualDiscount.
  ///
  /// In es, this message translates to:
  /// **'20% descuento pago anual (2 meses gratis)'**
  String get subscriptionAnnualDiscount;

  /// No description provided for @subscriptionTrialActivated.
  ///
  /// In es, this message translates to:
  /// **'Trial de 30 días activado: {plan}'**
  String subscriptionTrialActivated(String plan);

  /// No description provided for @subscriptionOnlyAdminsCanActivate.
  ///
  /// In es, this message translates to:
  /// **'Solo administradores pueden activar el trial'**
  String get subscriptionOnlyAdminsCanActivate;

  /// No description provided for @subscriptionActivationError.
  ///
  /// In es, this message translates to:
  /// **'Error al activar trial: {message}'**
  String subscriptionActivationError(String message);

  /// No description provided for @subscriptionPopular.
  ///
  /// In es, this message translates to:
  /// **'POPULAR'**
  String get subscriptionPopular;

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In es, this message translates to:
  /// **'/mes'**
  String get subscriptionPerMonth;

  /// No description provided for @subscriptionTry30DaysFree.
  ///
  /// In es, this message translates to:
  /// **'Probar gratis 30 días'**
  String get subscriptionTry30DaysFree;

  /// No description provided for @adminSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración de comunidad'**
  String get adminSettingsTitle;

  /// No description provided for @adminCommunityNotFound.
  ///
  /// In es, this message translates to:
  /// **'Comunidad no encontrada'**
  String get adminCommunityNotFound;

  /// No description provided for @adminGeneralData.
  ///
  /// In es, this message translates to:
  /// **'Datos generales'**
  String get adminGeneralData;

  /// No description provided for @adminNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get adminNameLabel;

  /// No description provided for @adminNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get adminNameRequired;

  /// No description provided for @adminAddressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get adminAddressLabel;

  /// No description provided for @adminCityLabel.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get adminCityLabel;

  /// No description provided for @adminEstratoLabel.
  ///
  /// In es, this message translates to:
  /// **'Estrato'**
  String get adminEstratoLabel;

  /// No description provided for @adminEstratoOption.
  ///
  /// In es, this message translates to:
  /// **'Estrato {n}'**
  String adminEstratoOption(int n);

  /// No description provided for @adminSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get adminSaveChanges;

  /// No description provided for @adminGenericError.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String adminGenericError(String message);

  /// No description provided for @adminCodeCopied.
  ///
  /// In es, this message translates to:
  /// **'Código copiado'**
  String get adminCodeCopied;

  /// No description provided for @adminRotateCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Rotar código'**
  String get adminRotateCodeTitle;

  /// No description provided for @adminRotateCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'El código actual dejará de funcionar y se generará uno nuevo. Los residentes que aún no se hayan unido deberán pedirlo de nuevo.'**
  String get adminRotateCodeMessage;

  /// No description provided for @adminRotateAction.
  ///
  /// In es, this message translates to:
  /// **'Rotar'**
  String get adminRotateAction;

  /// No description provided for @adminNewCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'Nuevo código: {code}'**
  String adminNewCodeMessage(String code);

  /// No description provided for @adminCodeRotated.
  ///
  /// In es, this message translates to:
  /// **'Código rotado'**
  String get adminCodeRotated;

  /// No description provided for @adminRotateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo rotar: {statusCode}'**
  String adminRotateError(String statusCode);

  /// No description provided for @adminSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {message}'**
  String adminSaveError(String message);

  /// No description provided for @adminChangesSaved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get adminChangesSaved;

  /// No description provided for @adminResidentsLabel.
  ///
  /// In es, this message translates to:
  /// **'Residentes'**
  String get adminResidentsLabel;

  /// No description provided for @adminServiceLabel.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get adminServiceLabel;

  /// No description provided for @adminUnitsLabel.
  ///
  /// In es, this message translates to:
  /// **'Unidades'**
  String get adminUnitsLabel;

  /// No description provided for @adminPendingApprovalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes pendientes'**
  String get adminPendingApprovalsTitle;

  /// No description provided for @adminAllCaughtUp.
  ///
  /// In es, this message translates to:
  /// **'Todo al día'**
  String get adminAllCaughtUp;

  /// No description provided for @adminNoPendingRequests.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes pendientes'**
  String get adminNoPendingRequests;

  /// No description provided for @adminUserApproved.
  ///
  /// In es, this message translates to:
  /// **'{name} aprobado'**
  String adminUserApproved(String name);

  /// No description provided for @adminApproveError.
  ///
  /// In es, this message translates to:
  /// **'Error al aprobar: {error}'**
  String adminApproveError(String error);

  /// No description provided for @adminRequestRejected.
  ///
  /// In es, this message translates to:
  /// **'Solicitud rechazada'**
  String get adminRequestRejected;

  /// No description provided for @adminRejectError.
  ///
  /// In es, this message translates to:
  /// **'Error al rechazar: {error}'**
  String adminRejectError(String error);

  /// No description provided for @superAdminCommunityDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de comunidad'**
  String get superAdminCommunityDetailTitle;

  /// No description provided for @superAdminInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get superAdminInfoTitle;

  /// No description provided for @superAdminUnitTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo unidad'**
  String get superAdminUnitTypeLabel;

  /// No description provided for @superAdminAdminUidLabel.
  ///
  /// In es, this message translates to:
  /// **'Admin UID'**
  String get superAdminAdminUidLabel;

  /// No description provided for @superAdminUnassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get superAdminUnassigned;

  /// No description provided for @superAdminCommunityIdLabel.
  ///
  /// In es, this message translates to:
  /// **'ID comunidad'**
  String get superAdminCommunityIdLabel;

  /// No description provided for @superAdminCreatedLabel.
  ///
  /// In es, this message translates to:
  /// **'Creada'**
  String get superAdminCreatedLabel;

  /// No description provided for @superAdminSubscriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Suscripción'**
  String get superAdminSubscriptionTitle;

  /// No description provided for @superAdminNoActivePlanMessage.
  ///
  /// In es, this message translates to:
  /// **'Sin Vecindario Admin activo. El admin puede activar el trial o tú puedes activar un plan aquí.'**
  String get superAdminNoActivePlanMessage;

  /// No description provided for @superAdminPlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get superAdminPlanLabel;

  /// No description provided for @superAdminStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get superAdminStatusLabel;

  /// No description provided for @superAdminActionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get superAdminActionsTitle;

  /// No description provided for @superAdminAssignAdminAction.
  ///
  /// In es, this message translates to:
  /// **'Asignar administrador'**
  String get superAdminAssignAdminAction;

  /// No description provided for @superAdminAssignAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el UID del usuario que gestionará la comunidad'**
  String get superAdminAssignAdminSubtitle;

  /// No description provided for @superAdminActivatePlanAction.
  ///
  /// In es, this message translates to:
  /// **'Activar plan'**
  String get superAdminActivatePlanAction;

  /// No description provided for @superAdminActivatePlanSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Starter, Profesional o Enterprise (trial o activo)'**
  String get superAdminActivatePlanSubtitle;

  /// No description provided for @superAdminDeleteCommunityAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar comunidad'**
  String get superAdminDeleteCommunityAction;

  /// No description provided for @superAdminDeleteCommunitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Acción irreversible. No borra usuarios.'**
  String get superAdminDeleteCommunitySubtitle;

  /// No description provided for @superAdminAssignAdminDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar Admin — {name}'**
  String superAdminAssignAdminDialogTitle(String name);

  /// No description provided for @superAdminAssignAdminDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el UID del usuario que será administrador. Puedes encontrarlo en Firebase Auth.'**
  String get superAdminAssignAdminDialogMessage;

  /// No description provided for @superAdminUidLabel.
  ///
  /// In es, this message translates to:
  /// **'UID del usuario'**
  String get superAdminUidLabel;

  /// No description provided for @superAdminAssignAction.
  ///
  /// In es, this message translates to:
  /// **'Asignar'**
  String get superAdminAssignAction;

  /// No description provided for @superAdminAdminAssigned.
  ///
  /// In es, this message translates to:
  /// **'Admin asignado'**
  String get superAdminAdminAssigned;

  /// No description provided for @superAdminActivatePlanDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Activar Plan — {name}'**
  String superAdminActivatePlanDialogTitle(String name);

  /// No description provided for @superAdminActivateTrialAction.
  ///
  /// In es, this message translates to:
  /// **'Activar Trial'**
  String get superAdminActivateTrialAction;

  /// No description provided for @superAdminPlanActivatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Plan {plan} activado (trial 30 días gratis)'**
  String superAdminPlanActivatedMessage(String plan);

  /// No description provided for @superAdminDeleteCommunityMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro? Se eliminará el documento de \"{name}\" y su suscripción. Los usuarios NO se eliminan (quedan sin comunidad).'**
  String superAdminDeleteCommunityMessage(String name);

  /// No description provided for @superAdminCommunityDeleted.
  ///
  /// In es, this message translates to:
  /// **'Comunidad eliminada'**
  String get superAdminCommunityDeleted;

  /// No description provided for @superAdminAccessDeniedTitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso denegado'**
  String get superAdminAccessDeniedTitle;

  /// No description provided for @superAdminNoPermission.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos de Super Admin'**
  String get superAdminNoPermission;

  /// No description provided for @superAdminPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel Global'**
  String get superAdminPanelTitle;

  /// No description provided for @superAdminCreateCommunityTooltip.
  ///
  /// In es, this message translates to:
  /// **'Crear comunidad'**
  String get superAdminCreateCommunityTooltip;

  /// No description provided for @superAdminLogoutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres salir?'**
  String get superAdminLogoutConfirmMessage;

  /// No description provided for @superAdminExitAction.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get superAdminExitAction;

  /// No description provided for @superAdminNoCommunitiesMessage.
  ///
  /// In es, this message translates to:
  /// **'No hay comunidades registradas'**
  String get superAdminNoCommunitiesMessage;

  /// No description provided for @superAdminCreateFirstCommunity.
  ///
  /// In es, this message translates to:
  /// **'Crear primera comunidad'**
  String get superAdminCreateFirstCommunity;

  /// No description provided for @superAdminCommunitiesCountTitle.
  ///
  /// In es, this message translates to:
  /// **'COMUNIDADES ({count})'**
  String superAdminCommunitiesCountTitle(int count);

  /// No description provided for @superAdminGlobalStatsCommunities.
  ///
  /// In es, this message translates to:
  /// **'Conjuntos'**
  String get superAdminGlobalStatsCommunities;

  /// No description provided for @superAdminSubscriptionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Suscripciones'**
  String get superAdminSubscriptionsLabel;

  /// No description provided for @superAdminMembersCount.
  ///
  /// In es, this message translates to:
  /// **'{count} residentes'**
  String superAdminMembersCount(int count);

  /// No description provided for @superAdminAssignAdminButton.
  ///
  /// In es, this message translates to:
  /// **'Asignar Admin'**
  String get superAdminAssignAdminButton;

  /// No description provided for @superAdminPlanButton.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get superAdminPlanButton;

  /// No description provided for @superAdminPanelAssignAdminMessage.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el UID del usuario que será administrador del conjunto. Puedes encontrarlo en Firebase Auth.'**
  String get superAdminPanelAssignAdminMessage;

  /// No description provided for @superAdminNewCommunityTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva comunidad'**
  String get superAdminNewCommunityTitle;

  /// No description provided for @superAdminCreateCommunityHint.
  ///
  /// In es, this message translates to:
  /// **'Después de crear la comunidad, se generará un código de invitación único para compartir con el administrador.'**
  String get superAdminCreateCommunityHint;

  /// No description provided for @superAdminBasicInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información básica'**
  String get superAdminBasicInfoTitle;

  /// No description provided for @superAdminCommunityNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del conjunto'**
  String get superAdminCommunityNameLabel;

  /// No description provided for @superAdminCommunityNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Pinares de Granada'**
  String get superAdminCommunityNameHint;

  /// No description provided for @superAdminAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Carrera 15 # 80-45'**
  String get superAdminAddressHint;

  /// No description provided for @superAdminAddressRequired.
  ///
  /// In es, this message translates to:
  /// **'La dirección es obligatoria'**
  String get superAdminAddressRequired;

  /// No description provided for @superAdminCityHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Bogotá'**
  String get superAdminCityHint;

  /// No description provided for @superAdminCityRequired.
  ///
  /// In es, this message translates to:
  /// **'La ciudad es obligatoria'**
  String get superAdminCityRequired;

  /// No description provided for @superAdminCharacteristicsTitle.
  ///
  /// In es, this message translates to:
  /// **'Características'**
  String get superAdminCharacteristicsTitle;

  /// No description provided for @superAdminEstratoSocioLabel.
  ///
  /// In es, this message translates to:
  /// **'Estrato socioeconómico'**
  String get superAdminEstratoSocioLabel;

  /// No description provided for @superAdminUnitTypeFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de unidad'**
  String get superAdminUnitTypeFieldLabel;

  /// No description provided for @superAdminCreatingAction.
  ///
  /// In es, this message translates to:
  /// **'Creando...'**
  String get superAdminCreatingAction;

  /// No description provided for @superAdminCreateCommunityAction.
  ///
  /// In es, this message translates to:
  /// **'Crear comunidad'**
  String get superAdminCreateCommunityAction;

  /// No description provided for @superAdminCommunityCreatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Comunidad \"{name}\" creada. Código: {code}'**
  String superAdminCommunityCreatedMessage(String name, String code);

  /// No description provided for @superAdminCreateError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear: {error}'**
  String superAdminCreateError(String error);

  /// No description provided for @profileAccountSection.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get profileAccountSection;

  /// No description provided for @profileEditProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEditProfile;

  /// No description provided for @profilePlatformSection.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get profilePlatformSection;

  /// No description provided for @profileSuperAdminPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Super Admin Panel'**
  String get profileSuperAdminPanelTitle;

  /// No description provided for @profileManageCommunitiesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar comunidades y clientes'**
  String get profileManageCommunitiesSubtitle;

  /// No description provided for @profileAdminSection.
  ///
  /// In es, this message translates to:
  /// **'Administración'**
  String get profileAdminSection;

  /// No description provided for @profileCommunityAdminTitle.
  ///
  /// In es, this message translates to:
  /// **'Administración del conjunto'**
  String get profileCommunityAdminTitle;

  /// No description provided for @profileCommunityAdminSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobaciones, circulares, multas, finanzas, PQRS y más'**
  String get profileCommunityAdminSubtitle;

  /// No description provided for @profileMyCommunitySection.
  ///
  /// In es, this message translates to:
  /// **'Mi conjunto'**
  String get profileMyCommunitySection;

  /// No description provided for @profileCircularsTitle.
  ///
  /// In es, this message translates to:
  /// **'Circulares'**
  String get profileCircularsTitle;

  /// No description provided for @profileReserveZoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Reservar zona'**
  String get profileReserveZoneTitle;

  /// No description provided for @profilePqrsTitle.
  ///
  /// In es, this message translates to:
  /// **'PQRS'**
  String get profilePqrsTitle;

  /// No description provided for @profileMyFinesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis multas'**
  String get profileMyFinesTitle;

  /// No description provided for @profileAccountStatementTitle.
  ///
  /// In es, this message translates to:
  /// **'Estado de cuenta'**
  String get profileAccountStatementTitle;

  /// No description provided for @profileAssembliesTitle.
  ///
  /// In es, this message translates to:
  /// **'Asambleas'**
  String get profileAssembliesTitle;

  /// No description provided for @profileManualTitle.
  ///
  /// In es, this message translates to:
  /// **'Manual de convivencia'**
  String get profileManualTitle;

  /// No description provided for @profileMyStoreSection.
  ///
  /// In es, this message translates to:
  /// **'Mi Tienda'**
  String get profileMyStoreSection;

  /// No description provided for @profileStorePanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de tienda'**
  String get profileStorePanelTitle;

  /// No description provided for @profileManageOrdersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar pedidos y catálogo'**
  String get profileManageOrdersSubtitle;

  /// No description provided for @profileConfigSection.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get profileConfigSection;

  /// No description provided for @profileNotificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get profileNotificationsTitle;

  /// No description provided for @profilePrivacySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Datos, derechos y eliminación de cuenta'**
  String get profilePrivacySubtitle;

  /// No description provided for @profileAppearanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get profileAppearanceTitle;

  /// No description provided for @profileThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get profileThemeDark;

  /// No description provided for @profileThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Automático (sistema)'**
  String get profileThemeSystem;

  /// No description provided for @profileLegalSection.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get profileLegalSection;

  /// No description provided for @profileLogoutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get profileLogoutConfirmMessage;

  /// No description provided for @profilePostsLabel.
  ///
  /// In es, this message translates to:
  /// **'Posts'**
  String get profilePostsLabel;

  /// No description provided for @profileOrdersLabel.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get profileOrdersLabel;

  /// No description provided for @profileMemberSinceLabel.
  ///
  /// In es, this message translates to:
  /// **'Miembro desde'**
  String get profileMemberSinceLabel;

  /// No description provided for @profileEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEditTitle;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get profileUpdated;

  /// No description provided for @profileStorageUnauthorized.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos para subir fotos'**
  String get profileStorageUnauthorized;

  /// No description provided for @profileStorageQuotaExceeded.
  ///
  /// In es, this message translates to:
  /// **'La foto es demasiado grande (máx 5 MB)'**
  String get profileStorageQuotaExceeded;

  /// No description provided for @profileStorageRetryLimit.
  ///
  /// In es, this message translates to:
  /// **'Red inestable, intenta de nuevo'**
  String get profileStorageRetryLimit;

  /// No description provided for @profileUploadCanceled.
  ///
  /// In es, this message translates to:
  /// **'Subida cancelada'**
  String get profileUploadCanceled;

  /// No description provided for @profilePermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos. ¿Sesión expirada?'**
  String get profilePermissionDenied;

  /// No description provided for @profileNoConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Verifica tu internet e intenta de nuevo'**
  String get profileNoConnection;

  /// No description provided for @profileSaveErrorDetail.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {detail}'**
  String profileSaveErrorDetail(String detail);

  /// No description provided for @profileUnexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado: {error}'**
  String profileUnexpectedError(String error);

  /// No description provided for @profileEmailHelperText.
  ///
  /// In es, this message translates to:
  /// **'No se puede modificar'**
  String get profileEmailHelperText;

  /// No description provided for @profileLaw1581Title.
  ///
  /// In es, this message translates to:
  /// **'Ley 1581 de 2012'**
  String get profileLaw1581Title;

  /// No description provided for @profileLaw1581Description.
  ///
  /// In es, this message translates to:
  /// **'Tienes derecho a conocer, actualizar, rectificar y suprimir tus datos personales.'**
  String get profileLaw1581Description;

  /// No description provided for @profileMyDataSection.
  ///
  /// In es, this message translates to:
  /// **'Mis Datos'**
  String get profileMyDataSection;

  /// No description provided for @profileDownloadDataSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recibe un archivo con toda tu información'**
  String get profileDownloadDataSubtitle;

  /// No description provided for @profileDataExportRequested.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada. Recibirás un email en máximo 48 horas.'**
  String get profileDataExportRequested;

  /// No description provided for @profileEditPersonalInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar información personal'**
  String get profileEditPersonalInfoTitle;

  /// No description provided for @profileEditPersonalInfoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Nombre, teléfono, foto de perfil'**
  String get profileEditPersonalInfoSubtitle;

  /// No description provided for @profileConsentsSection.
  ///
  /// In es, this message translates to:
  /// **'Consentimientos'**
  String get profileConsentsSection;

  /// No description provided for @profilePushNotificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones push'**
  String get profilePushNotificationsTitle;

  /// No description provided for @profileEmailNewsTitle.
  ///
  /// In es, this message translates to:
  /// **'Email de novedades'**
  String get profileEmailNewsTitle;

  /// No description provided for @profileAnalyticsTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de uso (analytics)'**
  String get profileAnalyticsTitle;

  /// No description provided for @profilePrivacyPolicySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento de datos personales'**
  String get profilePrivacyPolicySubtitle;

  /// No description provided for @profileTermsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Condiciones del servicio'**
  String get profileTermsSubtitle;

  /// No description provided for @profileDangerZoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Zona de peligro'**
  String get profileDangerZoneTitle;

  /// No description provided for @profileIrreversibleAction.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible'**
  String get profileIrreversibleAction;

  /// No description provided for @profileCannotRecoverAfter15Days.
  ///
  /// In es, this message translates to:
  /// **'Después de 15 días no podrás recuperar tu cuenta.'**
  String get profileCannotRecoverAfter15Days;

  /// No description provided for @profileWillBeDeletedLabel.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará:'**
  String get profileWillBeDeletedLabel;

  /// No description provided for @profileProfileAndPhotoItem.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil y foto'**
  String get profileProfileAndPhotoItem;

  /// No description provided for @profileVerificationDocsItem.
  ///
  /// In es, this message translates to:
  /// **'Documentos de verificación'**
  String get profileVerificationDocsItem;

  /// No description provided for @profileTokensSessionsItem.
  ///
  /// In es, this message translates to:
  /// **'Tokens y sesiones'**
  String get profileTokensSessionsItem;

  /// No description provided for @profileWillBeAnonymizedLabel.
  ///
  /// In es, this message translates to:
  /// **'Se anonimizará:'**
  String get profileWillBeAnonymizedLabel;

  /// No description provided for @profilePostsAnonymizedItem.
  ///
  /// In es, this message translates to:
  /// **'Posts → \"Usuario eliminado\"'**
  String get profilePostsAnonymizedItem;

  /// No description provided for @profileReviewsAnonymizedItem.
  ///
  /// In es, this message translates to:
  /// **'Reseñas → \"Usuario eliminado\"'**
  String get profileReviewsAnonymizedItem;

  /// No description provided for @profileOrdersAnonymizedItem.
  ///
  /// In es, this message translates to:
  /// **'Pedidos → uid → null'**
  String get profileOrdersAnonymizedItem;

  /// No description provided for @profileDeleteAccountButtonLabel.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta (15 días de gracia)'**
  String get profileDeleteAccountButtonLabel;

  /// No description provided for @profileDeleteAccountDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get profileDeleteAccountDialogTitle;

  /// No description provided for @profileDeleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro? Después de 15 días esta acción no se puede deshacer.'**
  String get profileDeleteConfirmMessage;

  /// No description provided for @profileConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get profileConfirmPasswordLabel;

  /// No description provided for @profileEnterPasswordError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get profileEnterPasswordError;

  /// No description provided for @profileAccountDeletionScheduled.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta será eliminada en 15 días. Puedes reactivarla iniciando sesión.'**
  String get profileAccountDeletionScheduled;

  /// No description provided for @profileWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta'**
  String get profileWrongPassword;

  /// No description provided for @profileAuthError.
  ///
  /// In es, this message translates to:
  /// **'Error de autenticación'**
  String get profileAuthError;

  /// No description provided for @profileUnexpectedErrorShort.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado'**
  String get profileUnexpectedErrorShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
