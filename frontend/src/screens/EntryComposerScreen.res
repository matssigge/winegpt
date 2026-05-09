type mode =
  | New(int) // wineId (fixed by route)
  | Edit(int, int) // wineId, entryId

@react.component
let make = (
  ~mode: mode,
  ~wineStatus: WineState.status,
  ~entryForm: EntryState.form,
  ~onEntryFormChange: (. string, string) => unit,
  ~onUseSelectedWineForEntry: unit => unit,
  ~onUseNewWineForEntry: unit => unit,
  ~onSubmit: unit => unit,
  ~onClose: unit => unit,
) => {
  let wineId =
    switch mode {
    | New(id) => id
    | Edit(id, _) => id
    }
  let selectedWine =
    WineState.wines(wineStatus)->Belt.Array.getBy(summary => summary.wine.id == wineId)
  let composerMode =
    switch mode {
    | New(_) => EntryComposer.Create
    | Edit(_, _) => EntryComposer.Edit
    }
  let t = I18nContext.useT()
  let title =
    switch mode {
    | New(_) => t.entryComposerNewTitle
    | Edit(_, _) => t.entryComposerEditTitle
    }

  <section className="w-full max-w-xl">
    <header className="mb-4 flex items-center gap-3">
      <button
        type_="button"
        onClick={_ => onClose()}
        ariaLabel=t.entryComposerCancelAriaLabel
        className="flex h-10 w-10 items-center justify-center rounded-full border border-stone-300 text-stone-700">
        {React.string("‹")}
      </button>
      <h2 className="flex-1 font-serif text-xl tracking-tight text-stone-950">
        {React.string(title)}
      </h2>
    </header>
    <EntryComposer
      mode=composerMode
      entryForm
      selectedWine
      onEntryFormChange
      onUseSelectedWine=onUseSelectedWineForEntry
      onUseNewWine=onUseNewWineForEntry
      onSubmit
    />
  </section>
}
