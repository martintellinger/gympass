// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class LCs extends L {
  LCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'BýtFit Klub';

  @override
  String get navHome => 'Domů';

  @override
  String get navCard => 'Karta';

  @override
  String get navHistory => 'Historie';

  @override
  String get navBoard => 'Nástěnka';

  @override
  String get navProfile => 'Profil';

  @override
  String get navOverview => 'Přehled';

  @override
  String get navMembers => 'Členové';

  @override
  String get navPayments => 'Platby';

  @override
  String get navMessages => 'Zprávy';

  @override
  String get navMore => 'Více';

  @override
  String get personaTitle => 'BýtFit Klub';

  @override
  String get personaSubtitle => 'Vyber, jak appku otevřít.';

  @override
  String get personaOpenAsMember => 'Otevřít jako člen';

  @override
  String get personaOpenAsOwner => 'Otevřít jako Olda (majitel)';

  @override
  String get appearanceAndLanguage => 'Vzhled & jazyk';

  @override
  String get themeLabel => 'Téma';

  @override
  String get themeDark => 'Tmavé';

  @override
  String get themeSystem => 'Systém';

  @override
  String get themeLight => 'Světlé';

  @override
  String get languageLabel => 'Jazyk';

  @override
  String get languageCs => 'Čeština';

  @override
  String get languageEn => 'Angličtina';

  @override
  String get actionSave => 'Uložit';

  @override
  String get actionCancel => 'Zrušit';

  @override
  String get actionBack => 'Zpět';

  @override
  String get actionConfirm => 'Potvrdit';

  @override
  String get actionClose => 'Zavřít';

  @override
  String get boardTitle => 'Nástěnka';

  @override
  String get boardSubtitle => 'Co se děje v Klubu';

  @override
  String get boardStatusOpen => 'otevřeno';

  @override
  String get boardEmptyFilter => 'Pro tento filtr nic není.';

  @override
  String get boardFilterAll => 'Vše';

  @override
  String get boardFilterOutage => 'Výpadky';

  @override
  String get boardFilterWarning => 'Pozor';

  @override
  String get boardFilterPromo => 'Akce';

  @override
  String get boardFilterEvent => 'Události';

  @override
  String get boardTypePinned => 'Připnuto';

  @override
  String get boardTypeOutage => 'Mimo provoz';

  @override
  String get boardTypeWarning => 'Pozor';

  @override
  String get boardTypePromo => 'Akce';

  @override
  String get boardTypeEvent => 'Událost';

  @override
  String get boardTypeFixed => 'Opraveno';

  @override
  String get boardTypeInfo => 'Info';

  @override
  String cardJoinedSince(Object joined) {
    return 'člen od $joined';
  }

  @override
  String get cardSubtitle => 'Členská karta';

  @override
  String get cardKeyWithYou => 'Záloha 100 Kč uhrazena';

  @override
  String get cardKeyAtReception => 'na recepci';

  @override
  String get cardLabelStatus => 'Stav';

  @override
  String get cardStatusActive => 'Aktivní';

  @override
  String get cardLabelValidUntil => 'Platí do';

  @override
  String get cardLabelTariff => 'Tarif';

  @override
  String cardTariffValue(Object tariff) {
    return '$tariff · 3 měs.';
  }

  @override
  String get cardLabelKey => 'Klíč';

  @override
  String get cardBrightnessTip =>
      'Když ukazuješ kartu Oldovi, zvyš jas obrazovky — čte se to líp.';

  @override
  String get cardAddToWallet => 'Přidat do Walletu';

  @override
  String dashGreeting(Object name) {
    return 'Ahoj, $name.';
  }

  @override
  String get dashStatusHeadline => 'Do posilovny můžeš ještě';

  @override
  String get dashDaysUnit => 'dní';

  @override
  String get dashExpiryDate => 'do 23. 6. 2026';

  @override
  String get dashExtendMembership => 'Prodloužit členství';

  @override
  String get dashReportFault => 'Nahlásit závadu';

  @override
  String get dashYourCard => 'Tvoje karta';

  @override
  String get dashRecentActivity => 'Poslední aktivity';

  @override
  String get dashAll => 'Vše';

  @override
  String get dashBoard => 'Nástěnka';

  @override
  String get dashBoardAll => 'vše →';

  @override
  String get dashStatusActive => 'Aktivní';

  @override
  String get dashKeyWithYou => 'klíč u tebe';

  @override
  String get dashPinned => 'PŘIPNUTO';

  @override
  String get dashBoardTimeAgo => 'před 2 h';

  @override
  String get dashBoardPostTitle => 'Zítra zavřeno do 14:00';

  @override
  String get dashBoardPostBody =>
      'Revize elektroinstalace. Otevíráme po obědě. — Olda';

  @override
  String get faultTitle => 'Nahlásit závadu';

  @override
  String get faultSubtitle =>
      'Co se pokazilo, co nejde? Pošli to Oldovi, on vyřídí.';

  @override
  String get faultHint =>
      'Třeba: bench č. 2 má rozsekané lano nebo ve sprše č. 3 protéká kohoutek.';

  @override
  String get faultPhotosLabel => 'FOTKY';

  @override
  String get faultAddPhoto => 'fotka';

  @override
  String get faultSubmit => 'Odeslat';

  @override
  String get faultSentToast => 'Závada odeslána';

  @override
  String faultMessageBody(Object body) {
    return 'Závada: $body';
  }

  @override
  String get faultPhotoOptional => 'volitelné';

  @override
  String faultPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotek',
      few: '$count fotky',
      one: '$count foto',
    );
    return '$_temp0';
  }

  @override
  String get histTitle => 'Historie';

  @override
  String get histSubtitle => 'Všechno, co se v Klubu stalo s tvým účtem.';

  @override
  String get histStatPaid => 'Zaplaceno';

  @override
  String get histStatMemberSince => 'Člen od';

  @override
  String histStatMonthsCount(int count) {
    return '$count měsíců';
  }

  @override
  String histFilterAll(int count) {
    return 'Vše · $count';
  }

  @override
  String histFilterPayments(int count) {
    return 'Platby · $count';
  }

  @override
  String histFilterKey(int count) {
    return 'Klíč · $count';
  }

  @override
  String histFilterAccount(int count) {
    return 'Účet · $count';
  }

  @override
  String get histEndNote => 'To je všechno. Účet máš od září 2025.';

  @override
  String get profMemberSince => 'člen od 9 · 2025';

  @override
  String get profActiveDays => 'Aktivní · 23 dní';

  @override
  String get profSectionContact => 'Kontakt';

  @override
  String get profEmail => 'E-mail';

  @override
  String get profPhone => 'Telefon';

  @override
  String get profSectionMembership => 'Členství';

  @override
  String get profTariff => 'Tarif';

  @override
  String get profTariffValue => 'Standard · 3 měs.';

  @override
  String get profValidUntil => 'Platí do';

  @override
  String get profKey => 'Klíč';

  @override
  String get profKeyValue => 'u tebe';

  @override
  String get profSectionNotifications => 'Notifikace';

  @override
  String get profPushLabel => 'Push notifikace';

  @override
  String get profPushSub => 'Konec členství, schválení žádostí';

  @override
  String get profOutageLabel => 'Výpadky a zavírací doba';

  @override
  String get profOutageSub => 'Když je v Klubu něco mimo provoz';

  @override
  String get profPromoLabel => 'Akce a slevy';

  @override
  String get profPromoSub => 'Občas, ne víc než 1× měsíčně';

  @override
  String get profSectionHelp => 'Pomoc';

  @override
  String get profFaqLabel => 'FAQ';

  @override
  String get profFaqSub => 'Časté otázky a pravidla Klubu';

  @override
  String get profWriteToOlda => 'Napsat Oldovi';

  @override
  String get profWriteToOldaSub => 'Odpovídá obvykle do hodiny';

  @override
  String get profSignOut => 'Odhlásit';

  @override
  String get profBuildInfo => 'BýtFit Klub · v1.0.0 · sestaveno 5/2026';

  @override
  String get qrTitle => 'Platba';

  @override
  String get qrTariffLabel => 'TARIF';

  @override
  String get qrHeadline => 'Naskenuj QR nebo si ho ulož';

  @override
  String get qrDetailAmount => 'Částka';

  @override
  String get qrDetailAccount => 'Účet';

  @override
  String get qrDetailVs => 'VS';

  @override
  String get qrDetailMessage => 'Zpráva';

  @override
  String get qrSaveQr => 'Uložit QR';

  @override
  String get qrCopy => 'Zkopírovat';

  @override
  String get qrSaveHint =>
      'QR se uloží do Fotek. Otevři ho v bance přes „Naskenovat ze souboru\".';

  @override
  String get qrToastMarkedPaid => 'Označeno jako zaplaceno';

  @override
  String get qrPaidButton => 'Zaplatil jsem';

  @override
  String get adashKicker => 'BÝTFIT ADMIN';

  @override
  String get adashGreeting => 'Dobré ráno, Oldo.';

  @override
  String get adashStatActive => 'AKTIVNÍCH';

  @override
  String adashStatActiveSub(Object total) {
    return 'z $total';
  }

  @override
  String get adashStatEndingSoon => 'KONČÍ ≤ 7 DNÍ';

  @override
  String get adashStatEndingSoonSub => 'vyhraj výročí';

  @override
  String get adashStatOverdue => 'PO LHŮTĚ';

  @override
  String get adashStatOverdueSub => 'urgent';

  @override
  String adashStatRevenue(Object period) {
    return 'PŘÍJEM $period';
  }

  @override
  String get adashCurrencyCzk => 'Kč';

  @override
  String get adashNeedsAttention => 'Vyžaduje pozornost';

  @override
  String adashAttnPending(Object count) {
    return '$count čekající registrace';
  }

  @override
  String adashAttnOverdue(Object count) {
    return '$count po lhůtě';
  }

  @override
  String adashAttnOverdueSub(Object names) {
    return '$names · zaplať co nejdřív';
  }

  @override
  String adashAttnEndingSoon(Object count) {
    return '$count končí brzy';
  }

  @override
  String get adashAttnEndingSoonSub => 'Tento týden';

  @override
  String get adashQuickActions => 'Rychlé akce';

  @override
  String get adashActionSendMessage => 'Poslat zprávu';

  @override
  String get adashActionPayments => 'Platby';

  @override
  String get adashActionAddMember => 'Přidat člena';

  @override
  String get adashRevenue => 'Příjem';

  @override
  String get adashRevenueRange => '6 měsíců';

  @override
  String adashRevenueMonth(Object month) {
    return 'Kč · $month';
  }

  @override
  String get addmTitle => 'Nový člen';

  @override
  String get addmNoName => 'Bez jména';

  @override
  String addmMemberAddedToast(Object months, Object name) {
    return '$name přidán/a · $months měs.';
  }

  @override
  String get addmSectionBasic => 'Základní';

  @override
  String get addmFieldName => 'Jméno a příjmení';

  @override
  String get addmFieldNamePlaceholder => 'např. Pavel Novák';

  @override
  String get addmFieldNameError => 'Vyplň jméno';

  @override
  String get addmFieldEmail => 'E-mail';

  @override
  String get addmFieldPhone => 'Telefon';

  @override
  String get addmContactRequired => 'Potřebuju aspoň e-mail nebo telefon.';

  @override
  String get addmSectionTariff => 'Tarif';

  @override
  String get addmTariffStandard => 'Standard';

  @override
  String get addmTariffStandardSub => '750 Kč/měs';

  @override
  String get addmTariffStudent => 'Student';

  @override
  String get addmTariffStudentSub => '500 Kč/měs · ISIC';

  @override
  String get addmHasIsic => 'Má ISIC';

  @override
  String get addmHasIsicSub => 'Potřebuju vidět platnou kartu';

  @override
  String get addmLength => 'Délka';

  @override
  String addmMonths(Object months) {
    return '$months měs.';
  }

  @override
  String get addmSectionPrice => 'Cena za měsíc';

  @override
  String get addmCustomPrice => 'Individuální cena';

  @override
  String addmCustomPriceOnSub(Object price) {
    return 'Přepisuje standardní $price Kč/měs';
  }

  @override
  String addmCustomPriceOffSub(Object price) {
    return 'Použít standardní $price Kč/měs';
  }

  @override
  String get addmSectionKey => 'Klíč & kauce';

  @override
  String get addmIssueKey => 'Vydat klíč';

  @override
  String get addmIssueKeySub => 'Kauce 100 Kč v hotovosti';

  @override
  String get addmSubmit => 'Přidat člena';

  @override
  String get addmCancel => 'Zrušit';

  @override
  String get addmSubtitleIsic => ' · ISIC';

  @override
  String get addmSubtitleCustomPrice => ' · vlastní cena';

  @override
  String get addmCustomPriceLabel => 'Vlastní cena';

  @override
  String get addmPerMonth => 'Kč/měs';

  @override
  String get addmPriceError => 'Zadej částku větší než 0';

  @override
  String addmCzk(Object amount) {
    return '$amount Kč';
  }

  @override
  String get addmToPay => 'K zaplacení ';

  @override
  String get addmCzkUnit => 'Kč';

  @override
  String get amoreTitle => 'Více';

  @override
  String get amoreOwnerSubtitle => 'majitel · BýtFit Klub';

  @override
  String get amoreSectionActivity => 'Aktivita';

  @override
  String get amoreApprovalsLabel => 'Schvalování registrací';

  @override
  String get amoreApprovalsSub => '2 čekající žádosti';

  @override
  String get amoreBoardLabel => 'Nástěnka';

  @override
  String get amoreBoardSub => 'Připnout, mimo provoz, akce';

  @override
  String get amoreBroadcastLabel => 'Hromadná zpráva všem';

  @override
  String amoreBroadcastSub(Object count) {
    return '$count členů';
  }

  @override
  String get amoreSectionClub => 'Klub';

  @override
  String get amoreTariffsLabel => 'Tarify a ceny';

  @override
  String get amoreTariffsSub => 'Standard 2 250 · Student 1 500 · 6m / 12m';

  @override
  String get amoreHoursLabel => 'Otevírací doba';

  @override
  String get amoreHoursSub => 'Po–Pá 6:00–22:00 · So–Ne 8:00–20:00';

  @override
  String get amoreKeysLabel => 'Klíče a kauce';

  @override
  String get amoreKeysSub => '34 vydaných · 2 propadlé kauce';

  @override
  String get amoreRulesLabel => 'Pravidla Klubu';

  @override
  String get amoreRulesSub => 'Naposledy aktualizováno 3. 4. 2026';

  @override
  String get amoreSectionData => 'Data';

  @override
  String get amoreExportLabel => 'Export plateb (CSV)';

  @override
  String get amoreExportSub => 'Pro účetnictví · poslední 12 měsíců';

  @override
  String get amoreBackupLabel => 'Záloha databáze';

  @override
  String get amoreBackupSub => 'Poslední záloha · dnes 03:00';

  @override
  String get amoreSectionAccount => 'Účet';

  @override
  String get amoreHelpLabel => 'Nápověda & FAQ';

  @override
  String get amoreHelpSub => 'Pravidla aplikace, dotazy';

  @override
  String get amoreLogoutLabel => 'Odhlásit Oldu';

  @override
  String get amoreVersion => 'BÝTFIT KLUB · v1.0.0';

  @override
  String get amsgTitle => 'Zprávy';

  @override
  String get amsgSearchHint => 'Hledat ve zprávách…';

  @override
  String get amsgBulkAll => 'Hromadně všem';

  @override
  String get amsgRemindDebtors => 'Připomenout dlužníky';

  @override
  String get amsgPaymentReminderMsg => 'Připomínka platby — pošlu QR. Dík.';

  @override
  String get amsgRemindersSent => 'Připomínky odeslány';

  @override
  String amsgThreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vláken',
      few: '$count vlákna',
      one: '$count vlákno',
    );
    return '$_temp0';
  }

  @override
  String amsgEmptySearch(String query) {
    return 'Nikdo s \"$query\"';
  }

  @override
  String get amsgEmpty => 'Zatím žádné zprávy.';

  @override
  String get amsgAllDone => 'Vše vyřízeno';

  @override
  String amsgUnreadCount(int count) {
    return '$count nepřečteno';
  }

  @override
  String amsgUnreadThreads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vláken',
      few: '$count vlákna',
      one: '$count vlákno',
    );
    return '$_temp0';
  }

  @override
  String amsgSentToMembers(int count) {
    return 'Odesláno · $count členům';
  }

  @override
  String get amsgFromMePrefix => 'já →';

  @override
  String get amsgComposeTitle => 'Nová zpráva';

  @override
  String get amsgComposeSearchHint => 'Komu napsat…';

  @override
  String get amsgBroadcastTitle => 'Hromadná zpráva';

  @override
  String get amsgBroadcastSubtitle =>
      'Přistáne všem jako normální zpráva od Oldy';

  @override
  String get amsgBroadcastTo => 'KOMU';

  @override
  String get amsgBroadcastTextHint => 'Co chtěš říct…';

  @override
  String amsgSendButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count členů',
      few: '$count členové',
      one: '$count člen',
    );
    return 'Odeslat · $_temp0';
  }

  @override
  String get apayTitle => 'Platby';

  @override
  String get apayToastExportReady => 'Export připraven';

  @override
  String get apayToastAddPayment => 'Přidat platbu';

  @override
  String get apayMonthLabel => 'KVĚTEN 2026';

  @override
  String apayYtd(Object amount) {
    return 'YTD $amount';
  }

  @override
  String apayStatReceived(Object count) {
    return '$count přijato';
  }

  @override
  String apayStatPending(Object count) {
    return '$count čeká';
  }

  @override
  String apayStatDebt(Object amount) {
    return '$amount Kč dluh';
  }

  @override
  String get apaySearchHint => 'Hledat člena…';

  @override
  String apayFilterAll(Object count) {
    return 'Vše · $count';
  }

  @override
  String apayFilterReceived(Object count) {
    return 'Přijato · $count';
  }

  @override
  String apayFilterPending(Object count) {
    return 'Čeká · $count';
  }

  @override
  String apayFilterOverdue(Object count) {
    return 'Po lhůtě · $count';
  }

  @override
  String apayFilterActive(Object query) {
    return 'filtr: „$query\"';
  }

  @override
  String get apayEmpty => 'Žádné platby pro vybraný filtr.';

  @override
  String apayReminderMessage(Object amount) {
    return 'Připomínka platby $amount Kč — pošlu QR. Dík.';
  }

  @override
  String get apayToastReminderSent => 'Připomínka odeslána';

  @override
  String get apayRemind => 'Připomenout';

  @override
  String get apayMarkPaid => 'Označit zaplaceno';

  @override
  String apayRecordsHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů · datum ↓',
      few: '$count záznamy · datum ↓',
      one: '$count záznam · datum ↓',
    );
    return '$_temp0';
  }

  @override
  String get apprTitle => 'Schvalování';

  @override
  String get apprNewApplicant => 'NOVÝ ŽADATEL';

  @override
  String get apprEmail => 'E-mail';

  @override
  String get apprPhone => 'Telefon';

  @override
  String get apprTariff => 'Tarif';

  @override
  String get apprGdprConsent => 'GDPR souhlas';

  @override
  String get apprIsicCard => 'ISIC PRŮKAZ';

  @override
  String get apprTapToEnlarge => 'tap pro zvětšení';

  @override
  String get apprCheckPrefix => 'Zkontroluj: ';

  @override
  String get apprApplicantNote => 'POZNÁMKA OD ŽADATELE';

  @override
  String get apprReject => 'Zamítnout';

  @override
  String get apprApprove => 'Schválit';

  @override
  String apprRejectedToast(Object name) {
    return 'Zamítnuto · $name';
  }

  @override
  String apprApprovedToast(Object name) {
    return '$name přidána mezi členy';
  }

  @override
  String athrTemplatePaymentReminder(Object amount) {
    return 'Připomínka platby $amount Kč. Pošlu QR.';
  }

  @override
  String athrTemplateExpiringSoon(Object name) {
    return 'Ahoj $name, končí ti za pár dní. Chceš prodloužit?';
  }

  @override
  String get athrTemplateDropBy => 'Stavím se zítra v Klubu.';

  @override
  String get athrTemplateThanksGot => 'Díky, mám.';

  @override
  String get athrContextOverdue => 'Platba po lhůtě · prodlení';

  @override
  String get athrEmptyState => 'Začni první zprávou.';

  @override
  String athrComposerHint(Object name) {
    return 'Napiš $name…';
  }

  @override
  String athrExpiresIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Členství končí za $count dní',
      few: 'Členství končí za $count dny',
      one: 'Členství končí za $count den',
    );
    return '$_temp0';
  }

  @override
  String get bcastHeader => 'Hromadná zpráva';

  @override
  String get bcastTargetActive => 'Všem aktivním';

  @override
  String get bcastTargetOverdue => 'Dlužníkům';

  @override
  String get bcastTargetEnding => 'Končícím';

  @override
  String get bcastTargetAll => 'Všem členům';

  @override
  String get bcastSectionRecipients => 'PŘÍJEMCI';

  @override
  String get bcastSectionMessage => 'ZPRÁVA';

  @override
  String get bcastSectionTemplates => 'ŠABLONY';

  @override
  String get bcastSectionPreview => 'NÁHLED';

  @override
  String get bcastTitleHint => 'Titulek (volitelné)';

  @override
  String get bcastBodyHint => 'Napiš zprávu členům…';

  @override
  String get bcastPreviewBadge => 'INFO · NÁSTĚNKA';

  @override
  String get bcastPreviewNoTitle => 'Bez titulku';

  @override
  String get bcastPreviewBodyPlaceholder => 'Tady se zobrazí text zprávy.';

  @override
  String bcastSendLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count členům',
      few: '$count členům',
      one: '$count člen',
    );
    return 'Odeslat · $_temp0';
  }

  @override
  String bcastSentToast(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count členům',
      few: '$count členům',
      one: '$count členovi',
    );
    return 'Odesláno · $_temp0';
  }

  @override
  String get mdetTitle => 'Detail člena';

  @override
  String mdetStateActive(Object days) {
    return 'Aktivní · $days dní';
  }

  @override
  String mdetStateEnding(Object days) {
    return 'Končí za $days dní';
  }

  @override
  String mdetStateOverdue(Object days) {
    return 'Po lhůtě · $days dní';
  }

  @override
  String get mdetStateSuspended => 'Pozastaveno';

  @override
  String mdetMemberSince(Object date) {
    return 'člen od $date';
  }

  @override
  String get mdetQuickMessage => 'Zpráva';

  @override
  String get mdetQuickPayment => 'Platba';

  @override
  String get mdetQuickExtend => 'Prodloužit';

  @override
  String get mdetKvEmail => 'E-mail';

  @override
  String get mdetKvPhone => 'Telefon';

  @override
  String get mdetKvTariff => 'Tarif';

  @override
  String get mdetKvPricePerMonth => 'Cena/měs.';

  @override
  String get mdetKvPaidUntil => 'Platí do';

  @override
  String get mdetCustomBadge => 'VLASTNÍ';

  @override
  String mdetAlertOverdue(Object days) {
    return 'Platba $days dní po lhůtě';
  }

  @override
  String get mdetWrite => 'Napsat';

  @override
  String get mdetSectionKeyDeposit => 'Klíč & kauce';

  @override
  String get mdetKey => 'Klíč';

  @override
  String mdetKeyIssued(Object date) {
    return 'vydán $date';
  }

  @override
  String get mdetKeyWithMember => 'U člena';

  @override
  String get mdetDeposit => 'Kauce';

  @override
  String get mdetDepositReceived => 'Přijata';

  @override
  String get mdetMarkReturned => 'Označit jako vrácený';

  @override
  String get mdetSectionPayments => 'Platby';

  @override
  String mdetPaymentsSince(Object date) {
    return 'od $date';
  }

  @override
  String get mdetNoPayments => 'Zatím žádné platby.';

  @override
  String get mdetManualPayment => 'Manuální platba (cash)';

  @override
  String get mdetSectionActions => 'Akce';

  @override
  String get mdetSuspendLabel => 'Pozastavit členství';

  @override
  String get mdetSuspendSub =>
      'Členství zůstane v systému, neeviduje se platba';

  @override
  String get mdetDeleteLabel => 'Smazat člena';

  @override
  String get mdetDeleteSub => 'Nevratná akce, vyžaduje potvrzení';

  @override
  String get mdetDeleteDialogTitle => 'Smazat člena?';

  @override
  String mdetDeleteDialogBody(Object name) {
    return 'Opravdu chceš smazat $name? Nevratná akce.';
  }

  @override
  String get mdetDeleteDialogCancel => 'Zrušit';

  @override
  String get mdetDeleteDialogConfirm => 'Smazat';

  @override
  String get mlistTitle => 'Členové';

  @override
  String mlistSubtitle(Object active, Object attention, Object total) {
    return '$total celkem · $active aktivní · $attention potřebuje pozornost';
  }

  @override
  String get mlistSearchHint => 'Hledat člena, telefon, e-mail…';

  @override
  String mlistChipAll(Object count) {
    return 'Vše · $count';
  }

  @override
  String mlistChipActive(Object count) {
    return 'Aktivní $count';
  }

  @override
  String mlistChipEnding(Object count) {
    return 'Končí $count';
  }

  @override
  String mlistChipOverdue(Object count) {
    return 'Po lhůtě $count';
  }

  @override
  String get mlistSortLabelExpiration => 'expirace';

  @override
  String get mlistSortLabelName => 'jméno';

  @override
  String get mlistSortLabelTariff => 'tarif';

  @override
  String mlistEmptySearch(Object query) {
    return 'Nikdo neodpovídá \"$query\"';
  }

  @override
  String get mlistEmptyFilter => 'Žádní členové pro vybraný filtr.';

  @override
  String mlistMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count členů',
      few: '$count členové',
      one: '$count člen',
    );
    return '$_temp0';
  }

  @override
  String get mlistDaysSuspended => 'pozastaveno';

  @override
  String mlistDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'před $count dny',
      few: 'před $count dny',
      one: 'před $count dnem',
    );
    return '$_temp0';
  }

  @override
  String mlistDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní',
      few: '$count dny',
      one: '$count den',
    );
    return '$_temp0';
  }

  @override
  String get mlistRowUntilExpiry => 'do expirace';

  @override
  String get mlistRowEnding => 'končí';

  @override
  String get mlistRowOverdue => 'po lhůtě';

  @override
  String get mlistRow30Plus => '30+ dní';

  @override
  String get mlistRowKey => 'klíč';

  @override
  String get mlistRowNoKey => 'bez klíče';

  @override
  String get mlistSheetTitle => 'Filtr a řazení';

  @override
  String get mlistSheetReset => 'resetovat';

  @override
  String get mlistSheetSortBy => 'Řadit podle';

  @override
  String get mlistSortOptExpirationTitle => 'Expirace';

  @override
  String get mlistSortOptExpirationDesc => 'kdo končí nejdřív';

  @override
  String get mlistSortOptNameTitle => 'Jméno';

  @override
  String get mlistSortOptNameDesc => 'abecedně';

  @override
  String get mlistSortOptTariffTitle => 'Tarif';

  @override
  String get mlistSortOptTariffDesc => 'Standard / Student';

  @override
  String get mlistSheetAscending => 'Vzestupně';

  @override
  String get mlistSheetDescending => 'Sestupně';

  @override
  String get mlistSheetTapToToggle => 'Klepni pro otočení';

  @override
  String get mlistSheetTariff => 'Tarif';

  @override
  String get mlistTariffOptBoth => 'Oba';

  @override
  String get mlistSheetKey => 'Klíč';

  @override
  String get mlistKeyOptAll => 'Všichni';

  @override
  String get mlistKeyOptWith => 'S klíčem';

  @override
  String get mlistKeyOptWithout => 'Bez klíče';

  @override
  String get mlistSheetApply => 'Použít';
}
