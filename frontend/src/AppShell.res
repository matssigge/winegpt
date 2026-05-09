@val external document: 'doc = "document"
@send external addEventListener: ('doc, string, 'cb) => unit = "addEventListener"
@send external removeEventListener: ('doc, string, 'cb) => unit = "removeEventListener"
@get external eventTarget: Dom.event => 'el = "target"
@send external contains: ('el, 'target) => bool = "contains"

@react.component
let make = (
  ~user: AuthSession.user,
  ~route: Router.route,
  ~wineStatus: WineState.status,
  ~wineForm: WineCapture.form,
  ~wineOccasionFilter: WineState.occasionFilter,
  ~wineQuery: string,
  ~totalWineCount: int,
  ~entryStatus: EntryState.status,
  ~entryForm: EntryState.form,
  ~onEntryFormChange: (. string, string) => unit,
  ~onToggleDateMode: bool => unit,
  ~onWineFormChange: (. string, string) => unit,
  ~onCreateWine: unit => unit,
  ~onCreateEntry: unit => unit,
  ~onEditEntry: unit => unit,
  ~onWineQueryChange: string => unit,
  ~onSelectOccasionFilter: WineState.occasionFilter => unit,
  ~onLogout: unit => unit,
) => {
  let (isMenuOpen, setIsMenuOpen) = React.useState(() => false)
  let (isSearchOpen, setIsSearchOpen) = React.useState(() => false)
  let (isFilterOpen, setIsFilterOpen) = React.useState(() => false)

  React.useEffect1(() => {
    setIsMenuOpen(_ => false)
    setIsSearchOpen(_ => false)
    setIsFilterOpen(_ => false)
    None
  }, [route])

  let menuRef = React.useRef(Js.Nullable.null)
  let menuButtonRef = React.useRef(Js.Nullable.null)

  React.useEffect1(() => {
    if isMenuOpen {
      let handler = (event: Dom.event) => {
        let target = eventTarget(event)
        let menuNode = menuRef.current->Js.Nullable.toOption
        let buttonNode = menuButtonRef.current->Js.Nullable.toOption
        let insideMenu = menuNode->Belt.Option.mapWithDefault(false, n => contains(n, target))
        let onButton = buttonNode->Belt.Option.mapWithDefault(false, n => contains(n, target))
        if !insideMenu && !onButton {
          setIsMenuOpen(_ => false)
        }
      }
      document->addEventListener("mousedown", handler)
      Some(() => document->removeEventListener("mousedown", handler))
    } else {
      None
    }
  }, [isMenuOpen])

  let t = I18nContext.useT()
  let locale = I18nContext.useLocale()
  let override = I18nContext.useOverride()
  let setOverride = I18nContext.useSetOverride()

  let goHome = () => Router.navigate(Home)
  let goNewWine = () => Router.navigate(NewWine)
  let goWine = wineId => Router.navigate(Wine(wineId))
  let goNewEntry = wineId => Router.navigate(NewEntry(wineId))

  let header = switch route {
  | Home =>
    <header className="sticky top-0 z-10 -mx-4 -mt-4 mb-4 flex items-center justify-between gap-2 bg-white px-4 pt-4 md:relative md:top-auto md:mx-0 md:mt-0 md:bg-transparent md:px-0 md:pt-0">
      <h1 className="font-serif text-2xl tracking-tight text-stone-950">
        {React.string(t.appWines)}
      </h1>
      <div className="flex items-center gap-1">
        <button
          type_="button"
          ariaLabel={isSearchOpen ? t.appSearchAriaClose : t.appSearchAriaOpen}
          onClick={_ => {
            setIsSearchOpen(open_ => !open_)
            setIsFilterOpen(_ => false)
          }}
          className="flex h-10 w-10 items-center justify-center rounded-full border border-stone-300 text-stone-700">
          {React.string(isSearchOpen ? "×" : "⌕")}
        </button>
        <button
          type_="button"
          ariaLabel={isFilterOpen ? t.appFilterAriaClose : t.appFilterAriaOpen}
          onClick={_ => {
            setIsFilterOpen(open_ => !open_)
            setIsSearchOpen(_ => false)
          }}
          className="flex h-10 w-10 items-center justify-center rounded-full border border-stone-300 text-stone-700">
          {React.string(isFilterOpen ? "×" : "⚙")}
        </button>
        <button
          type_="button"
          ariaLabel=t.appMenuAriaOpen
          ref={ReactDOM.Ref.domRef(menuButtonRef)}
          onClick={_ => setIsMenuOpen(open_ => !open_)}
          className="flex h-10 w-10 items-center justify-center rounded-full border border-stone-300 text-stone-700">
          {React.string("≡")}
        </button>
      </div>
    </header>
  | _ => React.null
  }

  let searchPanel =
    if isSearchOpen && route == Home {
      <div className="mb-4">
        <TextField
          label=t.appSearchAriaOpen
          value=wineQuery
          onChange=onWineQueryChange
          autoComplete="off"
        />
      </div>
    } else {
      React.null
    }

  let filterPanel =
    if isFilterOpen && route == Home {
      <div className="mb-4 flex flex-wrap gap-2 rounded-2xl border border-stone-200 bg-white/70 p-3">
        <button
          type_="button"
          onClick={_ => onSelectOccasionFilter(WineState.All)}
          className={
            switch wineOccasionFilter {
            | WineState.All => "rounded-full bg-stone-950 px-3 py-1 text-xs text-white"
            | _ => "rounded-full border border-stone-300 px-3 py-1 text-xs text-stone-700"
            }
          }>
          {React.string(t.filterAllWines)}
        </button>
        <button
          type_="button"
          onClick={_ => onSelectOccasionFilter(WineState.WithOccasions)}
          className={
            switch wineOccasionFilter {
            | WineState.WithOccasions => "rounded-full bg-stone-950 px-3 py-1 text-xs text-white"
            | _ => "rounded-full border border-stone-300 px-3 py-1 text-xs text-stone-700"
            }
          }>
          {React.string(t.filterWithOccasions)}
        </button>
        <button
          type_="button"
          onClick={_ => onSelectOccasionFilter(WineState.WithoutOccasions)}
          className={
            switch wineOccasionFilter {
            | WineState.WithoutOccasions => "rounded-full bg-stone-950 px-3 py-1 text-xs text-white"
            | _ => "rounded-full border border-stone-300 px-3 py-1 text-xs text-stone-700"
            }
          }>
          {React.string(t.filterWithoutOccasions)}
        </button>
      </div>
    } else {
      React.null
    }

  let menu =
    if isMenuOpen {
      <div
        ref={ReactDOM.Ref.domRef(menuRef)}
        className="absolute right-6 top-20 z-20 w-64 rounded-2xl border border-stone-200 bg-white p-2 shadow-xl">
        <div className="rounded-xl border border-stone-200 bg-stone-50 px-4 py-3">
          <p className="text-xs font-medium uppercase tracking-widest text-stone-500">
            {React.string(t.appSignedIn)}
          </p>
          <p className="mt-1 text-sm font-medium text-stone-900">
            {React.string(user.email)}
          </p>
        </div>
        <div className="mt-2 rounded-xl border border-stone-200 bg-stone-50 px-4 py-3">
          <p className="text-xs font-medium uppercase tracking-widest text-stone-500">
            {React.string(t.appLanguage)}
          </p>
          <div className="mt-2 flex flex-col gap-1">
            <label className="flex items-center gap-2 text-sm text-stone-800">
              <input
                type_="radio"
                name="language"
                checked={override == Some(AppLocale.Sv)}
                onChange={_ => setOverride(Some(AppLocale.Sv))}
              />
              {React.string(t.appLanguageSwedishLabel)}
            </label>
            <label className="flex items-center gap-2 text-sm text-stone-800">
              <input
                type_="radio"
                name="language"
                checked={override == Some(AppLocale.En)}
                onChange={_ => setOverride(Some(AppLocale.En))}
              />
              {React.string(t.appLanguageEnglishLabel)}
            </label>
            <label className="flex items-center gap-2 text-sm text-stone-800">
              <input
                type_="radio"
                name="language"
                checked={override == None}
                onChange={_ => setOverride(None)}
              />
              {React.string(t.appLanguageBrowserDefault)}
            </label>
            {switch override {
            | None =>
              <p className="mt-1 text-xs text-stone-500">
                {React.string(t.appLanguageDetectedLabel(locale))}
              </p>
            | Some(_) => React.null
            }}
          </div>
        </div>
        <button
          type_="button"
          onClick={_ => {
            setIsMenuOpen(_ => false)
            onLogout()
          }}
          className="mt-2 w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 hover:bg-stone-50">
          {React.string(t.appLogOut)}
        </button>
      </div>
    } else {
      React.null
    }

  let body = switch route {
  | Home =>
    <>
      {searchPanel}
      {filterPanel}
      <WineListScreen
        wineStatus
        wineQuery
        wineOccasionFilter
        totalWineCount
        selectedWineId={None}
        onSelectWine=goWine
      />
      <button
        type_="button"
        ariaLabel=t.appAddWineAriaLabel
        onClick={_ => goNewWine()}
        className="fixed bottom-6 right-6 flex h-14 w-14 items-center justify-center rounded-full bg-stone-950 text-2xl font-semibold text-white shadow-lg">
        {React.string("+")}
      </button>
    </>
  | Wine(wineId) =>
    <WineDetailScreen
      wineStatus
      wineId
      entryStatus
      onEditEntry
      onAddEntry={() => goNewEntry(wineId)}
      onBack={() => goHome()}
    />
  | NewWine =>
    <WineComposerScreen
      wineForm
      onWineFormChange
      onSubmit=onCreateWine
      onClose={() => goHome()}
    />
  | NewEntry(wineId) =>
    <EntryComposerScreen
      mode={EntryComposerScreen.New(wineId)}
      entryForm
      onEntryFormChange
      onToggleDateMode
      onSubmit=onCreateEntry
      onClose={() => goWine(wineId)}
    />
  | EditEntry(wineId, entryId) =>
    <EntryComposerScreen
      mode={EntryComposerScreen.Edit(wineId, entryId)}
      entryForm
      onEntryFormChange
      onToggleDateMode
      onSubmit=onCreateEntry
      onClose={() => goWine(wineId)}
    />
  }

  <section
    className="relative w-full max-w-3xl px-4 py-4 md:rounded-3xl md:border md:border-stone-900/10 md:bg-white/80 md:p-10 md:shadow-xl md:backdrop-blur">
    {header}
    {menu}
    {body}
  </section>
}
