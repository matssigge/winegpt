type status = WineState.status

let wineLabel = (summary: WineModel.summary) =>
  switch summary.wine.producer {
  | Some(producer) => producer ++ " " ++ summary.wine.name
  | None => summary.wine.name
  }

let wineMeta = (summary: WineModel.summary) => {
  let segments = Belt.Array.keepMap(
    [
      summary.wine.grape,
      summary.wine.vintage->Belt.Option.map(Belt.Int.toString),
      Some(summary.entryCount->Belt.Int.toString ++ " entries"),
    ],
    value => value,
  )

  segments->Js.Array2.joinWith(" · ")
}

@react.component
let make = (
  ~status,
  ~selectedWineId: option<int>,
  ~onSelectWine: int => unit,
) =>
  switch status {
  | WineState.Idle =>
    <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string("Wines")} </h3>
      <p className="mt-2 text-sm leading-6 text-stone-600">
        {React.string("Select a collection to browse the wines you have logged there.")}
      </p>
    </section>
  | WineState.Loading =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string("Wines")} </h3>
      <p className="mt-2 text-sm text-stone-600"> {React.string("Loading collection wines...")} </p>
    </section>
  | WineState.Error(message) =>
    <section className="rounded-[1.75rem] border border-rose-200 bg-rose-50 p-6">
      <h3 className="text-lg font-semibold text-rose-900"> {React.string("Wines")} </h3>
      <p className="mt-2 text-sm text-rose-700"> {React.string(message)} </p>
    </section>
  | WineState.Ready(wines) =>
    if Belt.Array.length(wines) == 0 {
      <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
        <h3 className="text-lg font-semibold text-stone-950"> {React.string("Wines")} </h3>
        <p className="mt-2 text-sm leading-6 text-stone-600">
          {React.string("No wines yet. Add the first bottle you want to remember in this collection.")}
        </p>
      </section>
    } else {
      <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
        <div className="flex items-center justify-between gap-4">
          <h3 className="text-lg font-semibold text-stone-950"> {React.string("Wines")} </h3>
          <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
            {React.string(Belt.Array.length(wines)->Belt.Int.toString ++ " wines")}
          </span>
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
                       {React.string(summary->wineMeta)}
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
