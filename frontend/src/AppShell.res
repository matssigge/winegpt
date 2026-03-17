@react.component
let make = (
  ~user: AuthSession.user,
  ~collectionStatus,
  ~collectionForm: CollectionState.collectionForm,
  ~selectedCollectionId: option<int>,
  ~onCollectionFormChange: string => unit,
  ~onCreateCollection: unit => unit,
  ~onSelectCollection: int => unit,
  ~onLogout: unit => unit,
) => {
  <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-12">
    <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600"> {React.string("Wine")} </p>
    <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
      <div>
        <h1 className="max-w-xl font-serif text-5xl leading-none tracking-[-0.04em] text-stone-950 md:text-6xl">
          {React.string("Collections are ready for your first entries.")}
        </h1>
        <p className="mt-6 max-w-xl text-base leading-7 text-stone-700 md:text-lg">
          {React.string("Signed in as ")}
          <span className="font-semibold text-stone-900"> {React.string(user->AuthSession.email)} </span>
          {React.string(". Choose a collection once it exists, then entry capture is the next slice.")}
        </p>
      </div>
      <button
        type_="button"
        onClick={_ => onLogout()}
        className="rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950">
        {React.string("Log out")}
      </button>
    </div>
    <div className="mt-8">
      <section className="mb-6 rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
        <div className="flex flex-col gap-4 md:flex-row md:items-end">
          <div className="flex-1">
            <AuthField
              label="New collection"
              value=collectionForm.name
              onChange=onCollectionFormChange
              autoComplete="off"
            />
          </div>
          <button
            type_="button"
            onClick={_ => onCreateCollection()}
            disabled={collectionForm.isSubmitting}
            className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400">
            {React.string(
               if collectionForm.isSubmitting {
                 "Creating..."
               } else {
                 "Create collection"
               },
             )}
          </button>
        </div>
        {switch collectionForm.error {
        | Some(message) =>
          <div className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
            {React.string(message)}
          </div>
        | None => React.null
        }}
      </section>
      <CollectionList
        status=collectionStatus
        selectedCollectionId={selectedCollectionId->Js.Nullable.fromOption}
        onSelectCollection
      />
    </div>
  </section>
}
