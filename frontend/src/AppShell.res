@react.component
let make = (
  ~user: AuthSession.user,
  ~collectionStatus,
  ~collectionForm: CollectionState.collectionForm,
  ~selectedCollection: option<CollectionModel.collection>,
  ~selectedCollectionId: option<int>,
  ~inviteForm: CollectionInvite.form,
  ~wineStatus: WineState.status,
  ~selectedWine: option<WineModel.summary>,
  ~selectedWineId: option<int>,
  ~entryStatus: EntryState.status,
  ~entryForm: EntryState.form,
  ~entryComposerMode: option<EntryComposer.mode>,
  ~selectedEntry: option<EntryModel.entry>,
  ~selectedEntryId: option<int>,
  ~onCollectionFormChange: string => unit,
  ~onCreateCollection: unit => unit,
  ~onInviteFormChange: string => unit,
  ~onInvite: unit => unit,
  ~onEntryFormChange: (. string, string) => unit,
  ~onCreateEntry: unit => unit,
  ~onEditEntry: unit => unit,
  ~onOpenEntryComposer: unit => unit,
  ~onCloseEntryComposer: unit => unit,
  ~onSelectWine: int => unit,
  ~onSelectEntry: int => unit,
  ~onSelectCollection: int => unit,
  ~onLogout: unit => unit,
) => {
  let (isShareOpen, setIsShareOpen) = React.useState(() => false)
  let selectedWineLabel =
    switch selectedWine {
    | Some(summary) =>
      switch summary.wine.producer {
      | Some(producer) => producer ++ " " ++ summary.wine.name
      | None => summary.wine.name
      }
    | None => "this wine"
    }

  <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-12">
    <p className="mb-3 font-mono text-xs uppercase tracking-[0.35em] text-stone-600"> {React.string("Wine")} </p>
    <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
      <div>
        <h1 className="max-w-xl font-serif text-5xl leading-none tracking-[-0.04em] text-stone-950 md:text-6xl">
          {React.string("Remember the bottles worth coming back to.")}
        </h1>
        <p className="mt-6 max-w-xl text-base leading-7 text-stone-700 md:text-lg">
          {React.string("Signed in as ")}
          <span className="font-semibold text-stone-900"> {React.string(user.email)} </span>
          {React.string(". Browse the wines you know first, then open the occasions behind them when you need more context.")}
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
            <TextField
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
      <div className="mb-6">
        {switch selectedCollection {
        | Some(collection) =>
          <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-5">
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
              <div>
                <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
                  {React.string("Collection")}
                </p>
                <div className="mt-2 flex flex-wrap items-center gap-3">
                  <h2 className="text-xl font-semibold text-stone-950"> {React.string(collection.name)} </h2>
                  <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
                    {React.string(collection.role)}
                  </span>
                </div>
              </div>
              <div className="flex flex-wrap gap-3">
                {if collection->CollectionModel.isOwner {
                   <button
                     type_="button"
                     onClick={_ => setIsShareOpen(current => !current)}
                     className="rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950">
                     {React.string(if isShareOpen { "Close share" } else { "Share" })}
                   </button>
                 } else {
                   React.null
                 }}
                <button
                  type_="button"
                  onClick={_ => onOpenEntryComposer()}
                  className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800">
                  {React.string("Add entry")}
                </button>
              </div>
            </div>
            {if collection->CollectionModel.isOwner && isShareOpen {
               <div className="mt-5 border-t border-stone-200 pt-5">
                 <div className="flex flex-col gap-4 md:flex-row md:items-end">
                   <div className="flex-1">
                     <TextField
                       label="Invite by email"
                       type_="email"
                       value=inviteForm.email
                       onChange=onInviteFormChange
                       autoComplete="email"
                     />
                   </div>
                   <button
                     type_="button"
                     onClick={_ => onInvite()}
                     disabled={inviteForm.isSubmitting}
                     className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400">
                     {React.string(
                        if inviteForm.isSubmitting {
                          "Inviting..."
                        } else {
                          "Invite"
                        },
                      )}
                   </button>
                 </div>
                 {switch inviteForm.error {
                 | Some(message) =>
                   <div className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
                     {React.string(message)}
                   </div>
                 | None => React.null
                 }}
                 {switch inviteForm.success {
                 | Some(message) =>
                   <div className="mt-4 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
                     {React.string(message)}
                   </div>
                 | None => React.null
                 }}
               </div>
             } else {
               React.null
             }}
          </section>
        | None => React.null
        }}
      </div>
      <div className="mb-6">
        <WineList status=wineStatus selectedWineId onSelectWine />
      </div>
      <div className="mb-6">
        {switch selectedWine {
        | Some(summary) =>
          <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
            <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
              <div>
                <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
                  {React.string("Wine detail")}
                </p>
                <h3 className="mt-2 text-2xl font-semibold text-stone-950">
                  {React.string(
                     switch summary.wine.producer {
                     | Some(producer) => producer ++ " " ++ summary.wine.name
                     | None => summary.wine.name
                     },
                   )}
                </h3>
              </div>
              <div className="rounded-2xl border border-stone-200 bg-white px-4 py-3 text-right">
                <p className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                  {React.string("Occasions")}
                </p>
                <p className="mt-1 text-lg font-semibold text-stone-950">
                  {React.string(summary.entryCount->Belt.Int.toString)}
                </p>
              </div>
            </div>
            <div className="mt-6 grid gap-6 md:grid-cols-2">
              <section className="rounded-2xl border border-stone-200 bg-white p-5">
                <h4 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
                  {React.string("Identity")}
                </h4>
                <dl className="mt-4 grid gap-4">
                  <div>
                    <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                      {React.string("Name")}
                    </dt>
                    <dd className="mt-1 text-sm leading-6 text-stone-700">
                      {React.string(summary.wine.name)}
                    </dd>
                  </div>
                  {switch summary.wine.producer {
                  | Some(producer) =>
                    <div>
                      <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                        {React.string("Producer")}
                      </dt>
                      <dd className="mt-1 text-sm leading-6 text-stone-700">
                        {React.string(producer)}
                      </dd>
                    </div>
                  | None => React.null
                  }}
                  {switch summary.wine.grape {
                  | Some(grape) =>
                    <div>
                      <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                        {React.string("Grape")}
                      </dt>
                      <dd className="mt-1 text-sm leading-6 text-stone-700">
                        {React.string(grape)}
                      </dd>
                    </div>
                  | None => React.null
                  }}
                  {switch summary.wine.vintage {
                  | Some(vintage) =>
                    <div>
                      <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                        {React.string("Vintage")}
                      </dt>
                      <dd className="mt-1 text-sm leading-6 text-stone-700">
                        {React.string(vintage->Belt.Int.toString)}
                      </dd>
                    </div>
                  | None => React.null
                  }}
                </dl>
              </section>
              <section className="rounded-2xl border border-stone-200 bg-white p-5">
                <h4 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
                  {React.string("Memory")}
                </h4>
                <dl className="mt-4 grid gap-4">
                  <div>
                    <dt className="text-xs font-medium uppercase tracking-[0.2em] text-stone-500">
                      {React.string("Most recent")}
                    </dt>
                    <dd className="mt-1 text-sm leading-6 text-stone-700">
                      {React.string(summary.lastConsumedAt)}
                    </dd>
                  </div>
                </dl>
              </section>
            </div>
          </section>
        | None => React.null
        }}
      </div>
      <div className="mb-6">
        <EntryHistory
          status=entryStatus
          title={"Occasions for " ++ selectedWineLabel}
          idleMessage="Select a wine to browse its recorded occasions."
          loadingMessage={"Loading occasions for " ++ selectedWineLabel ++ "..."}
          emptyMessage={"No occasions recorded yet for " ++ selectedWineLabel ++ "."}
          selectedEntryId
          onSelectEntry
        />
      </div>
      <div className="mb-6">
        <EntryDetail entry=selectedEntry onEdit=onEditEntry />
      </div>
      <CollectionList
        status=collectionStatus
        selectedCollectionId={selectedCollectionId->Js.Nullable.fromOption}
        onSelectCollection
      />
      {switch entryComposerMode {
       | Some(mode) =>
         <EntryComposer
           mode
           entryForm
           onEntryFormChange
           onSubmit=onCreateEntry
           onClose=onCloseEntryComposer
         />
       | None => React.null
       }}
    </div>
  </section>
}
