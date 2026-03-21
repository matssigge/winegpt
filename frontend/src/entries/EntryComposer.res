@get
external target: ReactEvent.Form.t => Dom.eventTarget = "target"

@get
external targetValue: Dom.eventTarget => string = "value"

type mode =
  | Create
  | Edit

let wineLabel = (wine: EntryModel.wine) =>
  switch wine.producer {
  | Some(producer) => producer ++ " " ++ wine.name
  | None => wine.name
  }

@react.component
let make = (
  ~mode,
  ~entryForm: EntryState.form,
  ~selectedWine: option<WineModel.summary>,
  ~onEntryFormChange: (. string, string) => unit,
  ~onUseSelectedWine: unit => unit,
  ~onUseNewWine: unit => unit,
  ~onSubmit: unit => unit,
  ~onClose: unit => unit,
) => {
  let (eyebrow, heading, buttonLabel, buttonBusyLabel) =
    switch mode {
    | Create => ("Add entry", "Capture a wine", "Save entry", "Saving...")
    | Edit => ("Edit entry", "Update this memory", "Save changes", "Saving...")
    }

  <div className="fixed inset-0 z-50 overflow-y-auto bg-stone-950/40 px-4 py-4 md:px-6 md:py-10">
    <section className="mx-auto w-full max-w-2xl rounded-[2rem] border border-stone-900/10 bg-white p-6 shadow-[0_24px_80px_rgba(81,46,23,0.2)] md:p-8">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
            {React.string(eyebrow)}
          </p>
          <h3 className="mt-2 text-2xl font-semibold text-stone-950"> {React.string(heading)} </h3>
        </div>
        <button
          type_="button"
          onClick={_ => onClose()}
          className="rounded-2xl border border-stone-300 px-4 py-2 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950">
          {React.string("Close")}
        </button>
      </div>
      <div className="mt-6 grid gap-4 md:grid-cols-2">
        {switch (mode, selectedWine) {
         | (Create, Some(_)) =>
           <div className="md:col-span-2">
             <div className="flex flex-wrap gap-3">
               <button
                 type_="button"
                 onClick={_ => onUseSelectedWine()}
                 className={
                   switch entryForm.wineSource {
                   | EntryState.ExistingWine(_) =>
                     "rounded-2xl bg-stone-950 px-4 py-3 text-sm font-semibold text-white"
                   | EntryState.NewWine =>
                     "rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950"
                   }
                 }>
                 {React.string("Selected wine")}
               </button>
               <button
                 type_="button"
                 onClick={_ => onUseNewWine()}
                 className={
                   switch entryForm.wineSource {
                   | EntryState.NewWine =>
                     "rounded-2xl bg-stone-950 px-4 py-3 text-sm font-semibold text-white"
                   | EntryState.ExistingWine(_) =>
                     "rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950"
                   }
                 }>
                 {React.string("Different wine")}
               </button>
             </div>
             {switch entryForm.wineSource {
             | EntryState.ExistingWine(wine) =>
               <div className="mt-4 rounded-2xl border border-stone-200 bg-stone-50 px-4 py-4">
                 <p className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                   {React.string("Using")}
                 </p>
                 <p className="mt-2 text-base font-semibold text-stone-950">
                   {React.string(wine->wineLabel)}
                 </p>
                 <p className="mt-1 text-sm text-stone-600">
                   {React.string(
                      Belt.Array.keepMap(
                        [
                          wine.grape,
                          wine.vintage->Belt.Option.map(Belt.Int.toString),
                          wine.region,
                          wine.country,
                        ],
                        value => value,
                      )->Js.Array2.joinWith(" · "),
                    )}
                 </p>
               </div>
             | EntryState.NewWine => React.null
             }}
           </div>
         | _ => React.null
         }}
        {switch entryForm.wineSource {
         | EntryState.NewWine =>
           <>
             <TextField
               label="Wine name"
               value=entryForm.wineName
               onChange={value => onEntryFormChange(. "wineName", value)}
               autoComplete="off"
             />
             <TextField
               label="Producer"
               value=entryForm.producer
               onChange={value => onEntryFormChange(. "producer", value)}
               autoComplete="organization"
             />
             <TextField
               label="Style"
               value=entryForm.style
               onChange={value => onEntryFormChange(. "style", value)}
               autoComplete="off"
             />
             <TextField
               label="Grape"
               value=entryForm.grape
               onChange={value => onEntryFormChange(. "grape", value)}
               autoComplete="off"
             />
             <TextField
               label="Region"
               value=entryForm.region
               onChange={value => onEntryFormChange(. "region", value)}
               autoComplete="off"
             />
             <TextField
               label="Country"
               value=entryForm.country
               onChange={value => onEntryFormChange(. "country", value)}
               autoComplete="country-name"
             />
             <TextField
               label="Vintage"
               type_="number"
               value=entryForm.vintage
               onChange={value => onEntryFormChange(. "vintage", value)}
               autoComplete="off"
             />
           </>
         | EntryState.ExistingWine(_) =>
           switch mode {
           | Edit =>
             <>
               <TextField
                 label="Wine name"
                 value=entryForm.wineName
                 onChange={value => onEntryFormChange(. "wineName", value)}
                 autoComplete="off"
               />
               <TextField
                 label="Producer"
                 value=entryForm.producer
                 onChange={value => onEntryFormChange(. "producer", value)}
                 autoComplete="organization"
               />
               <TextField
                 label="Style"
                 value=entryForm.style
                 onChange={value => onEntryFormChange(. "style", value)}
                 autoComplete="off"
               />
               <TextField
                 label="Grape"
                 value=entryForm.grape
                 onChange={value => onEntryFormChange(. "grape", value)}
                 autoComplete="off"
               />
               <TextField
                 label="Region"
                 value=entryForm.region
                 onChange={value => onEntryFormChange(. "region", value)}
                 autoComplete="off"
               />
               <TextField
                 label="Country"
                 value=entryForm.country
                 onChange={value => onEntryFormChange(. "country", value)}
                 autoComplete="country-name"
               />
               <TextField
                 label="Vintage"
                 type_="number"
                 value=entryForm.vintage
                 onChange={value => onEntryFormChange(. "vintage", value)}
                 autoComplete="off"
               />
             </>
           | Create => React.null
           }
         }}
        <TextField
          label="Consumed at"
          type_="datetime-local"
          value=entryForm.consumedAt
          onChange={value => onEntryFormChange(. "consumedAt", value)}
          autoComplete="off"
        />
        <TextField
          label="Venue"
          value=entryForm.venueName
          onChange={value => onEntryFormChange(. "venueName", value)}
          autoComplete="off"
        />
        <TextField
          label="Location"
          value=entryForm.locationText
          onChange={value => onEntryFormChange(. "locationText", value)}
          autoComplete="street-address"
        />
      </div>
      <div className="mt-4 grid gap-4">
        <label className="block">
          <span className="mb-2 block text-sm font-medium text-stone-700">
            {React.string("Pairing notes")}
          </span>
          <textarea
            value=entryForm.pairingNotes
            onChange={event => onEntryFormChange(. "pairingNotes", event->target->targetValue)}
            rows=3
            className="w-full rounded-2xl border border-stone-300 bg-white px-4 py-3 text-base text-stone-950 outline-none transition focus:border-stone-500"
          />
        </label>
        <label className="block">
          <span className="mb-2 block text-sm font-medium text-stone-700">
            {React.string("Tasting notes")}
          </span>
          <textarea
            value=entryForm.tastingNotes
            onChange={event => onEntryFormChange(. "tastingNotes", event->target->targetValue)}
            rows=4
            className="w-full rounded-2xl border border-stone-300 bg-white px-4 py-3 text-base text-stone-950 outline-none transition focus:border-stone-500"
          />
        </label>
      </div>
      <div className="mt-4 flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div className="md:w-40">
          <TextField
            label="Rating"
            type_="number"
            value=entryForm.rating
            onChange={value => onEntryFormChange(. "rating", value)}
            autoComplete="off"
          />
        </div>
        <button
          type_="button"
          onClick={_ => onSubmit()}
          disabled={entryForm.isSubmitting}
          className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400">
          {React.string(if entryForm.isSubmitting { buttonBusyLabel } else { buttonLabel })}
        </button>
      </div>
      {switch entryForm.error {
      | Some(message) =>
        <div className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {React.string(message)}
        </div>
      | None => React.null
      }}
      {switch entryForm.success {
      | Some(message) =>
        <div className="mt-4 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          {React.string(message)}
        </div>
      | None => React.null
      }}
    </section>
  </div>
}
