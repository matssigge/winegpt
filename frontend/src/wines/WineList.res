type status = WineState.status

let wineLabel = (summary: WineModel.summary) =>
  switch summary.wine.producer {
  | Some(producer) => producer ++ " " ++ summary.wine.name
  | None => summary.wine.name
  }

let wineMeta = (summary: WineModel.summary, t: Translations.t) => {
  let segments = Belt.Array.keepMap(
    [
      summary.wine.grape,
      summary.wine.vintage->Belt.Option.map(Belt.Int.toString),
      Some(t.entryCount(summary.entryCount)),
    ],
    value => value,
  )

  segments->Js.Array2.joinWith(" · ")
}

let shouldShowFilteredCount = (wineQuery: string, occasionFilter) =>
  wineQuery->String.trim != "" || occasionFilter != WineState.All

@react.component
let make = (
  ~status,
  ~wineQuery: string,
  ~occasionFilter: WineState.occasionFilter,
  ~totalWineCount: int,
  ~selectedWineId: option<int>,
  ~onSelectWine: int => unit,
) => {
  let t = I18nContext.useT()
  switch status {
  | WineState.Idle =>
    <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string(t.appWines)} </h3>
      <p className="mt-2 text-sm leading-6 text-stone-600">
        {React.string(t.wineListEmptyBody)}
      </p>
    </section>
  | WineState.Loading =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string(t.appWines)} </h3>
      <p className="mt-2 text-sm text-stone-600"> {React.string(t.wineListLoading)} </p>
    </section>
  | WineState.Error(message) =>
    <section className="rounded-[1.75rem] border border-rose-200 bg-rose-50 p-6">
      <h3 className="text-lg font-semibold text-rose-900"> {React.string(t.wineListErrorTitle)} </h3>
      <p className="mt-2 text-sm text-rose-700"> {React.string(message)} </p>
    </section>
  | WineState.Ready(wines) =>
    if Belt.Array.length(wines) == 0 {
      <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
        <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
          <div>
            <h3 className="text-lg font-semibold text-stone-950"> {React.string(t.wineListEmptyTitle)} </h3>
            <p className="mt-2 text-sm leading-6 text-stone-600">
              {React.string(t.wineListEmptyBody)}
            </p>
          </div>
        </div>
      </section>
    } else {
      <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
        <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
          <div className="flex items-center gap-4">
            <h3 className="text-lg font-semibold text-stone-950"> {React.string(t.appWines)} </h3>
            <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
              {React.string(
                 if !shouldShowFilteredCount(wineQuery, occasionFilter) {
                   t.entryCount(Belt.Array.length(wines))
                 } else {
                   t.filteredOf(Belt.Array.length(wines), totalWineCount)
                 },
               )}
            </span>
          </div>
        </div>
        <ul className="mt-4 space-y-3">
          {wines
           ->Belt.Array.map(summary => {
             let isSelected =
               switch selectedWineId {
               | Some(selectedId) => summary.wine.id == selectedId
               | None => false
               }

             <li
               key={summary.wine.id->Belt.Int.toString}
               className={
                 if isSelected {
                   "rounded-2xl border border-stone-950 bg-stone-950 p-4 shadow-sm text-white"
                 } else {
                   "rounded-2xl border border-stone-200 bg-white p-4 shadow-sm"
                 }
               }>
               <button
                 type_="button"
                 onClick={_ => onSelectWine(summary.wine.id)}
                 className="block w-full text-left">
                 <div className="flex items-start justify-between gap-4">
                   <div>
                     <p className={if isSelected { "text-base font-semibold text-white" } else { "text-base font-semibold text-stone-950" }}>
                       {React.string(summary->wineLabel)}
                     </p>
                     <p className={if isSelected { "mt-1 text-sm text-stone-200" } else { "mt-1 text-sm text-stone-600" }}>
                       {React.string(summary->wineMeta(t))}
                     </p>
                   </div>
                   <p className={if isSelected { "text-xs font-medium uppercase tracking-[0.2em] text-stone-300" } else { "text-xs font-medium uppercase tracking-[0.2em] text-stone-500" }}>
                     {React.string(summary.lastConsumedAt)}
                   </p>
                 </div>
               </button>
             </li>
           })
           ->React.array}
        </ul>
      </section>
    }
  }
}
