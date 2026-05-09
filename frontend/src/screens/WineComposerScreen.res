@react.component
let make = (
  ~wineForm: WineCapture.form,
  ~onWineFormChange: (. string, string) => unit,
  ~onSubmit: unit => unit,
  ~onClose: unit => unit,
) => {
  let t = I18nContext.useT()
  <section className="w-full max-w-xl">
    <header className="mb-4 flex items-center gap-3">
      <button
        type_="button"
        onClick={_ => onClose()}
        ariaLabel=t.wineComposerCancelAriaLabel
        className="flex h-10 w-10 items-center justify-center rounded-full border border-stone-300 text-stone-700">
        {React.string("‹")}
      </button>
      <h2 className="flex-1 font-serif text-xl tracking-tight text-stone-950">
        {React.string(t.wineComposerScreenTitle)}
      </h2>
    </header>
    <WineComposer
      mode=WineComposer.Create
      wineForm
      onWineFormChange
      onSubmit
    />
  </section>
}
