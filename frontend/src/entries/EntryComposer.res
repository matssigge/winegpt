@get
external target: ReactEvent.Form.t => Dom.eventTarget = "target"

@get
external targetValue: Dom.eventTarget => string = "value"

@get
external targetChecked: Dom.eventTarget => bool = "checked"

type mode =
  | Create
  | Edit

@react.component
let make = (
  ~mode,
  ~entryForm: EntryState.form,
  ~onEntryFormChange: (. string, string) => unit,
  ~onToggleDateMode: bool => unit,
  ~onSubmit: unit => unit,
) => {
  let t = I18nContext.useT()
  let (buttonLabel, buttonBusyLabel) =
    switch mode {
    | Create => (t.entryComposerSaveCreate, t.entryComposerSavingLabel)
    | Edit => (t.entryComposerSaveEdit, t.entryComposerSavingLabel)
    }

  <section className="rounded-3xl border border-stone-900/10 bg-white p-6 shadow-[0_24px_80px_rgba(81,46,23,0.12)] md:p-8">
    <div className="grid gap-4">
      <label className="block">
        <span className="mb-2 block text-sm font-medium text-stone-700">
          {React.string(t.entryComposerPairingNotesLabel)}
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
          {React.string(t.entryComposerTastingNotesLabel)}
        </span>
        <textarea
          value=entryForm.tastingNotes
          onChange={event => onEntryFormChange(. "tastingNotes", event->target->targetValue)}
          rows=4
          className="w-full rounded-2xl border border-stone-300 bg-white px-4 py-3 text-base text-stone-950 outline-none transition focus:border-stone-500"
        />
      </label>
      <div className="md:w-40">
        <TextField
          label=t.entryComposerRatingLabel
          type_="number"
          value=entryForm.rating
          onChange={value => onEntryFormChange(. "rating", value)}
          autoComplete="off"
        />
      </div>
      <div>
        <label className="flex items-center gap-2 text-sm font-medium text-stone-700">
          <input
            type_="checkbox"
            checked={entryForm.dateMode}
            onChange={event => onToggleDateMode(event->target->targetChecked)}
          />
          {React.string(t.entryComposerSpecifyDate)}
        </label>
        {if entryForm.dateMode {
           <div className="mt-2">
             <TextField
               label=t.entryComposerConsumedAtLabel
               type_="date"
               value={entryForm.consumedAt->Belt.Option.getWithDefault("")}
               onChange={value => onEntryFormChange(. "consumedAt", value)}
               autoComplete="off"
             />
           </div>
         } else {
           React.null
         }}
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        <TextField
          label=t.entryComposerVenueLabel
          value=entryForm.venueName
          onChange={value => onEntryFormChange(. "venueName", value)}
          autoComplete="off"
        />
        <TextField
          label=t.entryComposerLocationLabel
          value=entryForm.locationText
          onChange={value => onEntryFormChange(. "locationText", value)}
          autoComplete="street-address"
        />
      </div>
    </div>
    <div className="mt-4 flex justify-end">
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
}
