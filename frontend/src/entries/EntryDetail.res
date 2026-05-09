let detailLine = (~label, ~value) =>
  <div>
    <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
      {React.string(label)}
    </dt>
    <dd className="mt-1 text-sm leading-6 text-stone-700"> {React.string(value)} </dd>
  </div>

let optionalDetailLine = (~label, ~value) =>
  switch value {
  | Some(text) => Some(detailLine(~label, ~value=text))
  | None => None
  }

let wineSummary = (entry: EntryModel.entry) => {
  let parts = Belt.Array.keepMap(
    [
      entry.wine.producer,
      Some(entry.wine.name),
      entry.wine.vintage->Belt.Option.map(Belt.Int.toString),
    ],
    value => value,
  )

  parts->Js.Array2.joinWith(" · ")
}

@react.component
let make = (~entry: option<EntryModel.entry>, ~onEdit: unit => unit) => {
  let t = I18nContext.useT()
  switch entry {
  | None =>
    <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
      <h3 className="text-lg font-semibold text-stone-950"> {React.string(t.entryDetailHeading)} </h3>
      <p className="mt-2 text-sm leading-6 text-stone-600">
        {React.string(t.entryDetailEmptyBody)}
      </p>
    </section>
  | Some(entry) =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
        <div>
          <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
            {React.string(t.entryDetailHeading)}
          </p>
          <h3 className="mt-2 text-2xl font-semibold text-stone-950">
            {React.string(entry->wineSummary)}
          </h3>
        </div>
        <div className="flex flex-col items-start gap-3 md:items-end">
          {switch entry.rating {
          | Some(rating) =>
            <span className="rounded-full border border-amber-300 bg-amber-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-amber-800">
              {React.string(t.rating(rating))}
            </span>
          | None => React.null
          }}
          <button
            type_="button"
            onClick={_ => onEdit()}
            className="rounded-2xl border border-stone-300 px-4 py-2 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950">
            {React.string(t.entryDetailEditEntry)}
          </button>
        </div>
      </div>
      <div className="mt-6 grid gap-6 md:grid-cols-2">
        <section className="rounded-2xl border border-stone-200 bg-white p-5">
          <h4 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
            {React.string(t.entryDetailWineLabel)}
          </h4>
          <dl className="mt-4 grid gap-4">
            {detailLine(~label="Name", ~value=entry.wine.name)}
            {optionalDetailLine(~label="Producer", ~value=entry.wine.producer)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(
               ~label="Vintage",
               ~value=entry.wine.vintage->Belt.Option.map(Belt.Int.toString),
             )->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Style", ~value=entry.wine.style)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Grape", ~value=entry.wine.grape)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Region", ~value=entry.wine.region)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Country", ~value=entry.wine.country)->Belt.Option.getWithDefault(React.null)}
          </dl>
        </section>
        <section className="rounded-2xl border border-stone-200 bg-white p-5">
          <h4 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
            {React.string(t.entryDetailOccasionLabel)}
          </h4>
          <dl className="mt-4 grid gap-4">
            {detailLine(~label="Consumed at", ~value=entry.consumedAt)}
            {optionalDetailLine(~label="Venue", ~value=entry.venueName)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Location", ~value=entry.locationText)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Pairing notes", ~value=entry.pairingNotes)->Belt.Option.getWithDefault(React.null)}
            {optionalDetailLine(~label="Tasting notes", ~value=entry.tastingNotes)->Belt.Option.getWithDefault(React.null)}
          </dl>
        </section>
      </div>
    </section>
  }
}
