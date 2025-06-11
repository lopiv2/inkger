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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @quote_1.
  ///
  /// In en, this message translates to:
  /// **'The saddest aspect of life right now is that science gathers knowledge faster than society gathers wisdom. — Isaac Asimov'**
  String get quote_1;

  /// No description provided for @quote_2.
  ///
  /// In en, this message translates to:
  /// **'It is our choices, Harry, that show what we truly are, far more than our abilities. — J.K. Rowling'**
  String get quote_2;

  /// No description provided for @quote_3.
  ///
  /// In en, this message translates to:
  /// **'Not all those who wander are lost. — J.R.R. Tolkien'**
  String get quote_3;

  /// No description provided for @quote_4.
  ///
  /// In en, this message translates to:
  /// **'We are such stuff as dreams are made on. — William Shakespeare'**
  String get quote_4;

  /// No description provided for @quote_5.
  ///
  /// In en, this message translates to:
  /// **'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife. — Jane Austen'**
  String get quote_5;

  /// No description provided for @quote_6.
  ///
  /// In en, this message translates to:
  /// **'The man who does not read has no advantage over the man who cannot read. — Mark Twain'**
  String get quote_6;

  /// No description provided for @quote_7.
  ///
  /// In en, this message translates to:
  /// **'So it goes. — Kurt Vonnegut'**
  String get quote_7;

  /// No description provided for @quote_8.
  ///
  /// In en, this message translates to:
  /// **'Whatever our souls are made of, his and mine are the same. — Emily Brontë'**
  String get quote_8;

  /// No description provided for @quote_9.
  ///
  /// In en, this message translates to:
  /// **'All animals are equal, but some animals are more equal than others. — George Orwell'**
  String get quote_9;

  /// No description provided for @quote_10.
  ///
  /// In en, this message translates to:
  /// **'Hell is empty and all the devils are here. — William Shakespeare'**
  String get quote_10;

  /// No description provided for @quote_11.
  ///
  /// In en, this message translates to:
  /// **'Do not pity the dead, Harry. Pity the living. — J.K. Rowling'**
  String get quote_11;

  /// No description provided for @quote_12.
  ///
  /// In en, this message translates to:
  /// **'You can’t get a cup of tea big enough or a book long enough to suit me. — C.S. Lewis'**
  String get quote_12;

  /// No description provided for @quote_13.
  ///
  /// In en, this message translates to:
  /// **'There is no friend as loyal as a book. — Ernest Hemingway'**
  String get quote_13;

  /// No description provided for @quote_14.
  ///
  /// In en, this message translates to:
  /// **'A room without books is like a body without a soul. — Cicero'**
  String get quote_14;

  /// No description provided for @quote_15.
  ///
  /// In en, this message translates to:
  /// **'Until I feared I would lose it, I never loved to read. One does not love breathing. — Harper Lee'**
  String get quote_15;

  /// No description provided for @quote_16.
  ///
  /// In en, this message translates to:
  /// **'Two things are infinite: the universe and human stupidity; and I\'m not sure about the universe. — Albert Einstein'**
  String get quote_16;

  /// No description provided for @quote_17.
  ///
  /// In en, this message translates to:
  /// **'I have always imagined that Paradise will be a kind of library. — Jorge Luis Borges'**
  String get quote_17;

  /// No description provided for @quote_18.
  ///
  /// In en, this message translates to:
  /// **'Reading is essential for those who seek to rise above the ordinary. — Jim Rohn'**
  String get quote_18;

  /// No description provided for @quote_19.
  ///
  /// In en, this message translates to:
  /// **'Fairy tales are more than true... — Neil Gaiman'**
  String get quote_19;

  /// No description provided for @quote_20.
  ///
  /// In en, this message translates to:
  /// **'Even the darkest night will end and the sun will rise. — Victor Hugo'**
  String get quote_20;

  /// No description provided for @quote_21.
  ///
  /// In en, this message translates to:
  /// **'The world is indeed full of peril and in it there are many dark places. — J.R.R. Tolkien'**
  String get quote_21;

  /// No description provided for @quote_22.
  ///
  /// In en, this message translates to:
  /// **'To be, or not to be, that is the question. — William Shakespeare'**
  String get quote_22;

  /// No description provided for @quote_23.
  ///
  /// In en, this message translates to:
  /// **'Words are, in my not-so-humble opinion, our most inexhaustible source of magic. — J.K. Rowling'**
  String get quote_23;

  /// No description provided for @quote_24.
  ///
  /// In en, this message translates to:
  /// **'Fear cuts deeper than swords. — George R.R. Martin'**
  String get quote_24;

  /// No description provided for @quote_25.
  ///
  /// In en, this message translates to:
  /// **'Books are a uniquely portable magic. — Stephen King'**
  String get quote_25;

  /// No description provided for @quote_26.
  ///
  /// In en, this message translates to:
  /// **'You don’t have to burn books to destroy a culture. Just get people to stop reading them. — Ray Bradbury'**
  String get quote_26;

  /// No description provided for @quote_27.
  ///
  /// In en, this message translates to:
  /// **'There is some good in this world, and it’s worth fighting for. — J.R.R. Tolkien'**
  String get quote_27;

  /// No description provided for @quote_28.
  ///
  /// In en, this message translates to:
  /// **'All that is gold does not glitter. — J.R.R. Tolkien'**
  String get quote_28;

  /// No description provided for @quote_29.
  ///
  /// In en, this message translates to:
  /// **'We read to know we’re not alone. — William Nicholson'**
  String get quote_29;

  /// No description provided for @quote_30.
  ///
  /// In en, this message translates to:
  /// **'I am no bird; and no net ensnares me. — Charlotte Brontë'**
  String get quote_30;

  /// No description provided for @quote_31.
  ///
  /// In en, this message translates to:
  /// **'Life is either a daring adventure or nothing. — Helen Keller'**
  String get quote_31;

  /// No description provided for @quote_32.
  ///
  /// In en, this message translates to:
  /// **'Nothing will work unless you do. — Maya Angelou'**
  String get quote_32;

  /// No description provided for @quote_33.
  ///
  /// In en, this message translates to:
  /// **'You can never get a cup of tea large enough or a book long enough to suit me. — C.S. Lewis'**
  String get quote_33;

  /// No description provided for @quote_34.
  ///
  /// In en, this message translates to:
  /// **'He that loves reading has everything within his reach. — William Godwin'**
  String get quote_34;

  /// No description provided for @quote_35.
  ///
  /// In en, this message translates to:
  /// **'Books are mirrors: you only see in them what you already have inside you. — Carlos Ruiz Zafón'**
  String get quote_35;

  /// No description provided for @quote_36.
  ///
  /// In en, this message translates to:
  /// **'We tell ourselves stories in order to live. — Joan Didion'**
  String get quote_36;

  /// No description provided for @quote_37.
  ///
  /// In en, this message translates to:
  /// **'I write to discover what I know. — Flannery O’Connor'**
  String get quote_37;

  /// No description provided for @quote_38.
  ///
  /// In en, this message translates to:
  /// **'Reading gives us someplace to go when we have to stay where we are. — Mason Cooley'**
  String get quote_38;

  /// No description provided for @quote_39.
  ///
  /// In en, this message translates to:
  /// **'What really knocks me out is a book that, when you\'re all done reading it, you wish the author that wrote it was a terrific friend of yours. — J.D. Salinger'**
  String get quote_39;

  /// No description provided for @quote_40.
  ///
  /// In en, this message translates to:
  /// **'A reader lives a thousand lives before he dies. — George R.R. Martin'**
  String get quote_40;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @audiobooks.
  ///
  /// In en, this message translates to:
  /// **'Audiobooks'**
  String get audiobooks;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @ascendingOrder.
  ///
  /// In en, this message translates to:
  /// **'Ascending order'**
  String get ascendingOrder;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cantOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link'**
  String get cantOpenLink;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @creationDate.
  ///
  /// In en, this message translates to:
  /// **'Date of creation'**
  String get creationDate;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createUser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get createUser;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @descendingOrder.
  ///
  /// In en, this message translates to:
  /// **'Descending order'**
  String get descendingOrder;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @documentLoaded.
  ///
  /// In en, this message translates to:
  /// **'Document loaded'**
  String get documentLoaded;

  /// No description provided for @documentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading a document...'**
  String get documentLoading;

  /// No description provided for @documentFormats.
  ///
  /// In en, this message translates to:
  /// **'Document formats'**
  String get documentFormats;

  /// No description provided for @documentSaved.
  ///
  /// In en, this message translates to:
  /// **'Document saved'**
  String get documentSaved;

  /// No description provided for @documentSavedError.
  ///
  /// In en, this message translates to:
  /// **'Error saving document'**
  String get documentSavedError;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editFeeds.
  ///
  /// In en, this message translates to:
  /// **'Edit feeds'**
  String get editFeeds;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @errorLoadingDocument.
  ///
  /// In en, this message translates to:
  /// **'Error loading document'**
  String get errorLoadingDocument;

  /// No description provided for @feeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get feeds;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @feedAdded.
  ///
  /// In en, this message translates to:
  /// **'Feed successfully added'**
  String get feedAdded;

  /// No description provided for @feedAddedError.
  ///
  /// In en, this message translates to:
  /// **'Error adding feed'**
  String get feedAddedError;

  /// No description provided for @feedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Feed successfully updated'**
  String get feedUpdated;

  /// No description provided for @feedUpdatedError.
  ///
  /// In en, this message translates to:
  /// **'Error updating feed'**
  String get feedUpdatedError;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @filesImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'New files successfully imported'**
  String get filesImportedSuccess;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @libraries.
  ///
  /// In en, this message translates to:
  /// **'Libraries'**
  String get libraries;

  /// No description provided for @listImportedError.
  ///
  /// In en, this message translates to:
  /// **'Error when creating the list'**
  String get listImportedError;

  /// No description provided for @listImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'List successfully created'**
  String get listImportedSuccess;

  /// No description provided for @listRenamedSuccess.
  ///
  /// In en, this message translates to:
  /// **'List successfully renamed'**
  String get listRenamedSuccess;

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged In'**
  String get loggedIn;

  /// No description provided for @loginAccount.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginAccount;

  /// No description provided for @metadataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated metadata'**
  String get metadataUpdated;

  /// No description provided for @missingComicVineApiKey.
  ///
  /// In en, this message translates to:
  /// **'Missing Comic Vine API key. Please add a key in the settings.'**
  String get missingComicVineApiKey;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @noSerie.
  ///
  /// In en, this message translates to:
  /// **'No series'**
  String get noSerie;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get preferencesSaved;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated'**
  String get profileSaved;

  /// No description provided for @profileSavedError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get profileSavedError;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @publishingDate.
  ///
  /// In en, this message translates to:
  /// **'Date of publication'**
  String get publishingDate;

  /// No description provided for @readBooks.
  ///
  /// In en, this message translates to:
  /// **'Items read'**
  String get readBooks;

  /// No description provided for @readingLists.
  ///
  /// In en, this message translates to:
  /// **'Reading Lists'**
  String get readingLists;

  /// No description provided for @readingListsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reading lists'**
  String get readingListsEmpty;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @savedProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress saved'**
  String get savedProgress;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get searching;

  /// No description provided for @searchingError.
  ///
  /// In en, this message translates to:
  /// **'Error searching'**
  String get searchingError;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get startSession;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @updateMetadata.
  ///
  /// In en, this message translates to:
  /// **'Update metadata'**
  String get updateMetadata;

  /// No description provided for @updateMetadataError.
  ///
  /// In en, this message translates to:
  /// **'Error updating metadata'**
  String get updateMetadataError;

  /// No description provided for @updateMetadataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Metadata successfully updated'**
  String get updateMetadataSuccess;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User successfully created'**
  String get userCreated;

  /// No description provided for @userCreatedError.
  ///
  /// In en, this message translates to:
  /// **'Error creating user'**
  String get userCreatedError;

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User successfully updated'**
  String get userUpdated;

  /// No description provided for @userUpdatedError.
  ///
  /// In en, this message translates to:
  /// **'Error updating user'**
  String get userUpdatedError;

  /// No description provided for @watchFeeds.
  ///
  /// In en, this message translates to:
  /// **'Watch feeds'**
  String get watchFeeds;
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
