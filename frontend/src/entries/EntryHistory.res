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
let make = (~status) =>
  switch status {
  | EntryState.Idle =>
    <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string("Entry history")} </h3>
      <p className="mt-2 text-sm leading-6 text-stone-600">
        {React.string("Select a collection to browse its entries.")}
      </p>
    </section>
  | EntryState.Loading =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string("Entry history")} </h3>
      <p className="mt-2 text-sm text-stone-600"> {React.string("Loading collection history...")} </p>
    </section>
  | EntryState.Error(message) =>
    <section className="rounded-[1.75rem] border border-rose-200 bg-rose-50 p-6">
      <h3 className="text-lg font-semibold text-rose-900"> {React.string("Entry history")} </h3>
      <p className="mt-2 text-sm text-rose-700"> {React.string(message)} </p>
    </section>
  | EntryState.Ready(entries) =>
    if Belt.Array.length(entries) == 0 {
      <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
        <h3 className="text-lg font-semibold text-stone-950"> {React.string("Entry history")} </h3>
        <p className="mt-2 text-sm leading-6 text-stone-600">
          {React.string("No entries yet. Your latest bottles and notes will show up here.")}
        </p>
      </section>
    } else {
      <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
        <div className="flex items-center justify-between gap-4">
          <h3 className="text-lg font-semibold text-stone-950"> {React.string("Entry history")} </h3>
          <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
            {React.string(Belt.Array.length(entries)->Belt.Int.toString ++ " entries")}
          </span>
        </div>
        <ul className="mt-4 space-y-3">
          {entries
           ->Belt.Array.map(entry => {
             <li
               key={entry.id->Belt.Int.toString}
               className="rounded-2xl border border-stone-200 bg-white p-4 shadow-sm">
               <div className="flex items-start justify-between gap-4">
                 <div>
                   <p className="text-base font-semibold text-stone-950"> {React.string(entry->wineLabel)} </p>
                   {switch entry->wineMeta {
                   | Some(meta) =>
                     <p className="mt-1 text-sm text-stone-600"> {React.string(meta)} </p>
                   | None => React.null
                   }}
                 </div>
                 {switch entry.rating {
                 | Some(rating) =>
                   <span className="rounded-full border border-amber-300 bg-amber-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-amber-800">
                     {React.string(rating->Belt.Int.toString ++ "/5")}
                   </span>
                 | None => React.null
                 }}
               </div>
               <p className="mt-3 text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                 {React.string(entry.consumedAt)}
               </p>
               {switch entry.tastingNotes {
               | Some(notes) =>
                 <p className="mt-3 text-sm leading-6 text-stone-700"> {React.string(notes)} </p>
               | None => React.null
               }}
               {switch entry.pairingNotes {
               | Some(notes) =>
                 <p className="mt-2 text-sm leading-6 text-stone-600">
                   <span className="font-medium text-stone-800"> {React.string("Pairing: ")} </span>
                   {React.string(notes)}
                 </p>
               | None => React.null
               }}
             </li>
           })
           ->React.array}
        </ul>
      </section>
    }
  }
