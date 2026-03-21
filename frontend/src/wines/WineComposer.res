type mode = Create

@react.component
let make = (
  ~mode: mode,
  ~wineForm: WineCapture.form,
  ~onWineFormChange: (. string, string) => unit,
  ~onSubmit: unit => unit,
  ~onClose: unit => unit,
) => {
  let (_eyebrow, heading, buttonLabel, buttonBusyLabel) =
    switch mode {
    | Create => ("Add wine", "Remember a wine", "Save wine", "Saving...")
    }

  <div className="fixed inset-0 z-50 flex items-end justify-center bg-stone-950/40 p-4 md:items-center">
    <section className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-[2rem] border border-stone-900/10 bg-white p-6 shadow-[0_24px_80px_rgba(81,46,23,0.2)] md:p-8">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
            {React.string("Add wine")}
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
      <p className="mt-3 max-w-xl text-sm leading-6 text-stone-600">
        {React.string("Add a bottle you want to remember now, then attach occasions later when they happen.")}
      </p>
      <div className="mt-6 grid gap-4 md:grid-cols-2">
        <TextField
          label="Wine name"
          value=wineForm.wineName
          onChange={value => onWineFormChange(. "wineName", value)}
          autoComplete="off"
        />
        <TextField
          label="Producer"
          value=wineForm.producer
          onChange={value => onWineFormChange(. "producer", value)}
          autoComplete="organization"
        />
        <TextField
          label="Style"
          value=wineForm.style
          onChange={value => onWineFormChange(. "style", value)}
          autoComplete="off"
        />
        <TextField
          label="Grape"
          value=wineForm.grape
          onChange={value => onWineFormChange(. "grape", value)}
          autoComplete="off"
        />
        <TextField
          label="Region"
          value=wineForm.region
          onChange={value => onWineFormChange(. "region", value)}
          autoComplete="off"
        />
        <TextField
          label="Country"
          value=wineForm.country
          onChange={value => onWineFormChange(. "country", value)}
          autoComplete="country-name"
        />
        <TextField
          label="Vintage"
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
  </div>
}
