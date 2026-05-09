type mode = Create

@react.component
let make = (
  ~mode: mode,
  ~wineForm: WineCapture.form,
  ~onWineFormChange: (. string, string) => unit,
  ~onSubmit: unit => unit,
) => {
  let t = I18nContext.useT()
  let _ = mode // single variant; keep prop for forward-compat
  let buttonLabel = t.wineComposerSaveLabel
  let buttonBusyLabel = t.wineComposerSavingLabel

  <section className="rounded-3xl border border-stone-900/10 bg-white p-6 shadow-[0_24px_80px_rgba(81,46,23,0.12)] md:p-8">
    <p className="text-sm leading-6 text-stone-600">
      {React.string(t.wineComposerHelpText)}
    </p>
    <div className="mt-6 grid gap-4 md:grid-cols-2">
      <TextField
        label=t.wineComposerWineNameLabel
        value=wineForm.wineName
        onChange={value => onWineFormChange(. "wineName", value)}
        autoComplete="off"
      />
      <TextField
        label=t.wineComposerProducerLabel
        value=wineForm.producer
        onChange={value => onWineFormChange(. "producer", value)}
        autoComplete="organization"
      />
      <TextField
        label=t.wineComposerStyleLabel
        value=wineForm.style
        onChange={value => onWineFormChange(. "style", value)}
        autoComplete="off"
      />
      <TextField
        label=t.wineComposerGrapeLabel
        value=wineForm.grape
        onChange={value => onWineFormChange(. "grape", value)}
        autoComplete="off"
      />
      <TextField
        label=t.wineComposerRegionLabel
        value=wineForm.region
        onChange={value => onWineFormChange(. "region", value)}
        autoComplete="off"
      />
      <TextField
        label=t.wineComposerCountryLabel
        value=wineForm.country
        onChange={value => onWineFormChange(. "country", value)}
        autoComplete="country-name"
      />
      <TextField
        label=t.wineComposerVintageLabel
        type_="number"
        value=wineForm.vintage
        onChange={value => onWineFormChange(. "vintage", value)}
        autoComplete="off"
      />
    </div>
    <div className="mt-6 flex justify-end">
      <button
        type_="button"
        onClick={_ => onSubmit()}
        disabled={wineForm.isSubmitting}
        className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400">
        {React.string(if wineForm.isSubmitting { buttonBusyLabel } else { buttonLabel })}
      </button>
    </div>
    {switch wineForm.error {
    | Some(message) =>
      <div className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
        {React.string(message)}
      </div>
    | None => React.null
    }}
  </section>
}
