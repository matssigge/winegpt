let optionalDetailLine = (~label, ~value) =>
  switch value {
  | Some(text) =>
    <div>
      <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
        {React.string(label)}
      </dt>
      <dd className="mt-1 text-sm leading-6 text-stone-700"> {React.string(text)} </dd>
    </div>
  | None => React.null
  }

let wineLabel = (summary: WineModel.summary) =>
  switch summary.wine.producer {
  | Some(producer) => producer ++ " " ++ summary.wine.name
  | None => summary.wine.name
  }

@react.component
let make = (
  ~selectedWine: option<WineModel.summary>,
  ~entryStatus: EntryState.status,
  ~selectedEntry: option<EntryModel.entry>,
  ~selectedEntryId: option<int>,
  ~onSelectEntry: int => unit,
  ~onEditEntry: unit => unit,
) => {
  let t = I18nContext.useT()
  let selectedWineLabel =
    switch selectedWine {
    | Some(summary) => summary->wineLabel
    | None => "this wine"
    }

  switch selectedWine {
  | None =>
    <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string(t.wineDetailDefaultTitle)} </h3>
      <p className="mt-2 text-sm leading-6 text-stone-600">
        {React.string("Select a wine to browse its identity, remembered occasions, and entry details.")}
      </p>
    </section>
  | Some(summary) =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
        <div>
          <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
            {React.string(t.wineDetailDefaultTitle)}
          </p>
          <h3 className="mt-2 text-2xl font-semibold text-stone-950">
            {React.string(summary->wineLabel)}
          </h3>
        </div>
        <div className="rounded-2xl border border-stone-200 bg-white px-4 py-3 text-right">
          <p className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
            {React.string(t.wineDetailOccasionsLabel)}
          </p>
          <p className="mt-1 text-lg font-semibold text-stone-950">
            {React.string(t.entryCount(summary.entryCount))}
          </p>
        </div>
      </div>
      <div className="mt-6 grid gap-6 md:grid-cols-2">
        <section className="rounded-2xl border border-stone-200 bg-white p-5">
          <h4 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
            {React.string(t.wineDetailIdentity)}
          </h4>
          <dl className="mt-4 grid gap-4">
            <div>
              <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                {React.string(t.wineDetailNameLabel)}
              </dt>
              <dd className="mt-1 text-sm leading-6 text-stone-700">
                {React.string(summary.wine.name)}
              </dd>
            </div>
            {optionalDetailLine(~label=t.wineComposerProducerLabel, ~value=summary.wine.producer)}
            {optionalDetailLine(~label=t.wineComposerStyleLabel, ~value=summary.wine.style)}
            {optionalDetailLine(~label=t.wineComposerGrapeLabel, ~value=summary.wine.grape)}
            {optionalDetailLine(~label=t.wineComposerRegionLabel, ~value=summary.wine.region)}
            {optionalDetailLine(~label=t.wineComposerCountryLabel, ~value=summary.wine.country)}
            {optionalDetailLine(
               ~label=t.wineComposerVintageLabel,
               ~value=summary.wine.vintage->Belt.Option.map(Belt.Int.toString),
             )}
          </dl>
        </section>
        <section className="rounded-2xl border border-stone-200 bg-white p-5">
          <h4 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
            {React.string(t.wineDetailMemory)}
          </h4>
          <dl className="mt-4 grid gap-4">
            <div>
              <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                {React.string(t.wineDetailMostRecent)}
              </dt>
              <dd className="mt-1 text-sm leading-6 text-stone-700">
                {React.string(summary.lastConsumedAt)}
              </dd>
            </div>
          </dl>
        </section>
      </div>
      <div className="mt-6">
        <EntryHistory
          status=entryStatus
          title={"Occasions for " ++ selectedWineLabel}
          idleMessage="Select a wine to browse its recorded occasions."
          loadingMessage={"Loading occasions for " ++ selectedWineLabel ++ "..."}
          emptyMessage={"No occasions recorded yet for " ++ selectedWineLabel ++ "."}
          selectedEntryId
          onSelectEntry
        />
      </div>
      <div className="mt-6">
        <EntryDetail entry=selectedEntry onEdit=onEditEntry />
      </div>
    </section>
  }
}
