import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
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
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

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
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In cs, this message translates to:
  /// **'BýtFit Klub'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In cs, this message translates to:
  /// **'Domů'**
  String get navHome;

  /// No description provided for @navCard.
  ///
  /// In cs, this message translates to:
  /// **'Karta'**
  String get navCard;

  /// No description provided for @navHistory.
  ///
  /// In cs, this message translates to:
  /// **'Historie'**
  String get navHistory;

  /// No description provided for @navBoard.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka'**
  String get navBoard;

  /// No description provided for @navProfile.
  ///
  /// In cs, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navOverview.
  ///
  /// In cs, this message translates to:
  /// **'Přehled'**
  String get navOverview;

  /// No description provided for @navMembers.
  ///
  /// In cs, this message translates to:
  /// **'Členové'**
  String get navMembers;

  /// No description provided for @navPayments.
  ///
  /// In cs, this message translates to:
  /// **'Platby'**
  String get navPayments;

  /// No description provided for @navMessages.
  ///
  /// In cs, this message translates to:
  /// **'Zprávy'**
  String get navMessages;

  /// No description provided for @navMore.
  ///
  /// In cs, this message translates to:
  /// **'Více'**
  String get navMore;

  /// No description provided for @personaTitle.
  ///
  /// In cs, this message translates to:
  /// **'BýtFit Klub'**
  String get personaTitle;

  /// No description provided for @personaSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyber, jak appku otevřít.'**
  String get personaSubtitle;

  /// No description provided for @personaOpenAsMember.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít jako člen'**
  String get personaOpenAsMember;

  /// No description provided for @personaOpenAsOwner.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít jako Olda (majitel)'**
  String get personaOpenAsOwner;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In cs, this message translates to:
  /// **'Vzhled & jazyk'**
  String get appearanceAndLanguage;

  /// No description provided for @themeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Téma'**
  String get themeLabel;

  /// No description provided for @themeDark.
  ///
  /// In cs, this message translates to:
  /// **'Tmavé'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In cs, this message translates to:
  /// **'Systém'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In cs, this message translates to:
  /// **'Světlé'**
  String get themeLight;

  /// No description provided for @languageLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jazyk'**
  String get languageLabel;

  /// No description provided for @languageCs.
  ///
  /// In cs, this message translates to:
  /// **'Čeština'**
  String get languageCs;

  /// No description provided for @languageEn.
  ///
  /// In cs, this message translates to:
  /// **'Angličtina'**
  String get languageEn;

  /// No description provided for @actionSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get actionCancel;

  /// No description provided for @actionBack.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get actionBack;

  /// No description provided for @actionConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit'**
  String get actionConfirm;

  /// No description provided for @actionClose.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get actionClose;

  /// No description provided for @errLoadTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se načíst data'**
  String get errLoadTitle;

  /// No description provided for @errLoadBody.
  ///
  /// In cs, this message translates to:
  /// **'Zkontroluj připojení a zkus to znovu.'**
  String get errLoadBody;

  /// No description provided for @errRetry.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get errRetry;

  /// No description provided for @boardTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka'**
  String get boardTitle;

  /// No description provided for @boardSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Co se děje v Klubu'**
  String get boardSubtitle;

  /// No description provided for @boardStatusOpen.
  ///
  /// In cs, this message translates to:
  /// **'otevřeno'**
  String get boardStatusOpen;

  /// No description provided for @boardEmptyFilter.
  ///
  /// In cs, this message translates to:
  /// **'Pro tento filtr nic není.'**
  String get boardEmptyFilter;

  /// No description provided for @boardFilterAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get boardFilterAll;

  /// No description provided for @boardFilterOutage.
  ///
  /// In cs, this message translates to:
  /// **'Výpadky'**
  String get boardFilterOutage;

  /// No description provided for @boardFilterWarning.
  ///
  /// In cs, this message translates to:
  /// **'Pozor'**
  String get boardFilterWarning;

  /// No description provided for @boardFilterPromo.
  ///
  /// In cs, this message translates to:
  /// **'Akce'**
  String get boardFilterPromo;

  /// No description provided for @boardFilterEvent.
  ///
  /// In cs, this message translates to:
  /// **'Události'**
  String get boardFilterEvent;

  /// No description provided for @boardTypePinned.
  ///
  /// In cs, this message translates to:
  /// **'Připnuto'**
  String get boardTypePinned;

  /// No description provided for @boardTypeOutage.
  ///
  /// In cs, this message translates to:
  /// **'Mimo provoz'**
  String get boardTypeOutage;

  /// No description provided for @boardTypeWarning.
  ///
  /// In cs, this message translates to:
  /// **'Pozor'**
  String get boardTypeWarning;

  /// No description provided for @boardTypePromo.
  ///
  /// In cs, this message translates to:
  /// **'Akce'**
  String get boardTypePromo;

  /// No description provided for @boardTypeEvent.
  ///
  /// In cs, this message translates to:
  /// **'Událost'**
  String get boardTypeEvent;

  /// No description provided for @boardTypeFixed.
  ///
  /// In cs, this message translates to:
  /// **'Opraveno'**
  String get boardTypeFixed;

  /// No description provided for @boardTypeInfo.
  ///
  /// In cs, this message translates to:
  /// **'Info'**
  String get boardTypeInfo;

  /// No description provided for @cardJoinedSince.
  ///
  /// In cs, this message translates to:
  /// **'člen od {joined}'**
  String cardJoinedSince(Object joined);

  /// No description provided for @cardSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Členská karta'**
  String get cardSubtitle;

  /// No description provided for @cardKeyWithYou.
  ///
  /// In cs, this message translates to:
  /// **'Záloha 100 Kč uhrazena'**
  String get cardKeyWithYou;

  /// No description provided for @cardKeyAtReception.
  ///
  /// In cs, this message translates to:
  /// **'na recepci'**
  String get cardKeyAtReception;

  /// No description provided for @cardLabelStatus.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get cardLabelStatus;

  /// No description provided for @cardStatusActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get cardStatusActive;

  /// No description provided for @cardLabelValidUntil.
  ///
  /// In cs, this message translates to:
  /// **'Platí do'**
  String get cardLabelValidUntil;

  /// No description provided for @cardLabelTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get cardLabelTariff;

  /// No description provided for @cardTariffValue.
  ///
  /// In cs, this message translates to:
  /// **'{tariff} · 3 měs.'**
  String cardTariffValue(Object tariff);

  /// No description provided for @cardLabelKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč'**
  String get cardLabelKey;

  /// No description provided for @cardBrightnessTip.
  ///
  /// In cs, this message translates to:
  /// **'Když ukazuješ kartu Oldovi, zvyš jas obrazovky — čte se to líp.'**
  String get cardBrightnessTip;

  /// No description provided for @cardAddToWallet.
  ///
  /// In cs, this message translates to:
  /// **'Přidat do Walletu'**
  String get cardAddToWallet;

  /// No description provided for @dashGreeting.
  ///
  /// In cs, this message translates to:
  /// **'Ahoj, {name}.'**
  String dashGreeting(Object name);

  /// No description provided for @dashStatusHeadline.
  ///
  /// In cs, this message translates to:
  /// **'Do posilovny můžeš ještě'**
  String get dashStatusHeadline;

  /// No description provided for @dashDaysUnit.
  ///
  /// In cs, this message translates to:
  /// **'dní'**
  String get dashDaysUnit;

  /// No description provided for @dashExpiryDate.
  ///
  /// In cs, this message translates to:
  /// **'do 23. 6. 2026'**
  String get dashExpiryDate;

  /// No description provided for @dashExtendMembership.
  ///
  /// In cs, this message translates to:
  /// **'Prodloužit členství'**
  String get dashExtendMembership;

  /// No description provided for @dashReportFault.
  ///
  /// In cs, this message translates to:
  /// **'Nahlásit závadu'**
  String get dashReportFault;

  /// No description provided for @dashYourCard.
  ///
  /// In cs, this message translates to:
  /// **'Tvoje karta'**
  String get dashYourCard;

  /// No description provided for @dashRecentActivity.
  ///
  /// In cs, this message translates to:
  /// **'Poslední aktivity'**
  String get dashRecentActivity;

  /// No description provided for @dashAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get dashAll;

  /// No description provided for @dashBoard.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka'**
  String get dashBoard;

  /// No description provided for @dashBoardAll.
  ///
  /// In cs, this message translates to:
  /// **'vše →'**
  String get dashBoardAll;

  /// No description provided for @dashStatusActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get dashStatusActive;

  /// No description provided for @dashKeyWithYou.
  ///
  /// In cs, this message translates to:
  /// **'klíč u tebe'**
  String get dashKeyWithYou;

  /// No description provided for @dashPinned.
  ///
  /// In cs, this message translates to:
  /// **'PŘIPNUTO'**
  String get dashPinned;

  /// No description provided for @dashBoardTimeAgo.
  ///
  /// In cs, this message translates to:
  /// **'před 2 h'**
  String get dashBoardTimeAgo;

  /// No description provided for @dashBoardPostTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zítra zavřeno do 14:00'**
  String get dashBoardPostTitle;

  /// No description provided for @dashBoardPostBody.
  ///
  /// In cs, this message translates to:
  /// **'Revize elektroinstalace. Otevíráme po obědě. — Olda'**
  String get dashBoardPostBody;

  /// No description provided for @faultTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nahlásit závadu'**
  String get faultTitle;

  /// No description provided for @faultSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Co se pokazilo, co nejde? Pošli to Oldovi, on vyřídí.'**
  String get faultSubtitle;

  /// No description provided for @faultHint.
  ///
  /// In cs, this message translates to:
  /// **'Třeba: bench č. 2 má rozsekané lano nebo ve sprše č. 3 protéká kohoutek.'**
  String get faultHint;

  /// No description provided for @faultPhotosLabel.
  ///
  /// In cs, this message translates to:
  /// **'FOTKY'**
  String get faultPhotosLabel;

  /// No description provided for @faultAddPhoto.
  ///
  /// In cs, this message translates to:
  /// **'fotka'**
  String get faultAddPhoto;

  /// No description provided for @faultSubmit.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat'**
  String get faultSubmit;

  /// No description provided for @faultSentToast.
  ///
  /// In cs, this message translates to:
  /// **'Závada odeslána'**
  String get faultSentToast;

  /// No description provided for @faultMessageBody.
  ///
  /// In cs, this message translates to:
  /// **'Závada: {body}'**
  String faultMessageBody(Object body);

  /// No description provided for @faultPhotoOptional.
  ///
  /// In cs, this message translates to:
  /// **'volitelné'**
  String get faultPhotoOptional;

  /// No description provided for @faultPhotoCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} foto} few{{count} fotky} other{{count} fotek}}'**
  String faultPhotoCount(int count);

  /// No description provided for @histTitle.
  ///
  /// In cs, this message translates to:
  /// **'Historie'**
  String get histTitle;

  /// No description provided for @histSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Všechno, co se v Klubu stalo s tvým účtem.'**
  String get histSubtitle;

  /// No description provided for @histStatPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zaplaceno'**
  String get histStatPaid;

  /// No description provided for @histStatMemberSince.
  ///
  /// In cs, this message translates to:
  /// **'Člen od'**
  String get histStatMemberSince;

  /// No description provided for @histStatMonthsCount.
  ///
  /// In cs, this message translates to:
  /// **'{count} měsíců'**
  String histStatMonthsCount(int count);

  /// No description provided for @histFilterAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše · {count}'**
  String histFilterAll(int count);

  /// No description provided for @histFilterPayments.
  ///
  /// In cs, this message translates to:
  /// **'Platby · {count}'**
  String histFilterPayments(int count);

  /// No description provided for @histFilterKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč · {count}'**
  String histFilterKey(int count);

  /// No description provided for @histFilterAccount.
  ///
  /// In cs, this message translates to:
  /// **'Účet · {count}'**
  String histFilterAccount(int count);

  /// No description provided for @histEndNote.
  ///
  /// In cs, this message translates to:
  /// **'To je všechno. Účet máš od září 2025.'**
  String get histEndNote;

  /// No description provided for @histEmptyFilter.
  ///
  /// In cs, this message translates to:
  /// **'Pro tento filtr tu zatím nic není.'**
  String get histEmptyFilter;

  /// No description provided for @profMemberSince.
  ///
  /// In cs, this message translates to:
  /// **'člen od 9 · 2025'**
  String get profMemberSince;

  /// No description provided for @profActiveDays.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní · 23 dní'**
  String get profActiveDays;

  /// No description provided for @profSectionContact.
  ///
  /// In cs, this message translates to:
  /// **'Kontakt'**
  String get profSectionContact;

  /// No description provided for @profEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get profEmail;

  /// No description provided for @profPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get profPhone;

  /// No description provided for @profSectionMembership.
  ///
  /// In cs, this message translates to:
  /// **'Členství'**
  String get profSectionMembership;

  /// No description provided for @profTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get profTariff;

  /// No description provided for @profTariffValue.
  ///
  /// In cs, this message translates to:
  /// **'Standard · 3 měs.'**
  String get profTariffValue;

  /// No description provided for @profValidUntil.
  ///
  /// In cs, this message translates to:
  /// **'Platí do'**
  String get profValidUntil;

  /// No description provided for @profKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč'**
  String get profKey;

  /// No description provided for @profKeyValue.
  ///
  /// In cs, this message translates to:
  /// **'u tebe'**
  String get profKeyValue;

  /// No description provided for @profSectionNotifications.
  ///
  /// In cs, this message translates to:
  /// **'Notifikace'**
  String get profSectionNotifications;

  /// No description provided for @profPushLabel.
  ///
  /// In cs, this message translates to:
  /// **'Push notifikace'**
  String get profPushLabel;

  /// No description provided for @profPushSub.
  ///
  /// In cs, this message translates to:
  /// **'Konec členství, schválení žádostí'**
  String get profPushSub;

  /// No description provided for @profOutageLabel.
  ///
  /// In cs, this message translates to:
  /// **'Výpadky a zavírací doba'**
  String get profOutageLabel;

  /// No description provided for @profOutageSub.
  ///
  /// In cs, this message translates to:
  /// **'Když je v Klubu něco mimo provoz'**
  String get profOutageSub;

  /// No description provided for @profPromoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Akce a slevy'**
  String get profPromoLabel;

  /// No description provided for @profPromoSub.
  ///
  /// In cs, this message translates to:
  /// **'Občas, ne víc než 1× měsíčně'**
  String get profPromoSub;

  /// No description provided for @profSectionHelp.
  ///
  /// In cs, this message translates to:
  /// **'Pomoc'**
  String get profSectionHelp;

  /// No description provided for @profFaqLabel.
  ///
  /// In cs, this message translates to:
  /// **'FAQ'**
  String get profFaqLabel;

  /// No description provided for @profFaqSub.
  ///
  /// In cs, this message translates to:
  /// **'Časté otázky a pravidla Klubu'**
  String get profFaqSub;

  /// No description provided for @profWriteToOlda.
  ///
  /// In cs, this message translates to:
  /// **'Napsat Oldovi'**
  String get profWriteToOlda;

  /// No description provided for @profWriteToOldaSub.
  ///
  /// In cs, this message translates to:
  /// **'Odpovídá obvykle do hodiny'**
  String get profWriteToOldaSub;

  /// No description provided for @profPaused.
  ///
  /// In cs, this message translates to:
  /// **'Pozastaveno'**
  String get profPaused;

  /// No description provided for @profPauseLabel.
  ///
  /// In cs, this message translates to:
  /// **'Pozastavit členství'**
  String get profPauseLabel;

  /// No description provided for @profPauseSub.
  ///
  /// In cs, this message translates to:
  /// **'Dovolená nebo dlouhodobá nemoc'**
  String get profPauseSub;

  /// No description provided for @profPauseSubLocked.
  ///
  /// In cs, this message translates to:
  /// **'Půjde až na konci předplatného'**
  String get profPauseSubLocked;

  /// No description provided for @pauseLockedTitle.
  ///
  /// In cs, this message translates to:
  /// **'Teď to nejde'**
  String get pauseLockedTitle;

  /// No description provided for @pauseLockedBody.
  ///
  /// In cs, this message translates to:
  /// **'Sám si členství můžeš pozastavit až na konci předplatného. Potřebuješ pauzu dřív (dovolená, nemoc)? Napiš Oldovi, nastaví ti ji.'**
  String get pauseLockedBody;

  /// No description provided for @profResumeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit členství'**
  String get profResumeLabel;

  /// No description provided for @profResumeSub.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat tam, kde jsi přestal'**
  String get profResumeSub;

  /// No description provided for @profResumeByOwnerSub.
  ///
  /// In cs, this message translates to:
  /// **'Obnovení řeší Olda — napiš mu'**
  String get profResumeByOwnerSub;

  /// No description provided for @pauseSheetTitle.
  ///
  /// In cs, this message translates to:
  /// **'Pozastavit členství'**
  String get pauseSheetTitle;

  /// No description provided for @pauseSheetBody.
  ///
  /// In cs, this message translates to:
  /// **'Členství se zmrazí — zbývající dny ti zůstanou a začnou nabíhat znovu, až ho Olda obnoví. Platby teď neřešíš a kauce za klíč běží taky až po obnovení. Až se budeš chtít vrátit, napiš Oldovi — pustí tě zpátky.'**
  String get pauseSheetBody;

  /// No description provided for @pauseReasonHeading.
  ///
  /// In cs, this message translates to:
  /// **'Důvod (nepovinné)'**
  String get pauseReasonHeading;

  /// No description provided for @pauseReasonHoliday.
  ///
  /// In cs, this message translates to:
  /// **'Dovolená'**
  String get pauseReasonHoliday;

  /// No description provided for @pauseReasonIllness.
  ///
  /// In cs, this message translates to:
  /// **'Nemoc'**
  String get pauseReasonIllness;

  /// No description provided for @pauseReasonOther.
  ///
  /// In cs, this message translates to:
  /// **'Jiné'**
  String get pauseReasonOther;

  /// No description provided for @pauseConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Pozastavit členství'**
  String get pauseConfirm;

  /// No description provided for @pausedToast.
  ///
  /// In cs, this message translates to:
  /// **'Členství pozastaveno. Olda dostal zprávu.'**
  String get pausedToast;

  /// No description provided for @resumeSheetTitle.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit členství'**
  String get resumeSheetTitle;

  /// No description provided for @resumeSheetBody.
  ///
  /// In cs, this message translates to:
  /// **'Členství se zase rozběhne tam, kde jsi ho pozastavil. Zbývající dny ti zůstaly.'**
  String get resumeSheetBody;

  /// No description provided for @resumeConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit členství'**
  String get resumeConfirm;

  /// No description provided for @resumedToast.
  ///
  /// In cs, this message translates to:
  /// **'Členství obnoveno.'**
  String get resumedToast;

  /// No description provided for @pauseOwnerNotice.
  ///
  /// In cs, this message translates to:
  /// **'Pozastavil(a) jsem si členství. Důvod: {reason}'**
  String pauseOwnerNotice(Object reason);

  /// No description provided for @pauseOwnerNoticeNoReason.
  ///
  /// In cs, this message translates to:
  /// **'Pozastavil(a) jsem si členství.'**
  String get pauseOwnerNoticeNoReason;

  /// No description provided for @resumeOwnerNotice.
  ///
  /// In cs, this message translates to:
  /// **'Obnovil(a) jsem si členství.'**
  String get resumeOwnerNotice;

  /// No description provided for @resumeByOwnerNotice.
  ///
  /// In cs, this message translates to:
  /// **'Olda ti obnovil členství.'**
  String get resumeByOwnerNotice;

  /// No description provided for @mdetResumeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit členství'**
  String get mdetResumeLabel;

  /// No description provided for @mdetResumeSub.
  ///
  /// In cs, this message translates to:
  /// **'Zruší pauzu, zbývající dny doběhnou dál'**
  String get mdetResumeSub;

  /// No description provided for @profSignOut.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit'**
  String get profSignOut;

  /// No description provided for @profBuildInfo.
  ///
  /// In cs, this message translates to:
  /// **'BýtFit Klub · v1.0.0 · sestaveno 5/2026'**
  String get profBuildInfo;

  /// No description provided for @qrTitle.
  ///
  /// In cs, this message translates to:
  /// **'Platba'**
  String get qrTitle;

  /// No description provided for @qrTariffLabel.
  ///
  /// In cs, this message translates to:
  /// **'TARIF'**
  String get qrTariffLabel;

  /// No description provided for @qrHeadline.
  ///
  /// In cs, this message translates to:
  /// **'Naskenuj QR nebo si ho ulož'**
  String get qrHeadline;

  /// No description provided for @qrDetailAmount.
  ///
  /// In cs, this message translates to:
  /// **'Částka'**
  String get qrDetailAmount;

  /// No description provided for @qrDetailAccount.
  ///
  /// In cs, this message translates to:
  /// **'Účet'**
  String get qrDetailAccount;

  /// No description provided for @qrDetailVs.
  ///
  /// In cs, this message translates to:
  /// **'VS'**
  String get qrDetailVs;

  /// No description provided for @qrDetailMessage.
  ///
  /// In cs, this message translates to:
  /// **'Zpráva'**
  String get qrDetailMessage;

  /// No description provided for @qrSaveQr.
  ///
  /// In cs, this message translates to:
  /// **'Uložit QR'**
  String get qrSaveQr;

  /// No description provided for @qrCopy.
  ///
  /// In cs, this message translates to:
  /// **'Zkopírovat'**
  String get qrCopy;

  /// No description provided for @qrSaveHint.
  ///
  /// In cs, this message translates to:
  /// **'QR se uloží do Fotek. Otevři ho v bance přes „Naskenovat ze souboru\".'**
  String get qrSaveHint;

  /// No description provided for @qrToastMarkedPaid.
  ///
  /// In cs, this message translates to:
  /// **'Označeno jako zaplaceno'**
  String get qrToastMarkedPaid;

  /// No description provided for @qrPaidButton.
  ///
  /// In cs, this message translates to:
  /// **'Zaplatil jsem'**
  String get qrPaidButton;

  /// No description provided for @adashKicker.
  ///
  /// In cs, this message translates to:
  /// **'BÝTFIT ADMIN'**
  String get adashKicker;

  /// No description provided for @adashGreeting.
  ///
  /// In cs, this message translates to:
  /// **'Dobré ráno, Oldo.'**
  String get adashGreeting;

  /// No description provided for @adashStatActive.
  ///
  /// In cs, this message translates to:
  /// **'AKTIVNÍCH'**
  String get adashStatActive;

  /// No description provided for @adashStatActiveSub.
  ///
  /// In cs, this message translates to:
  /// **'z {total}'**
  String adashStatActiveSub(Object total);

  /// No description provided for @adashStatEndingSoon.
  ///
  /// In cs, this message translates to:
  /// **'KONČÍ ≤ 7 DNÍ'**
  String get adashStatEndingSoon;

  /// No description provided for @adashStatEndingSoonSub.
  ///
  /// In cs, this message translates to:
  /// **'členství'**
  String get adashStatEndingSoonSub;

  /// No description provided for @adashStatOverdue.
  ///
  /// In cs, this message translates to:
  /// **'PLATBY PO LHŮTĚ'**
  String get adashStatOverdue;

  /// No description provided for @adashStatOverdueSub.
  ///
  /// In cs, this message translates to:
  /// **'neuhrazené'**
  String get adashStatOverdueSub;

  /// No description provided for @adashStatRevenue.
  ///
  /// In cs, this message translates to:
  /// **'PŘÍJEM {period}'**
  String adashStatRevenue(Object period);

  /// No description provided for @adashCurrencyCzk.
  ///
  /// In cs, this message translates to:
  /// **'Kč'**
  String get adashCurrencyCzk;

  /// No description provided for @adashNeedsAttention.
  ///
  /// In cs, this message translates to:
  /// **'Vyžaduje pozornost'**
  String get adashNeedsAttention;

  /// No description provided for @adashAttnPending.
  ///
  /// In cs, this message translates to:
  /// **'{count} čekající registrace'**
  String adashAttnPending(Object count);

  /// No description provided for @adashAttnOverdue.
  ///
  /// In cs, this message translates to:
  /// **'{count} po lhůtě'**
  String adashAttnOverdue(Object count);

  /// No description provided for @adashAttnOverdueSub.
  ///
  /// In cs, this message translates to:
  /// **'{names} · zaplať co nejdřív'**
  String adashAttnOverdueSub(Object names);

  /// No description provided for @adashAttnEndingSoon.
  ///
  /// In cs, this message translates to:
  /// **'{count} končí brzy'**
  String adashAttnEndingSoon(Object count);

  /// No description provided for @adashAttnEndingSoonSub.
  ///
  /// In cs, this message translates to:
  /// **'Tento týden'**
  String get adashAttnEndingSoonSub;

  /// No description provided for @adashAttnAllClear.
  ///
  /// In cs, this message translates to:
  /// **'Nic nečeká — máš hotovo.'**
  String get adashAttnAllClear;

  /// No description provided for @adashQuickActions.
  ///
  /// In cs, this message translates to:
  /// **'Rychlé akce'**
  String get adashQuickActions;

  /// No description provided for @adashActionSendMessage.
  ///
  /// In cs, this message translates to:
  /// **'Poslat zprávu'**
  String get adashActionSendMessage;

  /// No description provided for @adashActionPayments.
  ///
  /// In cs, this message translates to:
  /// **'Platby'**
  String get adashActionPayments;

  /// No description provided for @adashActionAddMember.
  ///
  /// In cs, this message translates to:
  /// **'Přidat člena'**
  String get adashActionAddMember;

  /// No description provided for @adashRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Příjem'**
  String get adashRevenue;

  /// No description provided for @adashRevenueRange.
  ///
  /// In cs, this message translates to:
  /// **'6 měsíců'**
  String get adashRevenueRange;

  /// No description provided for @adashRevenueMonth.
  ///
  /// In cs, this message translates to:
  /// **'Kč · {month}'**
  String adashRevenueMonth(Object month);

  /// No description provided for @addmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nový člen'**
  String get addmTitle;

  /// No description provided for @addmTitleEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit člena'**
  String get addmTitleEdit;

  /// No description provided for @addmNoName.
  ///
  /// In cs, this message translates to:
  /// **'Bez jména'**
  String get addmNoName;

  /// No description provided for @addmMemberAddedToast.
  ///
  /// In cs, this message translates to:
  /// **'{name} přidán/a · {months} měs.'**
  String addmMemberAddedToast(Object months, Object name);

  /// No description provided for @addmMemberSavedToast.
  ///
  /// In cs, this message translates to:
  /// **'{name} · změny uloženy'**
  String addmMemberSavedToast(Object name);

  /// No description provided for @addmSectionBasic.
  ///
  /// In cs, this message translates to:
  /// **'Základní'**
  String get addmSectionBasic;

  /// No description provided for @addmFieldName.
  ///
  /// In cs, this message translates to:
  /// **'Jméno a příjmení'**
  String get addmFieldName;

  /// No description provided for @addmFieldNamePlaceholder.
  ///
  /// In cs, this message translates to:
  /// **'např. Pavel Novák'**
  String get addmFieldNamePlaceholder;

  /// No description provided for @addmFieldNameError.
  ///
  /// In cs, this message translates to:
  /// **'Vyplň jméno'**
  String get addmFieldNameError;

  /// No description provided for @addmFieldFirst.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get addmFieldFirst;

  /// No description provided for @addmFieldFirstPlaceholder.
  ///
  /// In cs, this message translates to:
  /// **'např. Pavel'**
  String get addmFieldFirstPlaceholder;

  /// No description provided for @addmFieldLast.
  ///
  /// In cs, this message translates to:
  /// **'Příjmení'**
  String get addmFieldLast;

  /// No description provided for @addmFieldLastPlaceholder.
  ///
  /// In cs, this message translates to:
  /// **'např. Novák'**
  String get addmFieldLastPlaceholder;

  /// No description provided for @addmFieldEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get addmFieldEmail;

  /// No description provided for @addmFieldPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get addmFieldPhone;

  /// No description provided for @addmContactRequired.
  ///
  /// In cs, this message translates to:
  /// **'Potřebuju aspoň e-mail nebo telefon.'**
  String get addmContactRequired;

  /// No description provided for @addmSectionTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get addmSectionTariff;

  /// No description provided for @addmTariffStandard.
  ///
  /// In cs, this message translates to:
  /// **'Standard'**
  String get addmTariffStandard;

  /// No description provided for @addmTariffStandardSub.
  ///
  /// In cs, this message translates to:
  /// **'750 Kč/měs'**
  String get addmTariffStandardSub;

  /// No description provided for @addmTariffStudent.
  ///
  /// In cs, this message translates to:
  /// **'Student'**
  String get addmTariffStudent;

  /// No description provided for @addmTariffStudentSub.
  ///
  /// In cs, this message translates to:
  /// **'500 Kč/měs · ISIC'**
  String get addmTariffStudentSub;

  /// No description provided for @addmHasIsic.
  ///
  /// In cs, this message translates to:
  /// **'Má ISIC'**
  String get addmHasIsic;

  /// No description provided for @addmHasIsicSub.
  ///
  /// In cs, this message translates to:
  /// **'Potřebuju vidět platnou kartu'**
  String get addmHasIsicSub;

  /// No description provided for @addmLength.
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get addmLength;

  /// No description provided for @addmMonths.
  ///
  /// In cs, this message translates to:
  /// **'{months} měs.'**
  String addmMonths(Object months);

  /// No description provided for @addmSectionPrice.
  ///
  /// In cs, this message translates to:
  /// **'Cena za měsíc'**
  String get addmSectionPrice;

  /// No description provided for @addmCustomPrice.
  ///
  /// In cs, this message translates to:
  /// **'Individuální cena'**
  String get addmCustomPrice;

  /// No description provided for @addmCustomPriceOnSub.
  ///
  /// In cs, this message translates to:
  /// **'Přepisuje standardní {price} Kč/měs'**
  String addmCustomPriceOnSub(Object price);

  /// No description provided for @addmCustomPriceOffSub.
  ///
  /// In cs, this message translates to:
  /// **'Použít standardní {price} Kč/měs'**
  String addmCustomPriceOffSub(Object price);

  /// No description provided for @addmSectionKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč & kauce'**
  String get addmSectionKey;

  /// No description provided for @addmIssueKey.
  ///
  /// In cs, this message translates to:
  /// **'Vydat klíč'**
  String get addmIssueKey;

  /// No description provided for @addmIssueKeySub.
  ///
  /// In cs, this message translates to:
  /// **'Kauce 100 Kč v hotovosti'**
  String get addmIssueKeySub;

  /// No description provided for @addmSubmit.
  ///
  /// In cs, this message translates to:
  /// **'Přidat člena'**
  String get addmSubmit;

  /// No description provided for @addmSubmitEdit.
  ///
  /// In cs, this message translates to:
  /// **'Uložit změny'**
  String get addmSubmitEdit;

  /// No description provided for @addmCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get addmCancel;

  /// No description provided for @addmSubtitleIsic.
  ///
  /// In cs, this message translates to:
  /// **' · ISIC'**
  String get addmSubtitleIsic;

  /// No description provided for @addmSubtitleCustomPrice.
  ///
  /// In cs, this message translates to:
  /// **' · vlastní cena'**
  String get addmSubtitleCustomPrice;

  /// No description provided for @addmCustomPriceLabel.
  ///
  /// In cs, this message translates to:
  /// **'Vlastní cena'**
  String get addmCustomPriceLabel;

  /// No description provided for @addmPerMonth.
  ///
  /// In cs, this message translates to:
  /// **'Kč/měs'**
  String get addmPerMonth;

  /// No description provided for @addmPriceError.
  ///
  /// In cs, this message translates to:
  /// **'Zadej částku větší než 0'**
  String get addmPriceError;

  /// No description provided for @addmCzk.
  ///
  /// In cs, this message translates to:
  /// **'{amount} Kč'**
  String addmCzk(Object amount);

  /// No description provided for @addmToPay.
  ///
  /// In cs, this message translates to:
  /// **'K zaplacení '**
  String get addmToPay;

  /// No description provided for @addmCzkUnit.
  ///
  /// In cs, this message translates to:
  /// **'Kč'**
  String get addmCzkUnit;

  /// No description provided for @amoreTitle.
  ///
  /// In cs, this message translates to:
  /// **'Více'**
  String get amoreTitle;

  /// No description provided for @amoreOwnerSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'majitel · BýtFit Klub'**
  String get amoreOwnerSubtitle;

  /// No description provided for @amoreSectionActivity.
  ///
  /// In cs, this message translates to:
  /// **'Aktivita'**
  String get amoreSectionActivity;

  /// No description provided for @amoreApprovalsLabel.
  ///
  /// In cs, this message translates to:
  /// **'Schvalování registrací'**
  String get amoreApprovalsLabel;

  /// No description provided for @amoreApprovalsSub.
  ///
  /// In cs, this message translates to:
  /// **'2 čekající žádosti'**
  String get amoreApprovalsSub;

  /// No description provided for @amoreBoardLabel.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka'**
  String get amoreBoardLabel;

  /// No description provided for @amoreBoardSub.
  ///
  /// In cs, this message translates to:
  /// **'Připnout, mimo provoz, akce'**
  String get amoreBoardSub;

  /// No description provided for @amoreBroadcastLabel.
  ///
  /// In cs, this message translates to:
  /// **'Hromadná zpráva všem'**
  String get amoreBroadcastLabel;

  /// No description provided for @amoreBroadcastSub.
  ///
  /// In cs, this message translates to:
  /// **'{count} členů'**
  String amoreBroadcastSub(Object count);

  /// No description provided for @amoreSectionClub.
  ///
  /// In cs, this message translates to:
  /// **'Klub'**
  String get amoreSectionClub;

  /// No description provided for @amoreTariffsLabel.
  ///
  /// In cs, this message translates to:
  /// **'Tarify a ceny'**
  String get amoreTariffsLabel;

  /// No description provided for @amoreTariffsSub.
  ///
  /// In cs, this message translates to:
  /// **'Standard 2 250 · Student 1 500 · 6m / 12m'**
  String get amoreTariffsSub;

  /// No description provided for @amoreHoursLabel.
  ///
  /// In cs, this message translates to:
  /// **'Otevírací doba'**
  String get amoreHoursLabel;

  /// No description provided for @amoreHoursSub.
  ///
  /// In cs, this message translates to:
  /// **'Po–Pá 6:00–22:00 · So–Ne 8:00–20:00'**
  String get amoreHoursSub;

  /// No description provided for @amoreKeysLabel.
  ///
  /// In cs, this message translates to:
  /// **'Klíče a kauce'**
  String get amoreKeysLabel;

  /// No description provided for @amoreKeysSub.
  ///
  /// In cs, this message translates to:
  /// **'34 vydaných · 2 propadlé kauce'**
  String get amoreKeysSub;

  /// No description provided for @amoreRulesLabel.
  ///
  /// In cs, this message translates to:
  /// **'Pravidla Klubu'**
  String get amoreRulesLabel;

  /// No description provided for @amoreRulesSub.
  ///
  /// In cs, this message translates to:
  /// **'Naposledy aktualizováno 3. 4. 2026'**
  String get amoreRulesSub;

  /// No description provided for @amoreSectionData.
  ///
  /// In cs, this message translates to:
  /// **'Data'**
  String get amoreSectionData;

  /// No description provided for @amoreExportLabel.
  ///
  /// In cs, this message translates to:
  /// **'Export plateb (CSV)'**
  String get amoreExportLabel;

  /// No description provided for @amoreExportSub.
  ///
  /// In cs, this message translates to:
  /// **'Pro účetnictví · poslední 12 měsíců'**
  String get amoreExportSub;

  /// No description provided for @amoreBackupLabel.
  ///
  /// In cs, this message translates to:
  /// **'Záloha databáze'**
  String get amoreBackupLabel;

  /// No description provided for @amoreBackupSub.
  ///
  /// In cs, this message translates to:
  /// **'Poslední záloha · dnes 03:00'**
  String get amoreBackupSub;

  /// No description provided for @amoreImportLabel.
  ///
  /// In cs, this message translates to:
  /// **'Import z Excelu'**
  String get amoreImportLabel;

  /// No description provided for @amoreImportSub.
  ///
  /// In cs, this message translates to:
  /// **'Migrace a opakovaný import s rozdílem'**
  String get amoreImportSub;

  /// No description provided for @ximpTitle.
  ///
  /// In cs, this message translates to:
  /// **'Import z Excelu'**
  String get ximpTitle;

  /// No description provided for @ximpStepOf.
  ///
  /// In cs, this message translates to:
  /// **'{step}/{total}'**
  String ximpStepOf(int step, int total);

  /// No description provided for @ximpPickTitle.
  ///
  /// In cs, this message translates to:
  /// **'Migrace ze seznamu členů'**
  String get ximpPickTitle;

  /// No description provided for @ximpPickBody.
  ///
  /// In cs, this message translates to:
  /// **'Nahraj aktuální Excel (seznam_clenu.xlsx). App ti ukáže, co je nové a co se změnilo — nic nepřepíše bez tvého potvrzení.'**
  String get ximpPickBody;

  /// No description provided for @ximpPickCta.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat soubor (.xlsx)'**
  String get ximpPickCta;

  /// No description provided for @ximpPickNote.
  ///
  /// In cs, this message translates to:
  /// **'Excel zůstává hlavní evidence. Import jde opakovat — stejný soubor nic nerozbije.'**
  String get ximpPickNote;

  /// No description provided for @ximpParsing.
  ///
  /// In cs, this message translates to:
  /// **'Čtu a porovnávám řádky…'**
  String get ximpParsing;

  /// No description provided for @ximpFieldName.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get ximpFieldName;

  /// No description provided for @ximpFieldEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get ximpFieldEmail;

  /// No description provided for @ximpFieldPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get ximpFieldPhone;

  /// No description provided for @ximpFieldTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get ximpFieldTariff;

  /// No description provided for @ximpFieldPrice.
  ///
  /// In cs, this message translates to:
  /// **'Cena za měsíc'**
  String get ximpFieldPrice;

  /// No description provided for @ximpFieldKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč'**
  String get ximpFieldKey;

  /// No description provided for @ximpMappingTitle.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Načten {count} řádek} few{Načteny {count} řádky} other{Načteno {count} řádků}}'**
  String ximpMappingTitle(int count);

  /// No description provided for @ximpMappingBody.
  ///
  /// In cs, this message translates to:
  /// **'Sloupce z Excelu napárované na pole v aplikaci. Co aplikace nezná, zůstává jen v Excelu.'**
  String get ximpMappingBody;

  /// No description provided for @ximpMappingCta.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat na rozdíl'**
  String get ximpMappingCta;

  /// No description provided for @ximpSumAdded.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} nový} few{{count} noví} other{{count} nových}}'**
  String ximpSumAdded(int count);

  /// No description provided for @ximpSumChanged.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} změna} few{{count} změny} other{{count} změn}}'**
  String ximpSumChanged(int count);

  /// No description provided for @ximpSumConflict.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} konflikt} few{{count} konflikty} other{{count} konfliktů}}'**
  String ximpSumConflict(int count);

  /// No description provided for @ximpSumUnchanged.
  ///
  /// In cs, this message translates to:
  /// **'{count} beze změny'**
  String ximpSumUnchanged(int count);

  /// No description provided for @ximpKindAdded.
  ///
  /// In cs, this message translates to:
  /// **'Nový'**
  String get ximpKindAdded;

  /// No description provided for @ximpKindChanged.
  ///
  /// In cs, this message translates to:
  /// **'Změna'**
  String get ximpKindChanged;

  /// No description provided for @ximpKindConflict.
  ///
  /// In cs, this message translates to:
  /// **'Konflikt'**
  String get ximpKindConflict;

  /// No description provided for @ximpKindUnchanged.
  ///
  /// In cs, this message translates to:
  /// **'Beze změny'**
  String get ximpKindUnchanged;

  /// No description provided for @ximpChangedFields.
  ///
  /// In cs, this message translates to:
  /// **'Mění se: {fields}'**
  String ximpChangedFields(Object fields);

  /// No description provided for @ximpIncludeNew.
  ///
  /// In cs, this message translates to:
  /// **'Přidat tohoto člena'**
  String get ximpIncludeNew;

  /// No description provided for @ximpApplyChange.
  ///
  /// In cs, this message translates to:
  /// **'Použít tuto změnu'**
  String get ximpApplyChange;

  /// No description provided for @ximpKeepApp.
  ///
  /// In cs, this message translates to:
  /// **'Appka'**
  String get ximpKeepApp;

  /// No description provided for @ximpTakeExcel.
  ///
  /// In cs, this message translates to:
  /// **'Excel'**
  String get ximpTakeExcel;

  /// No description provided for @ximpSkip.
  ///
  /// In cs, this message translates to:
  /// **'Přeskočit'**
  String get ximpSkip;

  /// No description provided for @ximpApplyCta.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Importovat {count} záznam} few{Importovat {count} záznamy} other{Importovat {count} záznamů}}'**
  String ximpApplyCta(int count);

  /// No description provided for @ximpDoneTitle.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get ximpDoneTitle;

  /// No description provided for @ximpDoneBody.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Zapsán {count} záznam do evidence.} few{Zapsány {count} záznamy do evidence.} other{Zapsáno {count} záznamů do evidence.}}'**
  String ximpDoneBody(int count);

  /// No description provided for @ximpDoneCta.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get ximpDoneCta;

  /// No description provided for @ximpDoneToast.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Import · {count} záznam} few{Import · {count} záznamy} other{Import · {count} záznamů}}'**
  String ximpDoneToast(int count);

  /// No description provided for @amoreSectionAccount.
  ///
  /// In cs, this message translates to:
  /// **'Účet'**
  String get amoreSectionAccount;

  /// No description provided for @amoreHelpLabel.
  ///
  /// In cs, this message translates to:
  /// **'Nápověda & FAQ'**
  String get amoreHelpLabel;

  /// No description provided for @amoreHelpSub.
  ///
  /// In cs, this message translates to:
  /// **'Pravidla aplikace, dotazy'**
  String get amoreHelpSub;

  /// No description provided for @amoreLogoutLabel.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit Oldu'**
  String get amoreLogoutLabel;

  /// No description provided for @amoreVersion.
  ///
  /// In cs, this message translates to:
  /// **'BÝTFIT KLUB · v1.0.0'**
  String get amoreVersion;

  /// No description provided for @amsgTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zprávy'**
  String get amsgTitle;

  /// No description provided for @amsgSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat ve zprávách…'**
  String get amsgSearchHint;

  /// No description provided for @amsgBulkAll.
  ///
  /// In cs, this message translates to:
  /// **'Hromadně všem'**
  String get amsgBulkAll;

  /// No description provided for @amsgRemindDebtors.
  ///
  /// In cs, this message translates to:
  /// **'Připomenout dlužníky'**
  String get amsgRemindDebtors;

  /// No description provided for @amsgPaymentReminderMsg.
  ///
  /// In cs, this message translates to:
  /// **'Připomínka platby — pošlu QR. Dík.'**
  String get amsgPaymentReminderMsg;

  /// No description provided for @amsgRemindersSent.
  ///
  /// In cs, this message translates to:
  /// **'Připomínky odeslány'**
  String get amsgRemindersSent;

  /// No description provided for @amsgThreadCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} vlákno} few{{count} vlákna} other{{count} vláken}}'**
  String amsgThreadCount(int count);

  /// No description provided for @amsgEmptySearch.
  ///
  /// In cs, this message translates to:
  /// **'Nikdo s \"{query}\"'**
  String amsgEmptySearch(String query);

  /// No description provided for @amsgEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné zprávy.'**
  String get amsgEmpty;

  /// No description provided for @amsgAllDone.
  ///
  /// In cs, this message translates to:
  /// **'Vše vyřízeno'**
  String get amsgAllDone;

  /// No description provided for @amsgUnreadCount.
  ///
  /// In cs, this message translates to:
  /// **'{count} nepřečteno'**
  String amsgUnreadCount(int count);

  /// No description provided for @amsgUnreadThreads.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} vlákno} few{{count} vlákna} other{{count} vláken}}'**
  String amsgUnreadThreads(int count);

  /// No description provided for @amsgSentToMembers.
  ///
  /// In cs, this message translates to:
  /// **'Odesláno · {count} členům'**
  String amsgSentToMembers(int count);

  /// No description provided for @amsgFromMePrefix.
  ///
  /// In cs, this message translates to:
  /// **'já →'**
  String get amsgFromMePrefix;

  /// No description provided for @amsgComposeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nová zpráva'**
  String get amsgComposeTitle;

  /// No description provided for @amsgComposeSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Komu napsat…'**
  String get amsgComposeSearchHint;

  /// No description provided for @amsgBroadcastTitle.
  ///
  /// In cs, this message translates to:
  /// **'Hromadná zpráva'**
  String get amsgBroadcastTitle;

  /// No description provided for @amsgBroadcastSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přistáne všem jako normální zpráva od Oldy'**
  String get amsgBroadcastSubtitle;

  /// No description provided for @amsgBroadcastTo.
  ///
  /// In cs, this message translates to:
  /// **'KOMU'**
  String get amsgBroadcastTo;

  /// No description provided for @amsgBroadcastTextHint.
  ///
  /// In cs, this message translates to:
  /// **'Co chtěš říct…'**
  String get amsgBroadcastTextHint;

  /// No description provided for @amsgSendButton.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat · {count, plural, one{{count} člen} few{{count} členové} other{{count} členů}}'**
  String amsgSendButton(int count);

  /// No description provided for @apayTitle.
  ///
  /// In cs, this message translates to:
  /// **'Platby'**
  String get apayTitle;

  /// No description provided for @apayToastExportReady.
  ///
  /// In cs, this message translates to:
  /// **'Export připraven'**
  String get apayToastExportReady;

  /// No description provided for @apayToastAddPayment.
  ///
  /// In cs, this message translates to:
  /// **'Přidat platbu'**
  String get apayToastAddPayment;

  /// No description provided for @apayMonthLabel.
  ///
  /// In cs, this message translates to:
  /// **'KVĚTEN 2026'**
  String get apayMonthLabel;

  /// No description provided for @apayYtd.
  ///
  /// In cs, this message translates to:
  /// **'YTD {amount}'**
  String apayYtd(Object amount);

  /// No description provided for @apayStatReceived.
  ///
  /// In cs, this message translates to:
  /// **'{count} přijato'**
  String apayStatReceived(Object count);

  /// No description provided for @apayStatPending.
  ///
  /// In cs, this message translates to:
  /// **'{count} čeká'**
  String apayStatPending(Object count);

  /// No description provided for @apayStatDebt.
  ///
  /// In cs, this message translates to:
  /// **'{amount} Kč dluh'**
  String apayStatDebt(Object amount);

  /// No description provided for @apaySearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat člena…'**
  String get apaySearchHint;

  /// No description provided for @apayFilterAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše · {count}'**
  String apayFilterAll(Object count);

  /// No description provided for @apayFilterReceived.
  ///
  /// In cs, this message translates to:
  /// **'Přijato · {count}'**
  String apayFilterReceived(Object count);

  /// No description provided for @apayFilterPending.
  ///
  /// In cs, this message translates to:
  /// **'Čeká · {count}'**
  String apayFilterPending(Object count);

  /// No description provided for @apayFilterOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Po lhůtě · {count}'**
  String apayFilterOverdue(Object count);

  /// No description provided for @apayFilterActive.
  ///
  /// In cs, this message translates to:
  /// **'filtr: „{query}\"'**
  String apayFilterActive(Object query);

  /// No description provided for @apayEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné platby pro vybraný filtr.'**
  String get apayEmpty;

  /// No description provided for @apayReminderMessage.
  ///
  /// In cs, this message translates to:
  /// **'Připomínka platby {amount} Kč — pošlu QR. Dík.'**
  String apayReminderMessage(Object amount);

  /// No description provided for @apayToastReminderSent.
  ///
  /// In cs, this message translates to:
  /// **'Připomínka odeslána'**
  String get apayToastReminderSent;

  /// No description provided for @apayRemind.
  ///
  /// In cs, this message translates to:
  /// **'Připomenout'**
  String get apayRemind;

  /// No description provided for @apayMarkPaid.
  ///
  /// In cs, this message translates to:
  /// **'Označit zaplaceno'**
  String get apayMarkPaid;

  /// No description provided for @apayToastMarkedPaid.
  ///
  /// In cs, this message translates to:
  /// **'Platba potvrzena'**
  String get apayToastMarkedPaid;

  /// No description provided for @apayToastPaymentAdded.
  ///
  /// In cs, this message translates to:
  /// **'Platba přidána'**
  String get apayToastPaymentAdded;

  /// No description provided for @apayToastActionFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se uložit. Zkus to znovu.'**
  String get apayToastActionFailed;

  /// No description provided for @apayAddTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přidat platbu'**
  String get apayAddTitle;

  /// No description provided for @apayAddMember.
  ///
  /// In cs, this message translates to:
  /// **'Člen'**
  String get apayAddMember;

  /// No description provided for @apayAddPickMember.
  ///
  /// In cs, this message translates to:
  /// **'Vyber člena'**
  String get apayAddPickMember;

  /// No description provided for @apayAddTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif a období'**
  String get apayAddTariff;

  /// No description provided for @apayAddSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit platbu'**
  String get apayAddSave;

  /// No description provided for @apayAddTariffOption.
  ///
  /// In cs, this message translates to:
  /// **'{tariff} · {months, plural, one{{months} měsíc} few{{months} měsíce} other{{months} měsíců}} · {amount} Kč'**
  String apayAddTariffOption(Object tariff, int months, Object amount);

  /// No description provided for @apayRecordsHeader.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} záznam · datum ↓} few{{count} záznamy · datum ↓} other{{count} záznamů · datum ↓}}'**
  String apayRecordsHeader(int count);

  /// No description provided for @apprTitle.
  ///
  /// In cs, this message translates to:
  /// **'Schvalování'**
  String get apprTitle;

  /// No description provided for @apprNewApplicant.
  ///
  /// In cs, this message translates to:
  /// **'NOVÝ ŽADATEL'**
  String get apprNewApplicant;

  /// No description provided for @apprEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get apprEmail;

  /// No description provided for @apprPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get apprPhone;

  /// No description provided for @apprTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get apprTariff;

  /// No description provided for @apprGdprConsent.
  ///
  /// In cs, this message translates to:
  /// **'GDPR souhlas'**
  String get apprGdprConsent;

  /// No description provided for @apprIsicCard.
  ///
  /// In cs, this message translates to:
  /// **'ISIC PRŮKAZ'**
  String get apprIsicCard;

  /// No description provided for @apprTapToEnlarge.
  ///
  /// In cs, this message translates to:
  /// **'tap pro zvětšení'**
  String get apprTapToEnlarge;

  /// No description provided for @apprCheckPrefix.
  ///
  /// In cs, this message translates to:
  /// **'Zkontroluj: '**
  String get apprCheckPrefix;

  /// No description provided for @apprEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Žádné čekající registrace'**
  String get apprEmptyTitle;

  /// No description provided for @apprEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Až se někdo zaregistruje svým jménem, objeví se tu ke schválení.'**
  String get apprEmptyBody;

  /// No description provided for @apprApplicantNote.
  ///
  /// In cs, this message translates to:
  /// **'POZNÁMKA OD ŽADATELE'**
  String get apprApplicantNote;

  /// No description provided for @apprReject.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnout'**
  String get apprReject;

  /// No description provided for @apprApprove.
  ///
  /// In cs, this message translates to:
  /// **'Schválit'**
  String get apprApprove;

  /// No description provided for @apprRejectedToast.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnuto · {name}'**
  String apprRejectedToast(Object name);

  /// No description provided for @apprApprovedToast.
  ///
  /// In cs, this message translates to:
  /// **'{name} přidána mezi členy'**
  String apprApprovedToast(Object name);

  /// No description provided for @athrTemplatePaymentReminder.
  ///
  /// In cs, this message translates to:
  /// **'Připomínka platby {amount} Kč. Pošlu QR.'**
  String athrTemplatePaymentReminder(Object amount);

  /// No description provided for @athrTemplateExpiringSoon.
  ///
  /// In cs, this message translates to:
  /// **'Ahoj {name}, končí ti za pár dní. Chceš prodloužit?'**
  String athrTemplateExpiringSoon(Object name);

  /// No description provided for @athrTemplateDropBy.
  ///
  /// In cs, this message translates to:
  /// **'Stavím se zítra v Klubu.'**
  String get athrTemplateDropBy;

  /// No description provided for @athrTemplateThanksGot.
  ///
  /// In cs, this message translates to:
  /// **'Díky, mám.'**
  String get athrTemplateThanksGot;

  /// No description provided for @athrContextOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Platba po lhůtě · prodlení'**
  String get athrContextOverdue;

  /// No description provided for @athrEmptyState.
  ///
  /// In cs, this message translates to:
  /// **'Začni první zprávou.'**
  String get athrEmptyState;

  /// No description provided for @athrComposerHint.
  ///
  /// In cs, this message translates to:
  /// **'Napiš {name}…'**
  String athrComposerHint(Object name);

  /// No description provided for @athrExpiresIn.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Členství končí za {count} den} few{Členství končí za {count} dny} other{Členství končí za {count} dní}}'**
  String athrExpiresIn(int count);

  /// No description provided for @bcastHeader.
  ///
  /// In cs, this message translates to:
  /// **'Hromadná zpráva'**
  String get bcastHeader;

  /// No description provided for @bcastTargetActive.
  ///
  /// In cs, this message translates to:
  /// **'Všem aktivním'**
  String get bcastTargetActive;

  /// No description provided for @bcastTargetOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Dlužníkům'**
  String get bcastTargetOverdue;

  /// No description provided for @bcastTargetEnding.
  ///
  /// In cs, this message translates to:
  /// **'Končícím'**
  String get bcastTargetEnding;

  /// No description provided for @bcastTargetAll.
  ///
  /// In cs, this message translates to:
  /// **'Všem členům'**
  String get bcastTargetAll;

  /// No description provided for @bcastSectionRecipients.
  ///
  /// In cs, this message translates to:
  /// **'PŘÍJEMCI'**
  String get bcastSectionRecipients;

  /// No description provided for @bcastSectionMessage.
  ///
  /// In cs, this message translates to:
  /// **'ZPRÁVA'**
  String get bcastSectionMessage;

  /// No description provided for @bcastSectionTemplates.
  ///
  /// In cs, this message translates to:
  /// **'ŠABLONY'**
  String get bcastSectionTemplates;

  /// No description provided for @bcastSectionPreview.
  ///
  /// In cs, this message translates to:
  /// **'NÁHLED'**
  String get bcastSectionPreview;

  /// No description provided for @bcastTitleHint.
  ///
  /// In cs, this message translates to:
  /// **'Titulek (volitelné)'**
  String get bcastTitleHint;

  /// No description provided for @bcastBodyHint.
  ///
  /// In cs, this message translates to:
  /// **'Napiš zprávu členům…'**
  String get bcastBodyHint;

  /// No description provided for @bcastPreviewBadge.
  ///
  /// In cs, this message translates to:
  /// **'INFO · NÁSTĚNKA'**
  String get bcastPreviewBadge;

  /// No description provided for @bcastPreviewNoTitle.
  ///
  /// In cs, this message translates to:
  /// **'Bez titulku'**
  String get bcastPreviewNoTitle;

  /// No description provided for @bcastPreviewBodyPlaceholder.
  ///
  /// In cs, this message translates to:
  /// **'Tady se zobrazí text zprávy.'**
  String get bcastPreviewBodyPlaceholder;

  /// No description provided for @bcastSendLabel.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat · {count, plural, one{{count} člen} few{{count} členům} other{{count} členům}}'**
  String bcastSendLabel(num count);

  /// No description provided for @bcastSentToast.
  ///
  /// In cs, this message translates to:
  /// **'Odesláno · {count, plural, one{{count} členovi} few{{count} členům} other{{count} členům}}'**
  String bcastSentToast(num count);

  /// No description provided for @mdetTitle.
  ///
  /// In cs, this message translates to:
  /// **'Detail člena'**
  String get mdetTitle;

  /// No description provided for @mdetStateActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní · {days} dní'**
  String mdetStateActive(Object days);

  /// No description provided for @mdetStateEnding.
  ///
  /// In cs, this message translates to:
  /// **'Končí za {days} dní'**
  String mdetStateEnding(Object days);

  /// No description provided for @mdetStateOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Po lhůtě · {days} dní'**
  String mdetStateOverdue(Object days);

  /// No description provided for @mdetStateSuspended.
  ///
  /// In cs, this message translates to:
  /// **'Pozastaveno'**
  String get mdetStateSuspended;

  /// No description provided for @mdetMemberSince.
  ///
  /// In cs, this message translates to:
  /// **'člen od {date}'**
  String mdetMemberSince(Object date);

  /// No description provided for @mdetQuickMessage.
  ///
  /// In cs, this message translates to:
  /// **'Zpráva'**
  String get mdetQuickMessage;

  /// No description provided for @mdetQuickPayment.
  ///
  /// In cs, this message translates to:
  /// **'Platba'**
  String get mdetQuickPayment;

  /// No description provided for @mdetQuickExtend.
  ///
  /// In cs, this message translates to:
  /// **'Prodloužit'**
  String get mdetQuickExtend;

  /// No description provided for @mdetKvEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get mdetKvEmail;

  /// No description provided for @mdetKvPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get mdetKvPhone;

  /// No description provided for @mdetKvTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get mdetKvTariff;

  /// No description provided for @mdetKvPricePerMonth.
  ///
  /// In cs, this message translates to:
  /// **'Cena/měs.'**
  String get mdetKvPricePerMonth;

  /// No description provided for @mdetKvPaidUntil.
  ///
  /// In cs, this message translates to:
  /// **'Platí do'**
  String get mdetKvPaidUntil;

  /// No description provided for @mdetCustomBadge.
  ///
  /// In cs, this message translates to:
  /// **'VLASTNÍ'**
  String get mdetCustomBadge;

  /// No description provided for @mdetAlertOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Platba {days} dní po lhůtě'**
  String mdetAlertOverdue(Object days);

  /// No description provided for @mdetWrite.
  ///
  /// In cs, this message translates to:
  /// **'Napsat'**
  String get mdetWrite;

  /// No description provided for @mdetSectionKeyDeposit.
  ///
  /// In cs, this message translates to:
  /// **'Klíč & kauce'**
  String get mdetSectionKeyDeposit;

  /// No description provided for @mdetKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč'**
  String get mdetKey;

  /// No description provided for @mdetKeyIssued.
  ///
  /// In cs, this message translates to:
  /// **'vydán {date}'**
  String mdetKeyIssued(Object date);

  /// No description provided for @mdetKeyWithMember.
  ///
  /// In cs, this message translates to:
  /// **'U člena'**
  String get mdetKeyWithMember;

  /// No description provided for @mdetDeposit.
  ///
  /// In cs, this message translates to:
  /// **'Kauce'**
  String get mdetDeposit;

  /// No description provided for @mdetDepositReceived.
  ///
  /// In cs, this message translates to:
  /// **'Přijata'**
  String get mdetDepositReceived;

  /// No description provided for @mdetMarkReturned.
  ///
  /// In cs, this message translates to:
  /// **'Označit jako vrácený'**
  String get mdetMarkReturned;

  /// No description provided for @mdetSectionPayments.
  ///
  /// In cs, this message translates to:
  /// **'Platby'**
  String get mdetSectionPayments;

  /// No description provided for @mdetPaymentsSince.
  ///
  /// In cs, this message translates to:
  /// **'od {date}'**
  String mdetPaymentsSince(Object date);

  /// No description provided for @mdetNoPayments.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné platby.'**
  String get mdetNoPayments;

  /// No description provided for @mdetManualPayment.
  ///
  /// In cs, this message translates to:
  /// **'Manuální platba (cash)'**
  String get mdetManualPayment;

  /// No description provided for @mdetSectionActions.
  ///
  /// In cs, this message translates to:
  /// **'Akce'**
  String get mdetSectionActions;

  /// No description provided for @mdetSuspendLabel.
  ///
  /// In cs, this message translates to:
  /// **'Pozastavit členství'**
  String get mdetSuspendLabel;

  /// No description provided for @mdetSuspendSub.
  ///
  /// In cs, this message translates to:
  /// **'Členství zůstane v systému, neeviduje se platba'**
  String get mdetSuspendSub;

  /// No description provided for @mdetDeleteLabel.
  ///
  /// In cs, this message translates to:
  /// **'Smazat člena'**
  String get mdetDeleteLabel;

  /// No description provided for @mdetDeleteSub.
  ///
  /// In cs, this message translates to:
  /// **'Nevratná akce, vyžaduje potvrzení'**
  String get mdetDeleteSub;

  /// No description provided for @mdetDeleteDialogTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat člena?'**
  String get mdetDeleteDialogTitle;

  /// No description provided for @mdetDeleteDialogBody.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chceš smazat {name}? Nevratná akce.'**
  String mdetDeleteDialogBody(Object name);

  /// No description provided for @mdetDeleteDialogCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get mdetDeleteDialogCancel;

  /// No description provided for @mdetDeleteDialogConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get mdetDeleteDialogConfirm;

  /// No description provided for @mlistTitle.
  ///
  /// In cs, this message translates to:
  /// **'Členové'**
  String get mlistTitle;

  /// No description provided for @mlistSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'{total} celkem · {active} aktivní · {attention} potřebuje pozornost'**
  String mlistSubtitle(Object active, Object attention, Object total);

  /// No description provided for @mlistSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat člena, telefon, e-mail…'**
  String get mlistSearchHint;

  /// No description provided for @mlistChipAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše · {count}'**
  String mlistChipAll(Object count);

  /// No description provided for @mlistChipActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní {count}'**
  String mlistChipActive(Object count);

  /// No description provided for @mlistChipEnding.
  ///
  /// In cs, this message translates to:
  /// **'Končí {count}'**
  String mlistChipEnding(Object count);

  /// No description provided for @mlistChipOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Po lhůtě {count}'**
  String mlistChipOverdue(Object count);

  /// No description provided for @mlistSortLabelExpiration.
  ///
  /// In cs, this message translates to:
  /// **'expirace'**
  String get mlistSortLabelExpiration;

  /// No description provided for @mlistSortLabelName.
  ///
  /// In cs, this message translates to:
  /// **'jméno'**
  String get mlistSortLabelName;

  /// No description provided for @mlistSortLabelTariff.
  ///
  /// In cs, this message translates to:
  /// **'tarif'**
  String get mlistSortLabelTariff;

  /// No description provided for @mlistEmptySearch.
  ///
  /// In cs, this message translates to:
  /// **'Nikdo neodpovídá \"{query}\"'**
  String mlistEmptySearch(Object query);

  /// No description provided for @mlistEmptyFilter.
  ///
  /// In cs, this message translates to:
  /// **'Žádní členové pro vybraný filtr.'**
  String get mlistEmptyFilter;

  /// No description provided for @mlistMemberCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} člen} few{{count} členové} other{{count} členů}}'**
  String mlistMemberCount(int count);

  /// No description provided for @mlistDaysSuspended.
  ///
  /// In cs, this message translates to:
  /// **'pozastaveno'**
  String get mlistDaysSuspended;

  /// No description provided for @mlistDaysAgo.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{před {count} dnem} few{před {count} dny} other{před {count} dny}}'**
  String mlistDaysAgo(int count);

  /// No description provided for @mlistDaysLeft.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} den} few{{count} dny} other{{count} dní}}'**
  String mlistDaysLeft(int count);

  /// No description provided for @mlistRowUntilExpiry.
  ///
  /// In cs, this message translates to:
  /// **'do expirace'**
  String get mlistRowUntilExpiry;

  /// No description provided for @mlistRowEnding.
  ///
  /// In cs, this message translates to:
  /// **'končí'**
  String get mlistRowEnding;

  /// No description provided for @mlistRowOverdue.
  ///
  /// In cs, this message translates to:
  /// **'po lhůtě'**
  String get mlistRowOverdue;

  /// No description provided for @mlistRow30Plus.
  ///
  /// In cs, this message translates to:
  /// **'30+ dní'**
  String get mlistRow30Plus;

  /// No description provided for @mlistRowKey.
  ///
  /// In cs, this message translates to:
  /// **'klíč'**
  String get mlistRowKey;

  /// No description provided for @mlistRowNoKey.
  ///
  /// In cs, this message translates to:
  /// **'bez klíče'**
  String get mlistRowNoKey;

  /// No description provided for @mlistSheetTitle.
  ///
  /// In cs, this message translates to:
  /// **'Filtr a řazení'**
  String get mlistSheetTitle;

  /// No description provided for @mlistSheetReset.
  ///
  /// In cs, this message translates to:
  /// **'resetovat'**
  String get mlistSheetReset;

  /// No description provided for @mlistSheetSortBy.
  ///
  /// In cs, this message translates to:
  /// **'Řadit podle'**
  String get mlistSheetSortBy;

  /// No description provided for @mlistSortOptExpirationTitle.
  ///
  /// In cs, this message translates to:
  /// **'Expirace'**
  String get mlistSortOptExpirationTitle;

  /// No description provided for @mlistSortOptExpirationDesc.
  ///
  /// In cs, this message translates to:
  /// **'kdo končí nejdřív'**
  String get mlistSortOptExpirationDesc;

  /// No description provided for @mlistSortOptNameTitle.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get mlistSortOptNameTitle;

  /// No description provided for @mlistSortOptNameDesc.
  ///
  /// In cs, this message translates to:
  /// **'abecedně'**
  String get mlistSortOptNameDesc;

  /// No description provided for @mlistSortOptTariffTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get mlistSortOptTariffTitle;

  /// No description provided for @mlistSortOptTariffDesc.
  ///
  /// In cs, this message translates to:
  /// **'Standard / Student'**
  String get mlistSortOptTariffDesc;

  /// No description provided for @mlistSheetAscending.
  ///
  /// In cs, this message translates to:
  /// **'Vzestupně'**
  String get mlistSheetAscending;

  /// No description provided for @mlistSheetDescending.
  ///
  /// In cs, this message translates to:
  /// **'Sestupně'**
  String get mlistSheetDescending;

  /// No description provided for @mlistSheetTapToToggle.
  ///
  /// In cs, this message translates to:
  /// **'Klepni pro otočení'**
  String get mlistSheetTapToToggle;

  /// No description provided for @mlistSheetTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get mlistSheetTariff;

  /// No description provided for @mlistTariffOptBoth.
  ///
  /// In cs, this message translates to:
  /// **'Oba'**
  String get mlistTariffOptBoth;

  /// No description provided for @mlistSheetKey.
  ///
  /// In cs, this message translates to:
  /// **'Klíč'**
  String get mlistSheetKey;

  /// No description provided for @mlistKeyOptAll.
  ///
  /// In cs, this message translates to:
  /// **'Všichni'**
  String get mlistKeyOptAll;

  /// No description provided for @mlistKeyOptWith.
  ///
  /// In cs, this message translates to:
  /// **'S klíčem'**
  String get mlistKeyOptWith;

  /// No description provided for @mlistKeyOptWithout.
  ///
  /// In cs, this message translates to:
  /// **'Bez klíče'**
  String get mlistKeyOptWithout;

  /// No description provided for @mlistSheetApply.
  ///
  /// In cs, this message translates to:
  /// **'Použít'**
  String get mlistSheetApply;

  /// No description provided for @mmsgTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zprávy'**
  String get mmsgTitle;

  /// No description provided for @mmsgAllRead.
  ///
  /// In cs, this message translates to:
  /// **'Vše přečteno'**
  String get mmsgAllRead;

  /// No description provided for @mmsgUnreadCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} nepřečtená} few{{count} nepřečtené} other{{count} nepřečtených}}'**
  String mmsgUnreadCount(int count);

  /// No description provided for @mmsgOwnerTag.
  ///
  /// In cs, this message translates to:
  /// **'PROVOZ'**
  String get mmsgOwnerTag;

  /// No description provided for @mmsgYouPrefix.
  ///
  /// In cs, this message translates to:
  /// **'Já:'**
  String get mmsgYouPrefix;

  /// No description provided for @mmsgNoMessagesYet.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné zprávy'**
  String get mmsgNoMessagesYet;

  /// No description provided for @mmsgComposeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nová zpráva'**
  String get mmsgComposeTitle;

  /// No description provided for @mmsgComposeSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat člena…'**
  String get mmsgComposeSearchHint;

  /// No description provided for @mthrOwnerName.
  ///
  /// In cs, this message translates to:
  /// **'Olda'**
  String get mthrOwnerName;

  /// No description provided for @mthrOwnerRole.
  ///
  /// In cs, this message translates to:
  /// **'Provozovatel · BýtFit Klub'**
  String get mthrOwnerRole;

  /// No description provided for @mthrMemberRole.
  ///
  /// In cs, this message translates to:
  /// **'člen'**
  String get mthrMemberRole;

  /// No description provided for @mthrEmptyOwner.
  ///
  /// In cs, this message translates to:
  /// **'Napiš Oldovi cokoliv — od dotazu k platbě po hlášení závady.'**
  String get mthrEmptyOwner;

  /// No description provided for @mthrEmptyPeer.
  ///
  /// In cs, this message translates to:
  /// **'Začni konverzaci s {name}.'**
  String mthrEmptyPeer(String name);

  /// No description provided for @mthrComposerHint.
  ///
  /// In cs, this message translates to:
  /// **'Napiš {name}…'**
  String mthrComposerHint(String name);

  /// No description provided for @authLoginTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vítej zpět'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přihlas se do BýtFit Klubu.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In cs, this message translates to:
  /// **'Heslo'**
  String get authPassword;

  /// No description provided for @authSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se'**
  String get authSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In cs, this message translates to:
  /// **'Nemáš účet?'**
  String get authNoAccount;

  /// No description provided for @authRegisterLink.
  ///
  /// In cs, this message translates to:
  /// **'Zaregistruj se'**
  String get authRegisterLink;

  /// No description provided for @authHaveAccount.
  ///
  /// In cs, this message translates to:
  /// **'Už máš účet?'**
  String get authHaveAccount;

  /// No description provided for @authLoginLink.
  ///
  /// In cs, this message translates to:
  /// **'Přihlas se'**
  String get authLoginLink;

  /// No description provided for @authRegisterTitle.
  ///
  /// In cs, this message translates to:
  /// **'Registrace'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Vytvoř si účet. Než tě Olda schválí, počkáš na potvrzení.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFirstName.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In cs, this message translates to:
  /// **'Příjmení'**
  String get authLastName;

  /// No description provided for @authPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get authPhone;

  /// No description provided for @authTariff.
  ///
  /// In cs, this message translates to:
  /// **'Tarif'**
  String get authTariff;

  /// No description provided for @authTariffStandard.
  ///
  /// In cs, this message translates to:
  /// **'Standard'**
  String get authTariffStandard;

  /// No description provided for @authTariffStudent.
  ///
  /// In cs, this message translates to:
  /// **'Student'**
  String get authTariffStudent;

  /// No description provided for @authStudentProof.
  ///
  /// In cs, this message translates to:
  /// **'ISIC / potvrzení o studiu'**
  String get authStudentProof;

  /// No description provided for @authStudentProofPick.
  ///
  /// In cs, this message translates to:
  /// **'Nahrát fotku'**
  String get authStudentProofPick;

  /// No description provided for @authStudentProofPicked.
  ///
  /// In cs, this message translates to:
  /// **'Příloha přidána'**
  String get authStudentProofPicked;

  /// No description provided for @authGdpr.
  ///
  /// In cs, this message translates to:
  /// **'Souhlasím se zpracováním osobních údajů (GDPR).'**
  String get authGdpr;

  /// No description provided for @authCreateAccount.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit účet'**
  String get authCreateAccount;

  /// No description provided for @authPendingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Čeká na schválení'**
  String get authPendingTitle;

  /// No description provided for @authPendingBody.
  ///
  /// In cs, this message translates to:
  /// **'Jakmile tě Olda ověří a předá ti klíč, dostaneš oznámení a uvidíš svoje členství.'**
  String get authPendingBody;

  /// No description provided for @authConfirmEmailTitle.
  ///
  /// In cs, this message translates to:
  /// **'Potvrď svůj e-mail'**
  String get authConfirmEmailTitle;

  /// No description provided for @authConfirmEmailBody.
  ///
  /// In cs, this message translates to:
  /// **'Poslali jsme ti potvrzovací odkaz. Po potvrzení se vrať a přihlas se.'**
  String get authConfirmEmailBody;

  /// No description provided for @authRefresh.
  ///
  /// In cs, this message translates to:
  /// **'Zkontrolovat znovu'**
  String get authRefresh;

  /// No description provided for @authSignOut.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit se'**
  String get authSignOut;

  /// No description provided for @authErrInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Nesprávný e-mail nebo heslo.'**
  String get authErrInvalid;

  /// No description provided for @authErrGeneric.
  ///
  /// In cs, this message translates to:
  /// **'Něco se nepovedlo. Zkus to znovu.'**
  String get authErrGeneric;

  /// No description provided for @authErrFields.
  ///
  /// In cs, this message translates to:
  /// **'Vyplň prosím všechna pole.'**
  String get authErrFields;

  /// No description provided for @authErrEmail.
  ///
  /// In cs, this message translates to:
  /// **'Zadej platný e-mail.'**
  String get authErrEmail;

  /// No description provided for @authErrPassword.
  ///
  /// In cs, this message translates to:
  /// **'Heslo musí mít alespoň 6 znaků.'**
  String get authErrPassword;

  /// No description provided for @authErrGdpr.
  ///
  /// In cs, this message translates to:
  /// **'Pro registraci musíš potvrdit souhlas s GDPR.'**
  String get authErrGdpr;

  /// No description provided for @authErrStudentProof.
  ///
  /// In cs, this message translates to:
  /// **'Pro studentský tarif nahraj ISIC nebo potvrzení o studiu.'**
  String get authErrStudentProof;

  /// No description provided for @authRegisteredTitle.
  ///
  /// In cs, this message translates to:
  /// **'Účet vytvořen'**
  String get authRegisteredTitle;

  /// No description provided for @authBusy.
  ///
  /// In cs, this message translates to:
  /// **'Pracuji…'**
  String get authBusy;

  /// No description provided for @authNameStepSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Zadej jméno a příjmení tak, jak tě má klub v evidenci.'**
  String get authNameStepSubtitle;

  /// No description provided for @authContinue.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get authContinue;

  /// No description provided for @authErrNotInRoster.
  ///
  /// In cs, this message translates to:
  /// **'Tohle jméno nemáme v evidenci klubu. Ozvi se Oldovi, ať tě přidá.'**
  String get authErrNotInRoster;

  /// No description provided for @authContactStepSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Sedí to. Doplň kontakt a heslo — Olda pak potvrdí přístup.'**
  String get authContactStepSubtitle;

  /// No description provided for @authEmailLogin.
  ///
  /// In cs, this message translates to:
  /// **'E-mail (pro přihlášení)'**
  String get authEmailLogin;

  /// No description provided for @authPhoneOptional.
  ///
  /// In cs, this message translates to:
  /// **'Telefon (nepovinné)'**
  String get authPhoneOptional;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return LCs();
    case 'en':
      return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
