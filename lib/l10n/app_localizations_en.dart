// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vecindario';

  @override
  String get appSlogan => 'Your community, connected';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get logout => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Full name';

  @override
  String get phone => 'Phone';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get joinCommunity => 'Join community';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get tower => 'Tower / Block';

  @override
  String get apartment => 'Apartment';

  @override
  String get requestJoin => 'Request to join';

  @override
  String get pendingApproval => 'Your request is under review';

  @override
  String get news => 'News';

  @override
  String get neighbors => 'Neighbors';

  @override
  String get services => 'Services';

  @override
  String get profile => 'Profile';

  @override
  String get publish => 'Publish';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get noResults => 'No results';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get search => 'Search';

  @override
  String get allCategories => 'All';

  @override
  String get contactWhatsApp => 'Contact via WhatsApp';

  @override
  String get privacyTitle => 'My Privacy';

  @override
  String get downloadData => 'Download my data';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authSignUpAction => 'Sign up';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get sortTooltip => 'Sort';

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
    return 'Unexpected error: $message';
  }

  @override
  String get savingEllipsis => 'Saving...';

  @override
  String get errorCommunityNotAvailable => 'Community not available';

  @override
  String get errorUserOrCommunityUnavailable => 'User or community unavailable';

  @override
  String get formBasicInfo => 'Basic information';

  @override
  String get formDescriptionLabel => 'Description';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authForgotPasswordDesc =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get authForgotPasswordSent => 'A recovery link was sent to your email';

  @override
  String get authSendLink => 'Send link';

  @override
  String get authCheckEmail => 'Check your email!';

  @override
  String authRecoveryLinkSentTo(String email) {
    return 'We sent a recovery link to $email';
  }

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authJoinCommunityTitle => 'Join your community';

  @override
  String get authJoinCommunityDesc =>
      'Enter the invitation code given by your building\'s administration.';

  @override
  String get authEnterFullCode => 'Enter the full code';

  @override
  String get authFillTowerAndApartment => 'Fill in tower and apartment';

  @override
  String get authInvalidInviteCode => 'Invalid invitation code';

  @override
  String get authJoinCommunityError => 'Error joining community';

  @override
  String get authVerifyPhoneTitle => 'Verify phone';

  @override
  String get authVerificationCodeTitle => 'Verification code';

  @override
  String authSmsCodeSentTo(String phone) {
    return 'We sent an SMS code to\n+57 $phone';
  }

  @override
  String get authVerify => 'Verify';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authVerifyLater => 'Verify later';

  @override
  String get authLegalConsentPrefix => 'By signing up you accept our ';

  @override
  String get authLegalConsentSuffix =>
      ' and you authorize the processing of your personal data under Colombian Law 1581 of 2012.';

  @override
  String get externalRecommendedNotice =>
      'These services are recommended by neighbors — they are not residents of the building.';

  @override
  String get externalNoServicesYet => 'No services yet';

  @override
  String get externalNoServicesSubtitle =>
      'Recommend a trusted professional to your community';

  @override
  String get externalErrorLoading => 'Error loading services';

  @override
  String get externalRecommendCta => 'Recommend';

  @override
  String externalRecommendedByName(String name) {
    return 'Rec. by $name';
  }

  @override
  String externalCallWithPhone(String phone) {
    return 'Call · $phone';
  }

  @override
  String get externalCompleteNameDesc => 'Fill in name and description';

  @override
  String get externalNoUserOrCommunity => 'No user or community';

  @override
  String get externalServiceRecommended => 'Service recommended';

  @override
  String get externalErrorRecommending => 'Error recommending service';

  @override
  String get externalRecommendTitle => 'Recommend Service';

  @override
  String get externalRecommendDesc =>
      'Recommend an external service to your community';

  @override
  String get externalServiceNameLabel => 'Service name *';

  @override
  String get externalDescriptionLabel => 'Description *';

  @override
  String get externalDescriptionHint => 'What this service offers';

  @override
  String get externalWebsiteLabel => 'Website';

  @override
  String get externalWebsiteHint => 'https://example.com';

  @override
  String get externalSendRecommendation => 'Send Recommendation';

  @override
  String get externalErrorRecommendingShort => 'Error recommending';

  @override
  String get externalProfessionalNameLabel => 'Professional or company name';

  @override
  String get externalCategoryLabel => 'Category';

  @override
  String get externalDescribeExperienceLabel =>
      'Describe your experience with this service';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkAll => 'Mark all';

  @override
  String get notifEmpty => 'No notifications';

  @override
  String get notifEmptySubtitle => 'Your community\'s updates will appear here';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPage1Title => 'Your community, connected';

  @override
  String get onboardingPage1Desc =>
      'News, alerts and announcements from your building in one place. Never miss anything in the chat.';

  @override
  String get onboardingPage2Title => 'Buy from your neighbors';

  @override
  String get onboardingPage2Desc =>
      'Discover businesses and services in your community. Support those who live next door.';

  @override
  String get onboardingPage3Title => 'Trusted services';

  @override
  String get onboardingPage3Desc =>
      'Directory of professionals recommended by your neighbors. Electricians, plumbers and more.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get feedWriteSomething => 'Write something to publish';

  @override
  String get feedAddAtLeast2Options => 'Add at least 2 options';

  @override
  String get feedPublished => 'Published';

  @override
  String get feedAlertHint => 'What do you want to alert your community about?';

  @override
  String get feedShareHint => 'What do you want to share with your community?';

  @override
  String get feedPollOptionsTitle => 'Poll options';

  @override
  String feedPollOptionHint(int n) {
    return 'Option $n';
  }

  @override
  String get feedAddOption => 'Add option';

  @override
  String get feedPostTitle => 'Post';

  @override
  String get feedPostNotFound => 'Post not found';

  @override
  String get feedPinned => 'Pinned';

  @override
  String feedLikesCount(int count) {
    return '$count Likes';
  }

  @override
  String feedCommentsCount(int count) {
    return '$count comments';
  }

  @override
  String get feedLikeAction => 'Like';

  @override
  String get feedCommentAction => 'Comment';

  @override
  String get feedCouldNotLike => 'Couldn\'t register your like';

  @override
  String get feedPollTitle => 'Poll';

  @override
  String get feedAlertBadge => 'ALERT';

  @override
  String get feedCouldNotPin => 'Couldn\'t pin the post';

  @override
  String get feedUnpin => 'Unpin';

  @override
  String get feedPinToTop => 'Pin to top';

  @override
  String get feedReport => 'Report';

  @override
  String get feedReportDialogTitle => 'Report post';

  @override
  String get feedReportReasonInappropriate => 'Inappropriate content';

  @override
  String get feedReportReasonSpam => 'Spam or advertising';

  @override
  String get feedReportReasonFalseInfo => 'False information';

  @override
  String get feedReportReasonHarassment => 'Harassment or intimidation';

  @override
  String get feedReportReasonOther => 'Other';

  @override
  String get feedReportSent => 'Report sent';

  @override
  String get feedCouldNotSendReport => 'Couldn\'t send the report';

  @override
  String get serviceFillAllFields => 'Fill in all fields';

  @override
  String get serviceNoUserOrCommunity => 'No user or community';

  @override
  String get serviceCreated => 'Service created';

  @override
  String get serviceCreateError => 'Error creating service';

  @override
  String get serviceOfferTitle => 'Offer Service';

  @override
  String get serviceCategoryLabel => 'Category';

  @override
  String get serviceTitleLabel => 'Service title';

  @override
  String get serviceDescriptionLabel => 'Description';

  @override
  String get servicePriceLabel => 'Price (COP) - Optional';

  @override
  String get servicePublishButton => 'Publish Service';

  @override
  String get serviceDetailTitle => 'Service Detail';

  @override
  String get serviceNotFound => 'Service not found';

  @override
  String serviceOrdersCount(int count) {
    return '$count orders';
  }

  @override
  String get servicePriceHeading => 'Price';

  @override
  String get serviceProviderLabel => 'Service provider';

  @override
  String get serviceSearchHint => 'Search service...';

  @override
  String get serviceScreenTitle => 'Neighborhood Services';

  @override
  String get serviceSortRecent => 'Most recent';

  @override
  String get serviceSortRating => 'Highest rated';

  @override
  String get serviceSortPopular => 'Most popular';

  @override
  String get serviceEmptyTitle => 'No services yet';

  @override
  String get serviceEmptySubtitle =>
      'Offer your products or services to your community';

  @override
  String get serviceLoadError => 'Error loading services';

  @override
  String get serviceOfferFab => 'Offer';

  @override
  String get storeMyOrdersTitle => 'My Orders';

  @override
  String get storeNoOrdersTitle => 'No orders';

  @override
  String get storeNoOrdersSubtitle =>
      'Your orders to neighborhood stores will appear here';

  @override
  String get storeLoadOrdersError => 'Error loading orders';

  @override
  String get storeOrderTrackingTitle => 'Order Status';

  @override
  String get storeOrderNotFound => 'Order not found';

  @override
  String storeOrderNumber(String code) {
    return 'Order #$code';
  }

  @override
  String get storeOrderCancelledMessage => 'This order was cancelled';

  @override
  String get storeOrderSummaryLabel => 'Summary';

  @override
  String get storeServiceFeeLabel => 'Service fee';

  @override
  String get storeTotalLabel => 'Total';

  @override
  String get storeRateOrderButton => 'Rate order';

  @override
  String get storeSelectRatingError => 'Select a rating';

  @override
  String get storeRatingSubmitted => 'Rating submitted';

  @override
  String get storeRatingSubmitError => 'Error submitting rating';

  @override
  String storeRateOrderQuestion(String storeName) {
    return 'How was your order at $storeName?';
  }

  @override
  String get storeCommentHint => 'Optional comment...';

  @override
  String get storeSubmitRatingButton => 'Submit rating';

  @override
  String get storeRatingVeryBad => 'Very bad';

  @override
  String get storeRatingBad => 'Bad';

  @override
  String get storeRatingRegular => 'Regular';

  @override
  String get storeRatingGood => 'Good';

  @override
  String get storeRatingExcellent => 'Excellent';

  @override
  String get storeOrderCreated => 'Order created';

  @override
  String get storeOrderCreateError => 'Error creating order';

  @override
  String get storeDefaultTitle => 'Store';

  @override
  String get storeNoItemsMessage => 'This store has no products yet';

  @override
  String get storePaymentMethodLabel => 'Payment method';

  @override
  String get storeCashOnDeliveryTitle => 'Cash on delivery';

  @override
  String get storeCashOnDeliverySubtitle => 'Pay when you receive your order';

  @override
  String get storeOnlinePaymentTitle => 'Online payment';

  @override
  String get storeOnlinePaymentSubtitle => 'PSE, card, or Nequi via Wompi';

  @override
  String get storePayOnlineLabel => 'Pay online';

  @override
  String get storeOrderCashLabel => 'Order (cash on delivery)';

  @override
  String get storePanelTitle => 'My Store';

  @override
  String get storeCreatePrompt =>
      'Create your store to start selling products to your community';

  @override
  String get storeCreateMyStoreButton => 'Create my store';

  @override
  String get storeCreateDialogTitle => 'Create store';

  @override
  String get storeNameLabel => 'Store name';

  @override
  String get storeDeliveryTimeLabel => 'Delivery time';

  @override
  String get storeMinOrderLabel => 'Minimum order';

  @override
  String get storeNoCommunityAssigned => 'No community assigned';

  @override
  String get storeCreated => 'Store created';

  @override
  String get storePanelNoOrdersTitle => 'No orders';

  @override
  String get storePanelNoOrdersSubtitle =>
      'Your customers\' orders will appear here';

  @override
  String get storePendingLabel => 'Pending';

  @override
  String get storeActiveLabel => 'Active';

  @override
  String get storeTodayLabel => 'Today';

  @override
  String storeNewOrdersCount(int count) {
    return 'New orders ($count)';
  }

  @override
  String storeInProgressCount(int count) {
    return 'In progress ($count)';
  }

  @override
  String get storeCompletedLabel => 'Completed';

  @override
  String get storeNewItemFab => 'New';

  @override
  String get storeNoItemsTitle => 'No products';

  @override
  String get storeNoItemsSubtitle => 'Add your first product with the + button';

  @override
  String get storeDeleteProductTitle => 'Delete product';

  @override
  String storeDeleteProductConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get storeHideLabel => 'Hide';

  @override
  String get storeActivateLabel => 'Activate';

  @override
  String get storeNewProductTitle => 'New product';

  @override
  String get storeEditProductTitle => 'Edit product';

  @override
  String get storeItemNameLabel => 'Name';

  @override
  String get storeItemPriceLabel => 'Price (COP)';

  @override
  String get storeProductCreated => 'Product created';

  @override
  String get storeProductUpdated => 'Product updated';

  @override
  String get storeStatusLabel => 'Status';

  @override
  String get storeActiveStatus => 'Active';

  @override
  String get storeInactiveStatus => 'Inactive';

  @override
  String get storeRatingLabel => 'Rating';

  @override
  String get storeCompletedOrdersLabel => 'Completed orders';

  @override
  String get storeEditInfoButton => 'Edit information';

  @override
  String get storePauseStoreButton => 'Pause store';

  @override
  String get storeReactivateStoreButton => 'Reactivate store';

  @override
  String get storeEditDialogTitle => 'Edit store';

  @override
  String get storeUpdated => 'Updated';

  @override
  String get storeRejectButton => 'Reject';

  @override
  String get storeMarkOnWayButton => 'Mark on the way';

  @override
  String get storeMarkDeliveredButton => 'Mark delivered';

  @override
  String get storeScreenTitle => 'Neighborhood Stores';

  @override
  String get storeBannerTitle => 'Order without leaving home';

  @override
  String get storeBannerSubtitle => 'Direct delivery to your door';

  @override
  String get storeEmptyTitle => 'No stores yet';

  @override
  String get storeEmptySubtitle => 'Your neighborhood stores will appear here';

  @override
  String get storeLoadError => 'Error loading stores';

  @override
  String get amenityScreenTitle => 'Amenities';

  @override
  String get amenityNewButton => 'New';

  @override
  String get amenityEmptyTitle => 'No amenities set up';

  @override
  String get amenityEmptySubtitle =>
      'Your community\'s amenities will appear here';

  @override
  String amenityCapacityLabel(int count) {
    return '$count people';
  }

  @override
  String amenityDepositLabel(String amount) {
    return 'Refundable deposit: $amount';
  }

  @override
  String amenityCapacityColon(int count) {
    return 'Capacity: $count people';
  }

  @override
  String amenityRateColon(String amount) {
    return 'Rate: $amount';
  }

  @override
  String amenityDepositColon(String amount) {
    return 'Deposit: $amount (refundable)';
  }

  @override
  String get amenityAvailable => 'Available';

  @override
  String get amenityReserved => 'Reserved';

  @override
  String get amenitySelected => 'Selected';

  @override
  String amenityScheduleColon(String hours) {
    return 'Schedule: $hours';
  }

  @override
  String get amenityRentalPlusDeposit => 'Rental + deposit';

  @override
  String get amenityPayAndBook => 'Pay and Book';

  @override
  String get amenityBookingCreated => 'Booking created';

  @override
  String get amenityCreateTitle => 'New amenity';

  @override
  String get amenityCreated => 'Amenity created';

  @override
  String get amenityNameLabel => 'Name';

  @override
  String get amenityNameHint => 'E.g: Social hall, BBQ, Pool';

  @override
  String get amenityCapacityFeesSection => 'Capacity and fees';

  @override
  String get amenityCapacityFieldLabel => 'Capacity (people)';

  @override
  String get amenityHourlyRateLabel => 'Hourly rate (COP)';

  @override
  String get amenityDepositOptionalLabel => 'Refundable deposit (optional)';

  @override
  String get amenityDepositHelper => 'Held and refunded if there is no damage';

  @override
  String get amenityScheduleRulesSection => 'Schedule and rules';

  @override
  String get amenityHoursLabel => 'Schedule';

  @override
  String get amenityRulesLabel => 'Rules (optional)';

  @override
  String get amenityRulesHint => 'E.g: Max capacity 15, no music after 10pm';

  @override
  String get amenityCreateSubmit => 'Create amenity';

  @override
  String get assemblyScreenTitle => 'Assemblies';

  @override
  String get assemblyConvene => 'Convene';

  @override
  String get assemblyEmptyTitle => 'No assemblies';

  @override
  String get assemblyEmptySubtitle => 'Assembly notices will appear here';

  @override
  String get assemblyLive => 'LIVE';

  @override
  String assemblyAgendaCount(int count) {
    return 'Agenda: $count items';
  }

  @override
  String assemblyAttendeesRegistered(int count) {
    return '$count attendees registered';
  }

  @override
  String get assemblyVoteRegistered => 'Vote registered';

  @override
  String assemblyTotalVotes(int count) {
    return '$count votes';
  }

  @override
  String get assemblyAgendaRequired => 'Add at least one agenda item';

  @override
  String get assemblyConvened => 'Assembly convened';

  @override
  String get assemblyConveneTitle => 'Convene assembly';

  @override
  String get assemblyTitleLabel => 'Title';

  @override
  String get assemblyTitleHint => 'E.g: 2026 Ordinary Assembly';

  @override
  String get assemblyLocationLabel => 'Location (optional)';

  @override
  String get assemblyLocationHint => 'E.g: Social hall';

  @override
  String get assemblyVirtualLinkLabel => 'Virtual link (optional)';

  @override
  String get assemblyAgendaTitle => 'Agenda';

  @override
  String get assemblyAddAgendaItem => 'Add';

  @override
  String get assemblyAgendaItemHint => 'Agenda item';

  @override
  String get assemblyConveneHelper =>
      'When you convene, residents will be notified and can confirm attendance. Voting can start on the day of the assembly.';

  @override
  String get circularScreenTitle => 'Circulars';

  @override
  String get circularEmptyTitle => 'No circulars';

  @override
  String get circularEmptySubtitle => 'Official notices will appear here';

  @override
  String circularAttachmentsCount(int count) {
    return '$count attachment(s)';
  }

  @override
  String circularReadPercentage(int pct) {
    return '$pct% read';
  }

  @override
  String get circularSignAck => 'Sign acknowledgment';

  @override
  String get circularTitleRequired => 'Enter a title';

  @override
  String get circularBodyRequired => 'Enter the content';

  @override
  String get circularPublished => 'Circular published';

  @override
  String get circularCreateTitle => 'New Circular';

  @override
  String get circularPriority => 'Priority';

  @override
  String get circularTitleLabel => 'Circular title';

  @override
  String get circularTitleHint => 'E.g: Scheduled water outage';

  @override
  String get circularContentLabel => 'Content';

  @override
  String get circularContentHint => 'Write the full notice...';

  @override
  String get circularRequiresAck => 'Requires acknowledgment';

  @override
  String get circularRequiresAckHelper =>
      'Residents will need to confirm they read it';

  @override
  String get financeStatementTitle => 'My Account Statement';

  @override
  String get financeStatementUnavailable => 'No account statement available';

  @override
  String get financeCurrentBalance => 'Current balance';

  @override
  String get financeUpToDate => 'You are up to date';

  @override
  String get financePendingBalance => 'You have a pending balance';

  @override
  String get financePayFee => 'Pay fee';

  @override
  String get financeHistory => 'History';

  @override
  String get financeNoMovements => 'No movements recorded';

  @override
  String get financePaid => 'Paid';

  @override
  String get financePending => 'Pending';

  @override
  String get financeEntryRegistered => 'Entry registered';

  @override
  String get financeNewEntryTitle => 'New entry';

  @override
  String get financeIncome => 'Income';

  @override
  String get financeExpense => 'Expense';

  @override
  String get financeCategoryLabel => 'Category';

  @override
  String get financeCategoryHint => 'E.g: Admin fee, Maintenance';

  @override
  String get financeAmountLabel => 'Amount (COP)';

  @override
  String get financeDateLabel => 'Date';

  @override
  String get financeRegister => 'Register';

  @override
  String get financeDashboardTitle => 'Financial Dashboard';

  @override
  String get financeExportPdf => 'Export PDF';

  @override
  String get financeGeneratingReport => 'Generating PDF report...';

  @override
  String get financeBalance => 'Balance';

  @override
  String get financeBudgetVsExecution => 'Budget vs. Execution';

  @override
  String get financeExecution => 'Execution';

  @override
  String get financeBudget => 'Budget';

  @override
  String get financeExecuted => 'Executed';

  @override
  String get financeConfigureBudgets =>
      'Set up budgets to compare with execution';

  @override
  String get financePortfolio => 'Portfolio';

  @override
  String get financeNoStatements => 'No account statements loaded';

  @override
  String get financeCollectionRate => 'Collection rate';

  @override
  String get financeOverdueBalance => 'Overdue balance';

  @override
  String get financeMovements => 'Movements';

  @override
  String get financeRegisterExpensesForChart =>
      'Record expenses by category to see the chart';

  @override
  String get financePayPendingFee => 'Pay pending fee';

  @override
  String get fineManagementTitle => 'Fine Management';

  @override
  String get fineMyTitle => 'My Fines';

  @override
  String get fineEmptyAdminTitle => 'No fines recorded';

  @override
  String get fineEmptyResidentTitle => 'No fines';

  @override
  String get fineEmptyAdminSubtitle => 'Fines you record will appear here';

  @override
  String get fineEmptyResidentSubtitle => 'You have no pending fines';

  @override
  String fineUnitLabel(String unit) {
    return 'Unit $unit';
  }

  @override
  String get fineResidentDefense => 'Resident\'s defense';

  @override
  String fineDaysLeftForDefense(int days) {
    return '⏱ $days days left to submit a defense';
  }

  @override
  String get fineSubmitDefense => 'Submit defense';

  @override
  String get fineConfirm => 'Confirm fine';

  @override
  String get fineVoid => 'Void';

  @override
  String get fineDefenseHint => 'Write your version of events...';

  @override
  String get fineDefenseSent => 'Defense submitted';

  @override
  String get fineSend => 'Send';

  @override
  String get fineUnitRequired => 'Enter the unit (e.g: T2-801)';

  @override
  String get fineReasonRequired => 'Describe the reason';

  @override
  String get fineAmountRequired => 'Enter a valid amount';

  @override
  String get fineRegistered => 'Fine recorded';

  @override
  String get fineCreateTitle => 'Record Fine';

  @override
  String get fineUnitFieldLabel => 'Unit / Apartment';

  @override
  String get fineReasonLabel => 'Reason for the fine';

  @override
  String get fineReasonHint => 'Describe the infraction...';

  @override
  String get fineManualArticleLabel => 'Manual article (optional)';

  @override
  String get fineDefenseDeadline => 'Defense deadline';

  @override
  String fineDaysCount(int days) {
    return '$days days';
  }

  @override
  String get fineNotifyInfo =>
      'The resident will be notified and will have the stated deadline to submit a defense.';

  @override
  String get fineDetailTitle => 'Fine Detail';

  @override
  String get fineNotFound => 'Fine not found';

  @override
  String fineNumber(String id) {
    return 'Fine #$id';
  }

  @override
  String get fineReasonTitle => 'Reason';

  @override
  String get fineManualArticleTitle => 'Manual article';

  @override
  String get fineEvidence => 'Evidence';

  @override
  String get fineDefense => 'Defense';

  @override
  String fineDaysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get fineDefenseFieldHint => 'Write your defense here...';

  @override
  String get fineSendDefense => 'Submit defense';

  @override
  String get finePayFine => 'Pay fine';

  @override
  String get fineWriteDefense => 'Write your defense';

  @override
  String fineConfirmMessage(int amount) {
    return 'Confirm the \$$amount fine?';
  }

  @override
  String get fineVoidTitle => 'Void fine';

  @override
  String get fineVoidMessage => 'Are you sure you want to void this fine?';

  @override
  String get manualScreenTitle => 'Community Guidelines';

  @override
  String get manualSearchHint => 'Search the manual...';

  @override
  String manualLinkedFines(int count) {
    return '$count linked fines';
  }

  @override
  String get pqrsScreenTitle => 'PQRS';

  @override
  String get pqrsEmptyAdminTitle => 'No PQRS';

  @override
  String get pqrsEmptyResidentTitle => 'No requests';

  @override
  String get pqrsEmptyAdminSubtitle => 'Resident requests will appear here';

  @override
  String get pqrsEmptyResidentSubtitle =>
      'Send petitions, complaints or suggestions';

  @override
  String get pqrsOpen => 'Open';

  @override
  String get pqrsInProgress => 'In progress';

  @override
  String get pqrsResolved => 'Resolved';

  @override
  String pqrsResidentUnit(String name, String unit) {
    return '$name · $unit';
  }

  @override
  String get pqrsAdminResponse => 'Response from administration';

  @override
  String get pqrsSlaOverdue => 'SLA overdue';

  @override
  String get pqrsRespond => 'Respond';

  @override
  String get pqrsRespondTitle => 'Respond to PQRS';

  @override
  String get pqrsResponseHint => 'Write the response...';

  @override
  String get pqrsResponseSent => 'Response sent';

  @override
  String get pqrsDescribeRequest => 'Describe your request';

  @override
  String get pqrsSent => 'PQRS sent';

  @override
  String get pqrsCreateTitle => 'New PQRS';

  @override
  String get pqrsRequestType => 'Request type';

  @override
  String get pqrsCategory => 'Category';

  @override
  String get pqrsDescriptionHint =>
      'Describe your petition, complaint, claim or suggestion...';

  @override
  String get pqrsNotifyInfo =>
      'Your request will be sent to the community administrator. You will be notified when it is handled.';

  @override
  String get premiumDashboardTitle => 'Vecindario Admin';

  @override
  String get premiumNotActive =>
      'Your community doesn\'t have Vecindario Admin active yet.';

  @override
  String get premiumViewPlans => 'View plans';

  @override
  String get premiumQuickActions => 'QUICK ACTIONS';

  @override
  String get premiumSendOfficialNotice => 'Send official notice';

  @override
  String get premiumCreateSanctionWithEvidence =>
      'Create sanction with evidence';

  @override
  String get premiumCreateConvocationWithAgenda => 'Create notice with agenda';

  @override
  String get premiumModules => 'MODULES';

  @override
  String get premiumCircularsAdminSubtitle => 'Send notices with read tracking';

  @override
  String get premiumCircularsResidentSubtitle =>
      'Official notices from your community';

  @override
  String get premiumFinesAdminSubtitle => 'Record and manage sanctions';

  @override
  String get premiumFinesResidentSubtitle => 'Your fines and defenses';

  @override
  String get premiumPqrsAdminSubtitle => 'Resident requests with SLA';

  @override
  String get premiumPqrsResidentSubtitle =>
      'Send petitions, complaints or suggestions';

  @override
  String get premiumManualSubtitle => 'Community bylaws by chapter';

  @override
  String get premiumAmenitiesAdminSubtitle => 'Manage bookings and deposits';

  @override
  String get premiumAmenitiesResidentSubtitle =>
      'Book the hall, BBQ, court and more';

  @override
  String get premiumFinancesAdminSubtitle => 'Income, expenses and budget';

  @override
  String get premiumFinancesResidentSubtitle =>
      'Your balance, payments and fees';

  @override
  String get premiumAssembliesAdminSubtitle => 'Convene and manage votes';

  @override
  String get premiumAssembliesResidentSubtitle =>
      'Participate and vote in real time';

  @override
  String get premiumResidents => 'Residents';

  @override
  String get premiumOpenPqrs => 'Open PQRS';

  @override
  String get premiumMonthlyRevenue => 'Monthly revenue';

  @override
  String get subscriptionPlansTitle => 'Vecindario Admin Plans';

  @override
  String get subscriptionTagline => 'Digitize your community\'s management';

  @override
  String get subscriptionFirstMonthFree => 'First month free';

  @override
  String get subscriptionUnitsStarter => '1 - 50 units';

  @override
  String get subscriptionUnitsProfessional => '51 - 150 units';

  @override
  String get subscriptionUnitsEnterprise => '151+ units';

  @override
  String get subscriptionFeatureCircularsTracking => 'Circulars with tracking';

  @override
  String get subscriptionFeaturePqrsSla => 'PQRS with SLA';

  @override
  String get subscriptionFeatureManual => 'Community guidelines';

  @override
  String get subscriptionFeatureFineManagement => 'Fine management';

  @override
  String get subscriptionFeatureAmenities => 'Amenities';

  @override
  String get subscriptionFeatureFinances => 'Finances';

  @override
  String get subscriptionFeatureAllStarter => 'Everything in Starter';

  @override
  String get subscriptionFeatureAmenitiesBooking => 'Amenity booking';

  @override
  String get subscriptionFeatureOnlinePayments => 'Online payments';

  @override
  String get subscriptionFeatureFinanceDashboard => 'Financial dashboard';

  @override
  String get subscriptionFeatureIndividualStatement =>
      'Individual account statement';

  @override
  String get subscriptionFeatureAssemblies => 'Assemblies/voting';

  @override
  String get subscriptionFeatureAllProfessional => 'Everything in Professional';

  @override
  String get subscriptionFeatureAssembliesVoting => 'Assemblies + voting';

  @override
  String get subscriptionFeaturePdfReports => 'Automatic PDF reports';

  @override
  String get subscriptionFeatureAccountingApi => 'Accounting API (Siigo)';

  @override
  String get subscriptionFeaturePrioritySupport => 'Priority support';

  @override
  String get subscriptionAnnualDiscount =>
      '20% off annual payment (2 months free)';

  @override
  String subscriptionTrialActivated(String plan) {
    return '30-day trial activated: $plan';
  }

  @override
  String get subscriptionOnlyAdminsCanActivate =>
      'Only administrators can activate the trial';

  @override
  String subscriptionActivationError(String message) {
    return 'Error activating trial: $message';
  }

  @override
  String get subscriptionPopular => 'POPULAR';

  @override
  String get subscriptionPerMonth => '/mo';

  @override
  String get subscriptionTry30DaysFree => 'Try free for 30 days';

  @override
  String get adminSettingsTitle => 'Community settings';

  @override
  String get adminCommunityNotFound => 'Community not found';

  @override
  String get adminGeneralData => 'General information';

  @override
  String get adminNameLabel => 'Name';

  @override
  String get adminNameRequired => 'Name is required';

  @override
  String get adminAddressLabel => 'Address';

  @override
  String get adminCityLabel => 'City';

  @override
  String get adminEstratoLabel => 'Estrato';

  @override
  String adminEstratoOption(int n) {
    return 'Estrato $n';
  }

  @override
  String get adminSaveChanges => 'Save changes';

  @override
  String adminGenericError(String message) {
    return 'Error: $message';
  }

  @override
  String get adminCodeCopied => 'Code copied';

  @override
  String get adminRotateCodeTitle => 'Rotate code';

  @override
  String get adminRotateCodeMessage =>
      'The current code will stop working and a new one will be generated. Residents who haven\'t joined yet will need to request it again.';

  @override
  String get adminRotateAction => 'Rotate';

  @override
  String adminNewCodeMessage(String code) {
    return 'New code: $code';
  }

  @override
  String get adminCodeRotated => 'Code rotated';

  @override
  String adminRotateError(String statusCode) {
    return 'Couldn\'t rotate: $statusCode';
  }

  @override
  String adminSaveError(String message) {
    return 'Error saving: $message';
  }

  @override
  String get adminChangesSaved => 'Changes saved';

  @override
  String get adminResidentsLabel => 'Residents';

  @override
  String get adminServiceLabel => 'Service';

  @override
  String get adminUnitsLabel => 'Units';

  @override
  String get adminPendingApprovalsTitle => 'Pending requests';

  @override
  String get adminAllCaughtUp => 'All caught up';

  @override
  String get adminNoPendingRequests => 'No pending requests';

  @override
  String adminUserApproved(String name) {
    return '$name approved';
  }

  @override
  String adminApproveError(String error) {
    return 'Error approving: $error';
  }

  @override
  String get adminRequestRejected => 'Request rejected';

  @override
  String adminRejectError(String error) {
    return 'Error rejecting: $error';
  }

  @override
  String get superAdminCommunityDetailTitle => 'Community detail';

  @override
  String get superAdminInfoTitle => 'Information';

  @override
  String get superAdminUnitTypeLabel => 'Unit type';

  @override
  String get superAdminAdminUidLabel => 'Admin UID';

  @override
  String get superAdminUnassigned => 'Unassigned';

  @override
  String get superAdminCommunityIdLabel => 'Community ID';

  @override
  String get superAdminCreatedLabel => 'Created';

  @override
  String get superAdminSubscriptionTitle => 'Subscription';

  @override
  String get superAdminNoActivePlanMessage =>
      'No active Vecindario Admin. The admin can activate the trial, or you can activate a plan here.';

  @override
  String get superAdminPlanLabel => 'Plan';

  @override
  String get superAdminStatusLabel => 'Status';

  @override
  String get superAdminActionsTitle => 'Actions';

  @override
  String get superAdminAssignAdminAction => 'Assign administrator';

  @override
  String get superAdminAssignAdminSubtitle =>
      'Enter the UID of the user who will manage the community';

  @override
  String get superAdminActivatePlanAction => 'Activate plan';

  @override
  String get superAdminActivatePlanSubtitle =>
      'Starter, Professional or Enterprise (trial or active)';

  @override
  String get superAdminDeleteCommunityAction => 'Delete community';

  @override
  String get superAdminDeleteCommunitySubtitle =>
      'Irreversible action. Does not delete users.';

  @override
  String superAdminAssignAdminDialogTitle(String name) {
    return 'Assign Admin — $name';
  }

  @override
  String get superAdminAssignAdminDialogMessage =>
      'Enter the UID of the user who will be administrator. You can find it in Firebase Auth.';

  @override
  String get superAdminUidLabel => 'User UID';

  @override
  String get superAdminAssignAction => 'Assign';

  @override
  String get superAdminAdminAssigned => 'Admin assigned';

  @override
  String superAdminActivatePlanDialogTitle(String name) {
    return 'Activate Plan — $name';
  }

  @override
  String get superAdminActivateTrialAction => 'Activate Trial';

  @override
  String superAdminPlanActivatedMessage(String plan) {
    return 'Plan $plan activated (30-day free trial)';
  }

  @override
  String superAdminDeleteCommunityMessage(String name) {
    return 'Are you sure? The document for \"$name\" and its subscription will be deleted. Users are NOT deleted (they remain without a community).';
  }

  @override
  String get superAdminCommunityDeleted => 'Community deleted';

  @override
  String get superAdminAccessDeniedTitle => 'Access denied';

  @override
  String get superAdminNoPermission =>
      'You don\'t have Super Admin permissions';

  @override
  String get superAdminPanelTitle => 'Global Panel';

  @override
  String get superAdminCreateCommunityTooltip => 'Create community';

  @override
  String get superAdminLogoutConfirmMessage =>
      'Are you sure you want to log out?';

  @override
  String get superAdminExitAction => 'Log out';

  @override
  String get superAdminNoCommunitiesMessage => 'No communities registered';

  @override
  String get superAdminCreateFirstCommunity => 'Create first community';

  @override
  String superAdminCommunitiesCountTitle(int count) {
    return 'COMMUNITIES ($count)';
  }

  @override
  String get superAdminGlobalStatsCommunities => 'Communities';

  @override
  String get superAdminSubscriptionsLabel => 'Subscriptions';

  @override
  String superAdminMembersCount(int count) {
    return '$count residents';
  }

  @override
  String get superAdminAssignAdminButton => 'Assign Admin';

  @override
  String get superAdminPlanButton => 'Plan';

  @override
  String get superAdminPanelAssignAdminMessage =>
      'Enter the UID of the user who will be the community\'s administrator. You can find it in Firebase Auth.';

  @override
  String get superAdminNewCommunityTitle => 'New community';

  @override
  String get superAdminCreateCommunityHint =>
      'After creating the community, a unique invite code will be generated to share with the administrator.';

  @override
  String get superAdminBasicInfoTitle => 'Basic information';

  @override
  String get superAdminCommunityNameLabel => 'Community name';

  @override
  String get superAdminCommunityNameHint => 'E.g.: Pinares de Granada';

  @override
  String get superAdminAddressHint => 'E.g.: Carrera 15 # 80-45';

  @override
  String get superAdminAddressRequired => 'Address is required';

  @override
  String get superAdminCityHint => 'E.g.: Bogotá';

  @override
  String get superAdminCityRequired => 'City is required';

  @override
  String get superAdminCharacteristicsTitle => 'Characteristics';

  @override
  String get superAdminEstratoSocioLabel => 'Socioeconomic stratum';

  @override
  String get superAdminUnitTypeFieldLabel => 'Unit type';

  @override
  String get superAdminCreatingAction => 'Creating...';

  @override
  String get superAdminCreateCommunityAction => 'Create community';

  @override
  String superAdminCommunityCreatedMessage(String name, String code) {
    return 'Community \"$name\" created. Code: $code';
  }

  @override
  String superAdminCreateError(String error) {
    return 'Error creating: $error';
  }

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profilePlatformSection => 'Platform';

  @override
  String get profileSuperAdminPanelTitle => 'Super Admin Panel';

  @override
  String get profileManageCommunitiesSubtitle =>
      'Manage communities and clients';

  @override
  String get profileAdminSection => 'Administration';

  @override
  String get profileCommunityAdminTitle => 'Community administration';

  @override
  String get profileCommunityAdminSubtitle =>
      'Approvals, circulars, fines, finances, PQRS and more';

  @override
  String get profileMyCommunitySection => 'My community';

  @override
  String get profileCircularsTitle => 'Circulars';

  @override
  String get profileReserveZoneTitle => 'Reserve area';

  @override
  String get profilePqrsTitle => 'PQRS';

  @override
  String get profileMyFinesTitle => 'My fines';

  @override
  String get profileAccountStatementTitle => 'Account statement';

  @override
  String get profileAssembliesTitle => 'Assemblies';

  @override
  String get profileManualTitle => 'Community guidelines';

  @override
  String get profileMyStoreSection => 'My Store';

  @override
  String get profileStorePanelTitle => 'Store panel';

  @override
  String get profileManageOrdersSubtitle => 'Manage orders and catalog';

  @override
  String get profileConfigSection => 'Settings';

  @override
  String get profileNotificationsTitle => 'Notifications';

  @override
  String get profilePrivacySubtitle => 'Data, rights and account deletion';

  @override
  String get profileAppearanceTitle => 'Appearance';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileThemeSystem => 'Automatic (system)';

  @override
  String get profileLegalSection => 'Legal';

  @override
  String get profileLogoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get profilePostsLabel => 'Posts';

  @override
  String get profileOrdersLabel => 'Orders';

  @override
  String get profileMemberSinceLabel => 'Member since';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileStorageUnauthorized =>
      'You don\'t have permission to upload photos';

  @override
  String get profileStorageQuotaExceeded => 'Photo is too large (max 5 MB)';

  @override
  String get profileStorageRetryLimit => 'Unstable network, try again';

  @override
  String get profileUploadCanceled => 'Upload canceled';

  @override
  String get profilePermissionDenied =>
      'You don\'t have permission. Session expired?';

  @override
  String get profileNoConnection =>
      'No connection. Check your internet and try again';

  @override
  String profileSaveErrorDetail(String detail) {
    return 'Error saving: $detail';
  }

  @override
  String profileUnexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get profileEmailHelperText => 'Cannot be changed';

  @override
  String get profileLaw1581Title => 'Law 1581 of 2012';

  @override
  String get profileLaw1581Description =>
      'You have the right to know, update, correct and delete your personal data.';

  @override
  String get profileMyDataSection => 'My Data';

  @override
  String get profileDownloadDataSubtitle =>
      'Receive a file with all your information';

  @override
  String get profileDataExportRequested =>
      'Request sent. You\'ll receive an email within 48 hours.';

  @override
  String get profileEditPersonalInfoTitle => 'Edit personal information';

  @override
  String get profileEditPersonalInfoSubtitle => 'Name, phone, profile photo';

  @override
  String get profileConsentsSection => 'Consents';

  @override
  String get profilePushNotificationsTitle => 'Push notifications';

  @override
  String get profileEmailNewsTitle => 'News email';

  @override
  String get profileAnalyticsTitle => 'Usage data (analytics)';

  @override
  String get profilePrivacyPolicySubtitle => 'Personal data processing';

  @override
  String get profileTermsSubtitle => 'Terms of service';

  @override
  String get profileDangerZoneTitle => 'Danger zone';

  @override
  String get profileIrreversibleAction => 'This action is irreversible';

  @override
  String get profileCannotRecoverAfter15Days =>
      'After 15 days you won\'t be able to recover your account.';

  @override
  String get profileWillBeDeletedLabel => 'Will be deleted:';

  @override
  String get profileProfileAndPhotoItem => 'Your profile and photo';

  @override
  String get profileVerificationDocsItem => 'Verification documents';

  @override
  String get profileTokensSessionsItem => 'Tokens and sessions';

  @override
  String get profileWillBeAnonymizedLabel => 'Will be anonymized:';

  @override
  String get profilePostsAnonymizedItem => 'Posts → \"Deleted user\"';

  @override
  String get profileReviewsAnonymizedItem => 'Reviews → \"Deleted user\"';

  @override
  String get profileOrdersAnonymizedItem => 'Orders → uid → null';

  @override
  String get profileDeleteAccountButtonLabel =>
      'Delete my account (15-day grace period)';

  @override
  String get profileDeleteAccountDialogTitle => 'Delete Account';

  @override
  String get profileDeleteConfirmMessage =>
      'Are you sure? After 15 days this action can\'t be undone.';

  @override
  String get profileConfirmPasswordLabel => 'Confirm your password';

  @override
  String get profileEnterPasswordError => 'Enter your password';

  @override
  String get profileAccountDeletionScheduled =>
      'Your account will be deleted in 15 days. You can reactivate it by logging in.';

  @override
  String get profileWrongPassword => 'Wrong password';

  @override
  String get profileAuthError => 'Authentication error';

  @override
  String get profileUnexpectedErrorShort => 'Unexpected error';
}
