@react.component
let make = (
  ~wineStatus: WineState.status,
  ~wineId: int,
  ~entryStatus: EntryState.status,
  ~onEditEntry: unit => unit,
  ~onAddEntry: unit => unit,
  ~onBack: unit => unit,
) => {
  // Slice 1 has no entry-selection UI; deferred to a later slice.
  let selectedEntry: option<EntryModel.entry> = None
  let selectedEntryId: option<int> = None
  let onSelectEntry = (_: int) => ()
  let selectedWine =
    WineState.wines(wineStatus)->Belt.Array.getBy(summary => summary.wine.id == wineId)
  let filteredEntries =
    switch selectedWine {
    | Some(_) =>
      EntryState.entries(entryStatus)->Belt.Array.keep(entry => entry.wine.id == wineId)
    | None => []
    }
  let scopedEntryStatus =
    switch entryStatus {
    | EntryState.Idle => EntryState.Idle
    | EntryState.Loading => EntryState.Loading
    | EntryState.Error(message) => EntryState.Error(message)
    | EntryState.Ready(_) => EntryState.Ready(filteredEntries)
    }

  <section className="w-full max-w-3xl">
    <header className="mb-4 flex items-center gap-3">
      <button
        type_="button"
        onClick={_ => onBack()}
        ariaLabel="Back to wines"
        className="flex h-10 w-10 items-center justify-center rounded-full border border-stone-300 text-stone-700">
        {React.string("‹")}
      </button>
      <h2 className="flex-1 truncate font-serif text-xl tracking-tight text-stone-950">
        {React.string(
           switch selectedWine {
           | Some(summary) =>
             switch summary.wine.producer {
             | Some(producer) => producer ++ " " ++ summary.wine.name
             | None => summary.wine.name
             }
           | None => "Wine"
           },
         )}
      </h2>
      <button
        type_="button"
        onClick={_ => onAddEntry()}
        className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium text-stone-700">
        {React.string("+ Add occasion")}
      </button>
    </header>
    <WineDetail
      selectedWine
      entryStatus=scopedEntryStatus
      selectedEntry
      selectedEntryId
      onEditEntry
      onSelectEntry
    />
  </section>
}
