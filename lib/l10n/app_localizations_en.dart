// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BýtFit Klub';

  @override
  String get navHome => 'Home';

  @override
  String get navCard => 'Card';

  @override
  String get navHistory => 'History';

  @override
  String get navBoard => 'Board';

  @override
  String get navProfile => 'Profile';

  @override
  String get navOverview => 'Overview';

  @override
  String get navMembers => 'Members';

  @override
  String get navPayments => 'Payments';

  @override
  String get navMessages => 'Messages';

  @override
  String get navMore => 'More';

  @override
  String get personaTitle => 'BýtFit Klub';

  @override
  String get personaSubtitle => 'Choose how to open the app.';

  @override
  String get personaOpenAsMember => 'Open as member';

  @override
  String get personaOpenAsOwner => 'Open as Olda (owner)';

  @override
  String get appearanceAndLanguage => 'Appearance & language';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageCs => 'Czech';

  @override
  String get languageEn => 'English';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionBack => 'Back';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionClose => 'Close';

  @override
  String get boardTitle => 'Board';

  @override
  String get boardSubtitle => 'What\'s happening at the Club';

  @override
  String get boardStatusOpen => 'open';

  @override
  String get boardEmptyFilter => 'Nothing for this filter.';

  @override
  String get boardFilterAll => 'All';

  @override
  String get boardFilterOutage => 'Outages';

  @override
  String get boardFilterWarning => 'Caution';

  @override
  String get boardFilterPromo => 'Promos';

  @override
  String get boardFilterEvent => 'Events';

  @override
  String get boardTypePinned => 'Pinned';

  @override
  String get boardTypeOutage => 'Out of service';

  @override
  String get boardTypeWarning => 'Caution';

  @override
  String get boardTypePromo => 'Promo';

  @override
  String get boardTypeEvent => 'Event';

  @override
  String get boardTypeFixed => 'Fixed';

  @override
  String get boardTypeInfo => 'Info';

  @override
  String cardJoinedSince(Object joined) {
    return 'member since $joined';
  }

  @override
  String get cardSubtitle => 'Membership card';

  @override
  String get cardKeyWithYou => 'Deposit 100 CZK paid';

  @override
  String get cardKeyAtReception => 'at reception';

  @override
  String get cardLabelStatus => 'Status';

  @override
  String get cardStatusActive => 'Active';

  @override
  String get cardLabelValidUntil => 'Valid until';

  @override
  String get cardLabelTariff => 'Tariff';

  @override
  String cardTariffValue(Object tariff) {
    return '$tariff · 3 mo.';
  }

  @override
  String get cardLabelKey => 'Key';

  @override
  String get cardBrightnessTip =>
      'When showing the card to Olda, turn up screen brightness — it reads better.';

  @override
  String get cardAddToWallet => 'Add to Wallet';

  @override
  String dashGreeting(Object name) {
    return 'Hi, $name.';
  }

  @override
  String get dashStatusHeadline => 'You can still go to the gym for';

  @override
  String get dashDaysUnit => 'days';

  @override
  String get dashExpiryDate => 'until 23 Jun 2026';

  @override
  String get dashExtendMembership => 'Extend membership';

  @override
  String get dashReportFault => 'Report a fault';

  @override
  String get dashYourCard => 'Your card';

  @override
  String get dashRecentActivity => 'Recent activity';

  @override
  String get dashAll => 'All';

  @override
  String get dashBoard => 'Board';

  @override
  String get dashBoardAll => 'all →';

  @override
  String get dashStatusActive => 'Active';

  @override
  String get dashKeyWithYou => 'key with you';

  @override
  String get dashPinned => 'PINNED';

  @override
  String get dashBoardTimeAgo => '2 h ago';

  @override
  String get dashBoardPostTitle => 'Closed until 2:00 PM tomorrow';

  @override
  String get dashBoardPostBody =>
      'Electrical inspection. We open after lunch. — Olda';

  @override
  String get faultTitle => 'Report a problem';

  @override
  String get faultSubtitle =>
      'What broke, what doesn\'t work? Send it to Olda, he\'ll handle it.';

  @override
  String get faultHint =>
      'For example: bench no. 2 has a frayed cable or the faucet in shower no. 3 is leaking.';

  @override
  String get faultPhotosLabel => 'PHOTOS';

  @override
  String get faultAddPhoto => 'photo';

  @override
  String get faultSubmit => 'Send';

  @override
  String get faultSentToast => 'Problem reported';

  @override
  String faultMessageBody(Object body) {
    return 'Problem: $body';
  }

  @override
  String get faultPhotoOptional => 'optional';

  @override
  String faultPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '$count photo',
    );
    return '$_temp0';
  }

  @override
  String get histTitle => 'History';

  @override
  String get histSubtitle =>
      'Everything that happened with your account at the Club.';

  @override
  String get histStatPaid => 'Paid';

  @override
  String get histStatMemberSince => 'Member since';

  @override
  String histStatMonthsCount(int count) {
    return '$count months';
  }

  @override
  String histFilterAll(int count) {
    return 'All · $count';
  }

  @override
  String histFilterPayments(int count) {
    return 'Payments · $count';
  }

  @override
  String histFilterKey(int count) {
    return 'Key · $count';
  }

  @override
  String histFilterAccount(int count) {
    return 'Account · $count';
  }

  @override
  String get histEndNote =>
      'That\'s all. Your account dates back to September 2025.';

  @override
  String get profMemberSince => 'member since 9 · 2025';

  @override
  String get profActiveDays => 'Active · 23 days';

  @override
  String get profSectionContact => 'Contact';

  @override
  String get profEmail => 'Email';

  @override
  String get profPhone => 'Phone';

  @override
  String get profSectionMembership => 'Membership';

  @override
  String get profTariff => 'Tariff';

  @override
  String get profTariffValue => 'Standard · 3 mo.';

  @override
  String get profValidUntil => 'Valid until';

  @override
  String get profKey => 'Key';

  @override
  String get profKeyValue => 'with you';

  @override
  String get profSectionNotifications => 'Notifications';

  @override
  String get profPushLabel => 'Push notifications';

  @override
  String get profPushSub => 'Membership end, request approvals';

  @override
  String get profOutageLabel => 'Outages and closing hours';

  @override
  String get profOutageSub => 'When something at the Club is out of service';

  @override
  String get profPromoLabel => 'Deals and discounts';

  @override
  String get profPromoSub => 'Occasionally, no more than once a month';

  @override
  String get profSectionHelp => 'Help';

  @override
  String get profFaqLabel => 'FAQ';

  @override
  String get profFaqSub => 'Frequently asked questions and Club rules';

  @override
  String get profWriteToOlda => 'Write to Olda';

  @override
  String get profWriteToOldaSub => 'Usually replies within an hour';

  @override
  String get profSignOut => 'Sign out';

  @override
  String get profBuildInfo => 'BýtFit Klub · v1.0.0 · built 5/2026';

  @override
  String get qrTitle => 'Payment';

  @override
  String get qrTariffLabel => 'TARIFF';

  @override
  String get qrHeadline => 'Scan the QR code or save it';

  @override
  String get qrDetailAmount => 'Amount';

  @override
  String get qrDetailAccount => 'Account';

  @override
  String get qrDetailVs => 'VS';

  @override
  String get qrDetailMessage => 'Message';

  @override
  String get qrSaveQr => 'Save QR';

  @override
  String get qrCopy => 'Copy';

  @override
  String get qrSaveHint =>
      'The QR code is saved to Photos. Open it in your bank app via \"Scan from file\".';

  @override
  String get qrToastMarkedPaid => 'Marked as paid';

  @override
  String get qrPaidButton => 'I\'ve paid';

  @override
  String get adashKicker => 'BÝTFIT ADMIN';

  @override
  String get adashGreeting => 'Good morning, Olda.';

  @override
  String get adashStatActive => 'ACTIVE';

  @override
  String adashStatActiveSub(Object total) {
    return 'of $total';
  }

  @override
  String get adashStatEndingSoon => 'ENDING ≤ 7 DAYS';

  @override
  String get adashStatEndingSoonSub => 'win anniversary';

  @override
  String get adashStatOverdue => 'OVERDUE';

  @override
  String get adashStatOverdueSub => 'urgent';

  @override
  String adashStatRevenue(Object period) {
    return 'REVENUE $period';
  }

  @override
  String get adashCurrencyCzk => 'CZK';

  @override
  String get adashNeedsAttention => 'Needs attention';

  @override
  String adashAttnPending(Object count) {
    return '$count pending registrations';
  }

  @override
  String adashAttnOverdue(Object count) {
    return '$count overdue';
  }

  @override
  String adashAttnOverdueSub(Object names) {
    return '$names · pay as soon as possible';
  }

  @override
  String adashAttnEndingSoon(Object count) {
    return '$count ending soon';
  }

  @override
  String get adashAttnEndingSoonSub => 'This week';

  @override
  String get adashQuickActions => 'Quick actions';

  @override
  String get adashActionSendMessage => 'Send message';

  @override
  String get adashActionPayments => 'Payments';

  @override
  String get adashActionAddMember => 'Add member';

  @override
  String get adashRevenue => 'Revenue';

  @override
  String get adashRevenueRange => '6 months';

  @override
  String adashRevenueMonth(Object month) {
    return 'CZK · $month';
  }

  @override
  String get addmTitle => 'New member';

  @override
  String get addmNoName => 'No name';

  @override
  String addmMemberAddedToast(Object months, Object name) {
    return '$name added · $months mo.';
  }

  @override
  String get addmSectionBasic => 'Basics';

  @override
  String get addmFieldName => 'Full name';

  @override
  String get addmFieldNamePlaceholder => 'e.g. Pavel Novák';

  @override
  String get addmFieldNameError => 'Enter a name';

  @override
  String get addmFieldEmail => 'Email';

  @override
  String get addmFieldPhone => 'Phone';

  @override
  String get addmContactRequired => 'I need at least an email or phone.';

  @override
  String get addmSectionTariff => 'Tariff';

  @override
  String get addmTariffStandard => 'Standard';

  @override
  String get addmTariffStandardSub => '750 CZK/mo';

  @override
  String get addmTariffStudent => 'Student';

  @override
  String get addmTariffStudentSub => '500 CZK/mo · ISIC';

  @override
  String get addmHasIsic => 'Has ISIC';

  @override
  String get addmHasIsicSub => 'I need to see a valid card';

  @override
  String get addmLength => 'Length';

  @override
  String addmMonths(Object months) {
    return '$months mo.';
  }

  @override
  String get addmSectionPrice => 'Monthly price';

  @override
  String get addmCustomPrice => 'Custom price';

  @override
  String addmCustomPriceOnSub(Object price) {
    return 'Overrides the standard $price CZK/mo';
  }

  @override
  String addmCustomPriceOffSub(Object price) {
    return 'Use the standard $price CZK/mo';
  }

  @override
  String get addmSectionKey => 'Key & deposit';

  @override
  String get addmIssueKey => 'Issue key';

  @override
  String get addmIssueKeySub => '100 CZK deposit in cash';

  @override
  String get addmSubmit => 'Add member';

  @override
  String get addmCancel => 'Cancel';

  @override
  String get addmSubtitleIsic => ' · ISIC';

  @override
  String get addmSubtitleCustomPrice => ' · custom price';

  @override
  String get addmCustomPriceLabel => 'Custom price';

  @override
  String get addmPerMonth => 'CZK/mo';

  @override
  String get addmPriceError => 'Enter an amount greater than 0';

  @override
  String addmCzk(Object amount) {
    return '$amount CZK';
  }

  @override
  String get addmToPay => 'To pay ';

  @override
  String get addmCzkUnit => 'CZK';

  @override
  String get amoreTitle => 'More';

  @override
  String get amoreOwnerSubtitle => 'owner · BýtFit Klub';

  @override
  String get amoreSectionActivity => 'Activity';

  @override
  String get amoreApprovalsLabel => 'Registration approvals';

  @override
  String get amoreApprovalsSub => '2 pending requests';

  @override
  String get amoreBoardLabel => 'Board';

  @override
  String get amoreBoardSub => 'Pin, outage, events';

  @override
  String get amoreBroadcastLabel => 'Broadcast to everyone';

  @override
  String amoreBroadcastSub(Object count) {
    return '$count members';
  }

  @override
  String get amoreSectionClub => 'Club';

  @override
  String get amoreTariffsLabel => 'Tariffs and prices';

  @override
  String get amoreTariffsSub => 'Standard 2,250 · Student 1,500 · 6m / 12m';

  @override
  String get amoreHoursLabel => 'Opening hours';

  @override
  String get amoreHoursSub => 'Mon–Fri 6:00–22:00 · Sat–Sun 8:00–20:00';

  @override
  String get amoreKeysLabel => 'Keys and deposits';

  @override
  String get amoreKeysSub => '34 issued · 2 forfeited deposits';

  @override
  String get amoreRulesLabel => 'Club rules';

  @override
  String get amoreRulesSub => 'Last updated 3 Apr 2026';

  @override
  String get amoreSectionData => 'Data';

  @override
  String get amoreExportLabel => 'Export payments (CSV)';

  @override
  String get amoreExportSub => 'For accounting · last 12 months';

  @override
  String get amoreBackupLabel => 'Database backup';

  @override
  String get amoreBackupSub => 'Last backup · today 03:00';

  @override
  String get amoreSectionAccount => 'Account';

  @override
  String get amoreHelpLabel => 'Help & FAQ';

  @override
  String get amoreHelpSub => 'App rules, questions';

  @override
  String get amoreLogoutLabel => 'Sign out Olda';

  @override
  String get amoreVersion => 'BÝTFIT KLUB · v1.0.0';

  @override
  String get amsgTitle => 'Messages';

  @override
  String get amsgSearchHint => 'Search messages…';

  @override
  String get amsgBulkAll => 'Broadcast to all';

  @override
  String get amsgRemindDebtors => 'Remind debtors';

  @override
  String get amsgPaymentReminderMsg =>
      'Payment reminder — I\'ll send a QR code. Thanks.';

  @override
  String get amsgRemindersSent => 'Reminders sent';

  @override
  String amsgThreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count threads',
      one: '$count thread',
    );
    return '$_temp0';
  }

  @override
  String amsgEmptySearch(String query) {
    return 'No one matching \"$query\"';
  }

  @override
  String get amsgEmpty => 'No messages yet.';

  @override
  String get amsgAllDone => 'All caught up';

  @override
  String amsgUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String amsgUnreadThreads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count threads',
      one: '$count thread',
    );
    return '$_temp0';
  }

  @override
  String amsgSentToMembers(int count) {
    return 'Sent · to $count members';
  }

  @override
  String get amsgFromMePrefix => 'me →';

  @override
  String get amsgComposeTitle => 'New message';

  @override
  String get amsgComposeSearchHint => 'Who to message…';

  @override
  String get amsgBroadcastTitle => 'Broadcast message';

  @override
  String get amsgBroadcastSubtitle =>
      'Lands for everyone as a regular message from Olda';

  @override
  String get amsgBroadcastTo => 'TO';

  @override
  String get amsgBroadcastTextHint => 'What do you want to say…';

  @override
  String amsgSendButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return 'Send · $_temp0';
  }

  @override
  String get apayTitle => 'Payments';

  @override
  String get apayToastExportReady => 'Export ready';

  @override
  String get apayToastAddPayment => 'Add payment';

  @override
  String get apayMonthLabel => 'MAY 2026';

  @override
  String apayYtd(Object amount) {
    return 'YTD $amount';
  }

  @override
  String apayStatReceived(Object count) {
    return '$count received';
  }

  @override
  String apayStatPending(Object count) {
    return '$count pending';
  }

  @override
  String apayStatDebt(Object amount) {
    return '$amount CZK debt';
  }

  @override
  String get apaySearchHint => 'Search member…';

  @override
  String apayFilterAll(Object count) {
    return 'All · $count';
  }

  @override
  String apayFilterReceived(Object count) {
    return 'Received · $count';
  }

  @override
  String apayFilterPending(Object count) {
    return 'Pending · $count';
  }

  @override
  String apayFilterOverdue(Object count) {
    return 'Overdue · $count';
  }

  @override
  String apayFilterActive(Object query) {
    return 'filter: “$query”';
  }

  @override
  String get apayEmpty => 'No payments for the selected filter.';

  @override
  String apayReminderMessage(Object amount) {
    return 'Payment reminder $amount CZK — I\'ll send the QR. Thanks.';
  }

  @override
  String get apayToastReminderSent => 'Reminder sent';

  @override
  String get apayRemind => 'Remind';

  @override
  String get apayMarkPaid => 'Mark as paid';

  @override
  String apayRecordsHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records · date ↓',
      one: '$count record · date ↓',
    );
    return '$_temp0';
  }

  @override
  String get apprTitle => 'Approvals';

  @override
  String get apprNewApplicant => 'NEW APPLICANT';

  @override
  String get apprEmail => 'Email';

  @override
  String get apprPhone => 'Phone';

  @override
  String get apprTariff => 'Tariff';

  @override
  String get apprGdprConsent => 'GDPR consent';

  @override
  String get apprIsicCard => 'ISIC CARD';

  @override
  String get apprTapToEnlarge => 'tap to enlarge';

  @override
  String get apprCheckPrefix => 'Check: ';

  @override
  String get apprApplicantNote => 'NOTE FROM APPLICANT';

  @override
  String get apprReject => 'Reject';

  @override
  String get apprApprove => 'Approve';

  @override
  String apprRejectedToast(Object name) {
    return 'Rejected · $name';
  }

  @override
  String apprApprovedToast(Object name) {
    return '$name added to members';
  }

  @override
  String athrTemplatePaymentReminder(Object amount) {
    return 'Payment reminder $amount CZK. I\'ll send a QR code.';
  }

  @override
  String athrTemplateExpiringSoon(Object name) {
    return 'Hi $name, your membership ends in a few days. Want to renew?';
  }

  @override
  String get athrTemplateDropBy => 'I\'ll drop by the Club tomorrow.';

  @override
  String get athrTemplateThanksGot => 'Thanks, got it.';

  @override
  String get athrContextOverdue => 'Payment past due · overdue';

  @override
  String get athrEmptyState => 'Start with the first message.';

  @override
  String athrComposerHint(Object name) {
    return 'Message $name…';
  }

  @override
  String athrExpiresIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Membership ends in $count days',
      one: 'Membership ends in $count day',
    );
    return '$_temp0';
  }

  @override
  String get bcastHeader => 'Broadcast message';

  @override
  String get bcastTargetActive => 'All active';

  @override
  String get bcastTargetOverdue => 'Overdue members';

  @override
  String get bcastTargetEnding => 'Members ending soon';

  @override
  String get bcastTargetAll => 'All members';

  @override
  String get bcastSectionRecipients => 'RECIPIENTS';

  @override
  String get bcastSectionMessage => 'MESSAGE';

  @override
  String get bcastSectionTemplates => 'TEMPLATES';

  @override
  String get bcastSectionPreview => 'PREVIEW';

  @override
  String get bcastTitleHint => 'Title (optional)';

  @override
  String get bcastBodyHint => 'Write a message to members…';

  @override
  String get bcastPreviewBadge => 'INFO · BOARD';

  @override
  String get bcastPreviewNoTitle => 'No title';

  @override
  String get bcastPreviewBodyPlaceholder =>
      'The message text will appear here.';

  @override
  String bcastSendLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return 'Send · $_temp0';
  }

  @override
  String bcastSentToast(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return 'Sent · $_temp0';
  }

  @override
  String get mdetTitle => 'Member detail';

  @override
  String mdetStateActive(Object days) {
    return 'Active · $days days';
  }

  @override
  String mdetStateEnding(Object days) {
    return 'Ends in $days days';
  }

  @override
  String mdetStateOverdue(Object days) {
    return 'Overdue · $days days';
  }

  @override
  String get mdetStateSuspended => 'Suspended';

  @override
  String mdetMemberSince(Object date) {
    return 'member since $date';
  }

  @override
  String get mdetQuickMessage => 'Message';

  @override
  String get mdetQuickPayment => 'Payment';

  @override
  String get mdetQuickExtend => 'Extend';

  @override
  String get mdetKvEmail => 'Email';

  @override
  String get mdetKvPhone => 'Phone';

  @override
  String get mdetKvTariff => 'Tariff';

  @override
  String get mdetKvPricePerMonth => 'Price/mo.';

  @override
  String get mdetKvPaidUntil => 'Paid until';

  @override
  String get mdetCustomBadge => 'CUSTOM';

  @override
  String mdetAlertOverdue(Object days) {
    return 'Payment $days days overdue';
  }

  @override
  String get mdetWrite => 'Write';

  @override
  String get mdetSectionKeyDeposit => 'Key & deposit';

  @override
  String get mdetKey => 'Key';

  @override
  String mdetKeyIssued(Object date) {
    return 'issued $date';
  }

  @override
  String get mdetKeyWithMember => 'With member';

  @override
  String get mdetDeposit => 'Deposit';

  @override
  String get mdetDepositReceived => 'Received';

  @override
  String get mdetMarkReturned => 'Mark as returned';

  @override
  String get mdetSectionPayments => 'Payments';

  @override
  String mdetPaymentsSince(Object date) {
    return 'since $date';
  }

  @override
  String get mdetNoPayments => 'No payments yet.';

  @override
  String get mdetManualPayment => 'Manual payment (cash)';

  @override
  String get mdetSectionActions => 'Actions';

  @override
  String get mdetSuspendLabel => 'Suspend membership';

  @override
  String get mdetSuspendSub =>
      'Membership stays in the system, no payment is tracked';

  @override
  String get mdetDeleteLabel => 'Delete member';

  @override
  String get mdetDeleteSub => 'Irreversible action, requires confirmation';

  @override
  String get mdetDeleteDialogTitle => 'Delete member?';

  @override
  String mdetDeleteDialogBody(Object name) {
    return 'Do you really want to delete $name? This action is irreversible.';
  }

  @override
  String get mdetDeleteDialogCancel => 'Cancel';

  @override
  String get mdetDeleteDialogConfirm => 'Delete';

  @override
  String get mlistTitle => 'Members';

  @override
  String mlistSubtitle(Object active, Object attention, Object total) {
    return '$total total · $active active · $attention need attention';
  }

  @override
  String get mlistSearchHint => 'Search member, phone, e-mail…';

  @override
  String mlistChipAll(Object count) {
    return 'All · $count';
  }

  @override
  String mlistChipActive(Object count) {
    return 'Active $count';
  }

  @override
  String mlistChipEnding(Object count) {
    return 'Ending $count';
  }

  @override
  String mlistChipOverdue(Object count) {
    return 'Overdue $count';
  }

  @override
  String get mlistSortLabelExpiration => 'expiration';

  @override
  String get mlistSortLabelName => 'name';

  @override
  String get mlistSortLabelTariff => 'tariff';

  @override
  String mlistEmptySearch(Object query) {
    return 'Nobody matches \"$query\"';
  }

  @override
  String get mlistEmptyFilter => 'No members for the selected filter.';

  @override
  String mlistMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get mlistDaysSuspended => 'suspended';

  @override
  String mlistDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String mlistDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get mlistRowUntilExpiry => 'until expiry';

  @override
  String get mlistRowEnding => 'ending';

  @override
  String get mlistRowOverdue => 'overdue';

  @override
  String get mlistRow30Plus => '30+ days';

  @override
  String get mlistRowKey => 'key';

  @override
  String get mlistRowNoKey => 'no key';

  @override
  String get mlistSheetTitle => 'Filter and sorting';

  @override
  String get mlistSheetReset => 'reset';

  @override
  String get mlistSheetSortBy => 'Sort by';

  @override
  String get mlistSortOptExpirationTitle => 'Expiration';

  @override
  String get mlistSortOptExpirationDesc => 'who ends first';

  @override
  String get mlistSortOptNameTitle => 'Name';

  @override
  String get mlistSortOptNameDesc => 'alphabetically';

  @override
  String get mlistSortOptTariffTitle => 'Tariff';

  @override
  String get mlistSortOptTariffDesc => 'Standard / Student';

  @override
  String get mlistSheetAscending => 'Ascending';

  @override
  String get mlistSheetDescending => 'Descending';

  @override
  String get mlistSheetTapToToggle => 'Tap to toggle';

  @override
  String get mlistSheetTariff => 'Tariff';

  @override
  String get mlistTariffOptBoth => 'Both';

  @override
  String get mlistSheetKey => 'Key';

  @override
  String get mlistKeyOptAll => 'All';

  @override
  String get mlistKeyOptWith => 'With key';

  @override
  String get mlistKeyOptWithout => 'Without key';

  @override
  String get mlistSheetApply => 'Apply';
}
