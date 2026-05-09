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
  ~onUseSelectedWineForEntry: unit => unit,
  ~onUseNewWineForEntry: unit => unit,
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

  let t = I18nContext.useT()

  let goHome = () => Router.navigate(Home)
  let goNewWine = () => Router.navigate(NewWine)
  let goWine = wineId => Router.navigate(Wine(wineId))
  let goNewEntry = wineId => Router.navigate(NewEntry(wineId))

  let header = switch route {
  | Home =>
    <header className="mb-4 flex items-center justify-between gap-2">
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
        className="absolute right-6 top-20 z-20 w-64 rounded-2xl border border-stone-200 bg-white p-2 shadow-xl">
        <div className="rounded-xl border border-stone-200 bg-stone-50 px-4 py-3">
          <p className="text-xs font-medium uppercase tracking-widest text-stone-500">
            {React.string(t.appSignedIn)}
          </p>
          <p className="mt-1 text-sm font-medium text-stone-900">
            {React.string(user.email)}
          </p>
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
      wineStatus
      entryForm
      onEntryFormChange
      onUseSelectedWineForEntry
      onUseNewWineForEntry
      onSubmit=onCreateEntry
      onClose={() => goWine(wineId)}
    />
  | EditEntry(wineId, entryId) =>
    <EntryComposerScreen
      mode={EntryComposerScreen.Edit(wineId, entryId)}
      wineStatus
      entryForm
      onEntryFormChange
      onUseSelectedWineForEntry
      onUseNewWineForEntry
      onSubmit=onCreateEntry
      onClose={() => goWine(wineId)}
    />
  }

  <section
    className="relative w-full max-w-3xl rounded-3xl border border-stone-900/10 bg-white/80 p-6 shadow-xl backdrop-blur md:p-10">
    {header}
    {menu}
    {body}
  </section>
}
