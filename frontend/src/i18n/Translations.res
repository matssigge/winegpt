type errors = {
  authEmailTaken: string,
  authInvalidEmail: string,
  authPasswordTooShort: string,
  authInvalidCredentials: string,
  authGeneric: string,
  entryInvalidConsumedAt: string,
  entryInvalidRating: string,
  entryInvalidWineName: string,
  entryInvalidWineVintage: string,
  entryForbidden: string,
  entryGeneric: string,
  entryHistoryGeneric: string,
  wineInvalidName: string,
  wineInvalidVintage: string,
  wineForbidden: string,
  wineGeneric: string,
}

type t = {
  // Shell header / menu
  appWines: string,
  appSearchAriaOpen: string,
  appSearchAriaClose: string,
  appFilterAriaOpen: string,
  appFilterAriaClose: string,
  appMenuAriaOpen: string,
  appAddWineAriaLabel: string,
  appSignedIn: string,
  appLogOut: string,
  appLanguage: string,
  appLanguageSwedishLabel: string,
  appLanguageEnglishLabel: string,
  appLanguageBrowserDefault: string,
  appLanguageDetectedLabel: AppLocale.locale => string,
  appCheckingSession: string,

  // Filter panel
  filterAllWines: string,
  filterWithOccasions: string,
  filterWithoutOccasions: string,

  // Auth screen
  authBrand: string,
  authWelcomeBack: string,
  authCreateYourAccount: string,
  authLoginIntro: string,
  authRegisterIntro: string,
  authLogIn: string,
  authSignUp: string,
  authCreateAccount: string,
  authWorking: string,
  authFullName: string,
  authEmail: string,
  authPassword: string,

  // Wine list
  wineListEmptyTitle: string,
  wineListEmptyBody: string,
  wineListLoading: string,
  wineListErrorTitle: string,

  // Wine detail
  wineDetailBackAriaLabel: string,
  wineDetailDefaultTitle: string,
  wineDetailAddOccasion: string,
  wineDetailIdentity: string,
  wineDetailMemory: string,
  wineDetailMostRecent: string,
  wineDetailNameLabel: string,
  wineDetailEmptyOccasions: string,
  wineDetailOccasionsLabel: string,

  // Wine composer
  wineComposerScreenTitle: string,
  wineComposerCancelAriaLabel: string,
  wineComposerHelpText: string,
  wineComposerSaveLabel: string,
  wineComposerSavingLabel: string,
  wineComposerWineNameLabel: string,
  wineComposerProducerLabel: string,
  wineComposerStyleLabel: string,
  wineComposerGrapeLabel: string,
  wineComposerRegionLabel: string,
  wineComposerCountryLabel: string,
  wineComposerVintageLabel: string,

  // Entry composer
  entryComposerNewTitle: string,
  entryComposerEditTitle: string,
  entryComposerCancelAriaLabel: string,
  entryComposerSelectedWine: string,
  entryComposerDifferentWine: string,
  entryComposerUsing: string,
  entryComposerSaveCreate: string,
  entryComposerSaveEdit: string,
  entryComposerSavingLabel: string,
  entryComposerConsumedAtLabel: string,
  entryComposerVenueLabel: string,
  entryComposerLocationLabel: string,
  entryComposerPairingNotesLabel: string,
  entryComposerTastingNotesLabel: string,
  entryComposerRatingLabel: string,

  // Entry detail / history
  entryDetailHeading: string,
  entryDetailEmptyBody: string,
  entryDetailWineLabel: string,
  entryDetailOccasionLabel: string,
  entryDetailEditEntry: string,
  entryHistoryEmptyMessage: string,
  entryHistoryPairingPrefix: string,

  // Interpolations
  occasionCount: int => string,
  entryCount: int => string,
  rating: int => string,
  filteredOf: (int, int) => string,

  errors: errors,
}

let en: t = {
  appWines: "Wines",
  appSearchAriaOpen: "Search wines",
  appSearchAriaClose: "Close search",
  appFilterAriaOpen: "Filter wines",
  appFilterAriaClose: "Close filter",
  appMenuAriaOpen: "Open menu",
  appAddWineAriaLabel: "Add wine",
  appSignedIn: "Signed in",
  appLogOut: "Log out",
  appLanguage: "Language",
  appLanguageSwedishLabel: "Svenska",
  appLanguageEnglishLabel: "English",
  appLanguageBrowserDefault: "Use browser language",
  appLanguageDetectedLabel: locale =>
    switch locale {
    | AppLocale.En => "Detected: English"
    | AppLocale.Sv => "Detected: Swedish"
    },
  appCheckingSession: "Checking your session...",

  filterAllWines: "All wines",
  filterWithOccasions: "With occasions",
  filterWithoutOccasions: "No occasions yet",

  authBrand: "Wine",
  authWelcomeBack: "Welcome back",
  authCreateYourAccount: "Create your account",
  authLoginIntro: "Sign in to continue to your wine journal.",
  authRegisterIntro: "Start your wine journal with a personal account.",
  authLogIn: "Log in",
  authSignUp: "Sign up",
  authCreateAccount: "Create account",
  authWorking: "Working...",
  authFullName: "Full name",
  authEmail: "Email",
  authPassword: "Password",

  wineListEmptyTitle: "No wines yet",
  wineListEmptyBody: "Add your first bottle. You can record an occasion afterward.",
  wineListLoading: "Loading your wines...",
  wineListErrorTitle: "Wines",

  wineDetailBackAriaLabel: "Back to wines",
  wineDetailDefaultTitle: "Wine",
  wineDetailAddOccasion: "+ Add occasion",
  wineDetailIdentity: "Identity",
  wineDetailMemory: "Memory",
  wineDetailMostRecent: "Most recent",
  wineDetailNameLabel: "Name",
  wineDetailEmptyOccasions: "No occasions recorded yet.",
  wineDetailOccasionsLabel: "Occasions",

  wineComposerScreenTitle: "New wine",
  wineComposerCancelAriaLabel: "Cancel",
  wineComposerHelpText: "Add a bottle you want to remember now, then attach occasions later when they happen.",
  wineComposerSaveLabel: "Save wine",
  wineComposerSavingLabel: "Saving...",
  wineComposerWineNameLabel: "Wine name",
  wineComposerProducerLabel: "Producer",
  wineComposerStyleLabel: "Style",
  wineComposerGrapeLabel: "Grape",
  wineComposerRegionLabel: "Region",
  wineComposerCountryLabel: "Country",
  wineComposerVintageLabel: "Vintage",

  entryComposerNewTitle: "New occasion",
  entryComposerEditTitle: "Edit occasion",
  entryComposerCancelAriaLabel: "Cancel",
  entryComposerSelectedWine: "Selected wine",
  entryComposerDifferentWine: "Different wine",
  entryComposerUsing: "Using",
  entryComposerSaveCreate: "Save entry",
  entryComposerSaveEdit: "Save changes",
  entryComposerSavingLabel: "Saving...",
  entryComposerConsumedAtLabel: "Consumed at",
  entryComposerVenueLabel: "Venue",
  entryComposerLocationLabel: "Location",
  entryComposerPairingNotesLabel: "Pairing notes",
  entryComposerTastingNotesLabel: "Tasting notes",
  entryComposerRatingLabel: "Rating",

  entryDetailHeading: "Entry detail",
  entryDetailEmptyBody: "Select an entry from history to inspect the wine and occasion details.",
  entryDetailWineLabel: "Wine",
  entryDetailOccasionLabel: "Occasion",
  entryDetailEditEntry: "Edit entry",
  entryHistoryEmptyMessage: "No occasions recorded yet.",
  entryHistoryPairingPrefix: "Pairing: ",

  occasionCount: n =>
    switch n {
    | 1 => "1 occasion"
    | _ => Belt.Int.toString(n) ++ " occasions"
    },
  entryCount: n =>
    switch n {
    | 1 => "1 entry"
    | _ => Belt.Int.toString(n) ++ " entries"
    },
  rating: n => "Rating " ++ Belt.Int.toString(n) ++ "/5",
  filteredOf: (visible, total) =>
    Belt.Int.toString(visible) ++ " of " ++ Belt.Int.toString(total) ++ " wines",

  errors: {
    authEmailTaken: "That email address is already registered.",
    authInvalidEmail: "Enter a valid email address.",
    authPasswordTooShort: "Use a password with at least 8 characters.",
    authInvalidCredentials: "The email or password was not accepted.",
    authGeneric: "Something went wrong. Try again.",
    entryInvalidConsumedAt: "Enter when you drank the wine.",
    entryInvalidRating: "Rating must be a whole number from 1 to 5.",
    entryInvalidWineName: "Enter a wine name.",
    entryInvalidWineVintage: "Vintage must be a year between 1900 and 2100.",
    entryForbidden: "You no longer have access to this collection.",
    entryGeneric: "Could not save the entry. Try again.",
    entryHistoryGeneric: "Could not load your wines. Try refreshing.",
    wineInvalidName: "Enter a wine name.",
    wineInvalidVintage: "Vintage must be a year between 1900 and 2100.",
    wineForbidden: "You no longer have access to this collection.",
    wineGeneric: "Could not save the wine. Try again.",
  },
}

let sv: t = {
  appWines: "Viner",
  appSearchAriaOpen: "Sök viner",
  appSearchAriaClose: "Stäng sökning",
  appFilterAriaOpen: "Filtrera viner",
  appFilterAriaClose: "Stäng filter",
  appMenuAriaOpen: "Öppna meny",
  appAddWineAriaLabel: "Lägg till vin",
  appSignedIn: "Inloggad",
  appLogOut: "Logga ut",
  appLanguage: "Språk",
  appLanguageSwedishLabel: "Svenska",
  appLanguageEnglishLabel: "English",
  appLanguageBrowserDefault: "Använd webbläsarens språk",
  appLanguageDetectedLabel: locale =>
    switch locale {
    | AppLocale.En => "Upptäckt: Engelska"
    | AppLocale.Sv => "Upptäckt: Svenska"
    },
  appCheckingSession: "Kontrollerar din session...",

  filterAllWines: "Alla viner",
  filterWithOccasions: "Med tillfällen",
  filterWithoutOccasions: "Inga tillfällen än",

  authBrand: "Wine",
  authWelcomeBack: "Välkommen tillbaka",
  authCreateYourAccount: "Skapa ditt konto",
  authLoginIntro: "Logga in för att fortsätta till din vindagbok.",
  authRegisterIntro: "Starta din vindagbok med ett personligt konto.",
  authLogIn: "Logga in",
  authSignUp: "Registrera",
  authCreateAccount: "Skapa konto",
  authWorking: "Arbetar...",
  authFullName: "Fullständigt namn",
  authEmail: "E-post",
  authPassword: "Lösenord",

  wineListEmptyTitle: "Inga viner än",
  wineListEmptyBody: "Lägg till din första flaska. Du kan registrera ett tillfälle efteråt.",
  wineListLoading: "Hämtar dina viner...",
  wineListErrorTitle: "Viner",

  wineDetailBackAriaLabel: "Tillbaka till viner",
  wineDetailDefaultTitle: "Vin",
  wineDetailAddOccasion: "+ Nytt tillfälle",
  wineDetailIdentity: "Identitet",
  wineDetailMemory: "Minne",
  wineDetailMostRecent: "Senaste",
  wineDetailNameLabel: "Namn",
  wineDetailEmptyOccasions: "Inga tillfällen registrerade än.",
  wineDetailOccasionsLabel: "Tillfällen",

  wineComposerScreenTitle: "Nytt vin",
  wineComposerCancelAriaLabel: "Avbryt",
  wineComposerHelpText: "Lägg till en flaska du vill minnas nu, koppla tillfällen senare när de inträffar.",
  wineComposerSaveLabel: "Spara vin",
  wineComposerSavingLabel: "Sparar...",
  wineComposerWineNameLabel: "Vinets namn",
  wineComposerProducerLabel: "Producent",
  wineComposerStyleLabel: "Stil",
  wineComposerGrapeLabel: "Druva",
  wineComposerRegionLabel: "Region",
  wineComposerCountryLabel: "Land",
  wineComposerVintageLabel: "Årgång",

  entryComposerNewTitle: "Nytt tillfälle",
  entryComposerEditTitle: "Redigera tillfälle",
  entryComposerCancelAriaLabel: "Avbryt",
  entryComposerSelectedWine: "Valt vin",
  entryComposerDifferentWine: "Annat vin",
  entryComposerUsing: "Använder",
  entryComposerSaveCreate: "Spara tillfälle",
  entryComposerSaveEdit: "Spara ändringar",
  entryComposerSavingLabel: "Sparar...",
  entryComposerConsumedAtLabel: "Drucket",
  entryComposerVenueLabel: "Plats",
  entryComposerLocationLabel: "Adress",
  entryComposerPairingNotesLabel: "Matanteckningar",
  entryComposerTastingNotesLabel: "Smakanteckningar",
  entryComposerRatingLabel: "Betyg",

  entryDetailHeading: "Tillfälle",
  entryDetailEmptyBody: "Välj ett tillfälle från historiken för att se vinet och tillfällets detaljer.",
  entryDetailWineLabel: "Vin",
  entryDetailOccasionLabel: "Tillfälle",
  entryDetailEditEntry: "Redigera tillfälle",
  entryHistoryEmptyMessage: "Inga tillfällen registrerade än.",
  entryHistoryPairingPrefix: "Mat: ",

  occasionCount: n =>
    switch n {
    | 1 => "1 tillfälle"
    | _ => Belt.Int.toString(n) ++ " tillfällen"
    },
  entryCount: n =>
    switch n {
    | 1 => "1 anteckning"
    | _ => Belt.Int.toString(n) ++ " anteckningar"
    },
  rating: n => "Betyg " ++ Belt.Int.toString(n) ++ "/5",
  filteredOf: (visible, total) =>
    Belt.Int.toString(visible) ++ " av " ++ Belt.Int.toString(total) ++ " viner",

  errors: {
    authEmailTaken: "E-postadressen är redan registrerad.",
    authInvalidEmail: "Ange en giltig e-postadress.",
    authPasswordTooShort: "Använd ett lösenord med minst 8 tecken.",
    authInvalidCredentials: "E-postadressen eller lösenordet godtogs inte.",
    authGeneric: "Något gick fel. Försök igen.",
    entryInvalidConsumedAt: "Ange när du drack vinet.",
    entryInvalidRating: "Betyget måste vara ett heltal från 1 till 5.",
    entryInvalidWineName: "Ange ett vinnamn.",
    entryInvalidWineVintage: "Årgången måste vara mellan 1900 och 2100.",
    entryForbidden: "Du har inte längre åtkomst till den här samlingen.",
    entryGeneric: "Det gick inte att spara tillfället. Försök igen.",
    entryHistoryGeneric: "Det gick inte att hämta dina viner. Försök igen.",
    wineInvalidName: "Ange ett vinnamn.",
    wineInvalidVintage: "Årgången måste vara mellan 1900 och 2100.",
    wineForbidden: "Du har inte längre åtkomst till den här samlingen.",
    wineGeneric: "Det gick inte att spara vinet. Försök igen.",
  },
}

let pick = (locale: AppLocale.locale): t =>
  switch locale {
  | En => en
  | Sv => sv
  }
