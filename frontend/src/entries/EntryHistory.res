type status = EntryState.status

let wineLabel = (entry: EntryModel.entry) =>
  switch entry.wine.producer {
  | Some(producer) => producer ++ " " ++ entry.wine.name
  | None => entry.wine.name
  }

let wineMeta = (entry: EntryModel.entry) => {
  let segments = Belt.Array.keepMap(
    [
      entry.wine.vintage->Belt.Option.map(Belt.Int.toString),
      entry.locationText,
      entry.venueName,
    ],
    value => value,
  )

  if Belt.Array.length(segments) == 0 {
    None
  } else {
    Some(segments->Js.Array2.joinWith(" · "))
  }
}

@react.component
let make = (
  ~status,
  ~title: string="Entry history",
  ~idleMessage: string="Select a collection to browse its entries.",
  ~loadingMessage: string="Loading collection history...",
  ~emptyMessage: string="No entries yet. Your latest bottles and notes will show up here.",
  ~selectedEntryId: option<int>,
  ~onSelectEntry: int => unit,
) =>
  switch status {
  | EntryState.Idle =>
    <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string(title)} </h3>
      <p className="mt-2 text-sm leading-6 text-stone-600">
        {React.string(idleMessage)}
      </p>
    </section>
  | EntryState.Loading =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string(title)} </h3>
      <p className="mt-2 text-sm text-stone-600"> {React.string(loadingMessage)} </p>
    </section>
  | EntryState.Error(message) =>
    <section className="rounded-[1.75rem] border border-rose-200 bg-rose-50 p-6">
      <h3 className="text-lg font-semibold text-rose-900"> {React.string(title)} </h3>
      <p className="mt-2 text-sm text-rose-700"> {React.string(message)} </p>
    </section>
  | EntryState.Ready(entries) =>
    if Belt.Array.length(entries) == 0 {
      <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
        <h3 className="text-lg font-semibold text-stone-950"> {React.string(title)} </h3>
        <p className="mt-2 text-sm leading-6 text-stone-600">
          {React.string(emptyMessage)}
        </p>
      </section>
    } else {
      <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
        <div className="flex items-center justify-between gap-4">
          <h3 className="text-lg font-semibold text-stone-950"> {React.string(title)} </h3>
          <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
            {React.string(Belt.Array.length(entries)->Belt.Int.toString ++ " entries")}
          </span>
        </div>
        <ul className="mt-4 space-y-3">
          {entries
           ->Belt.Array.map(entry => {
             let isSelected =
               switch selectedEntryId {
               | Some(selectedId) => entry.id == selectedId
               | None => false
               }

             <li
               key={entry.id->Belt.Int.toString}
               className={
                 if isSelected {
                   "rounded-2xl border border-stone-950 bg-stone-950 p-4 shadow-sm text-white"
                 } else {
                   "rounded-2xl border border-stone-200 bg-white p-4 shadow-sm"
                 }
               }>
               <button type_="button" onClick={_ => onSelectEntry(entry.id)} className="block w-full text-left">
               <div className="flex items-start justify-between gap-4">
                 <div>
                   <p className={if isSelected { "text-base font-semibold text-white" } else { "text-base font-semibold text-stone-950" }}>
                     {React.string(entry->wineLabel)}
                   </p>
                   {switch entry->wineMeta {
                   | Some(meta) =>
                     <p className={if isSelected { "mt-1 text-sm text-stone-200" } else { "mt-1 text-sm text-stone-600" }}>
                       {React.string(meta)}
                     </p>
                   | None => React.null
                   }}
                 </div>
                 {switch entry.rating {
                 | Some(rating) =>
                   <span
                     className={
                       if isSelected {
                         "rounded-full border border-white/20 bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-white"
                       } else {
                         "rounded-full border border-amber-300 bg-amber-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-amber-800"
                       }
                     }>
                     {React.string(rating->Belt.Int.toString ++ "/5")}
                   </span>
                 | None => React.null
                 }}
               </div>
               <p className={if isSelected { "mt-3 text-xs font-medium uppercase tracking-[0.2em] text-stone-300" } else { "mt-3 text-xs font-medium uppercase tracking-[0.2em] text-stone-500" }}>
                 {React.string(entry.consumedAt)}
               </p>
               {switch entry.tastingNotes {
               | Some(notes) =>
                 <p className={if isSelected { "mt-3 text-sm leading-6 text-stone-100" } else { "mt-3 text-sm leading-6 text-stone-700" }}>
                   {React.string(notes)}
                 </p>
               | None => React.null
               }}
               {switch entry.pairingNotes {
               | Some(notes) =>
                 <p className={if isSelected { "mt-2 text-sm leading-6 text-stone-200" } else { "mt-2 text-sm leading-6 text-stone-600" }}>
                   <span className={if isSelected { "font-medium text-white" } else { "font-medium text-stone-800" }}>
                     {React.string("Pairing: ")}
                   </span>
                   {React.string(notes)}
                 </p>
               | None => React.null
               }}
               </button>
             </li>
           })
           ->React.array}
        </ul>
      </section>
    }
  }
