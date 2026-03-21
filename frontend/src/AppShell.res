@react.component
let make = (
  ~user: AuthSession.user,
  ~collectionStatus,
  ~collectionForm: CollectionState.collectionForm,
  ~selectedCollection: option<CollectionModel.collection>,
  ~selectedCollectionId: option<int>,
  ~inviteForm: CollectionInvite.form,
  ~wineStatus: WineState.status,
  ~wineForm: WineCapture.form,
  ~wineOccasionFilter: WineState.occasionFilter,
  ~wineQuery: string,
  ~selectedWine: option<WineModel.summary>,
  ~totalWineCount: int,
  ~selectedWineId: option<int>,
  ~entryStatus: EntryState.status,
  ~entryForm: EntryState.form,
  ~entryComposerMode: option<EntryComposer.mode>,
  ~wineComposerMode: option<WineComposer.mode>,
  ~selectedEntry: option<EntryModel.entry>,
  ~selectedEntryId: option<int>,
  ~onCollectionFormChange: string => unit,
  ~onCreateCollection: unit => unit,
  ~onInviteFormChange: string => unit,
  ~onInvite: unit => unit,
  ~onEntryFormChange: (. string, string) => unit,
  ~onUseSelectedWineForEntry: unit => unit,
  ~onUseNewWineForEntry: unit => unit,
  ~onWineFormChange: (. string, string) => unit,
  ~onCreateWine: unit => unit,
  ~onCreateEntry: unit => unit,
  ~onOpenWineComposer: unit => unit,
  ~onEditEntry: unit => unit,
  ~onOpenEntryComposer: unit => unit,
  ~onCloseWineComposer: unit => unit,
  ~onCloseEntryComposer: unit => unit,
  ~onSelectWine: int => unit,
  ~onSelectOccasionFilter: WineState.occasionFilter => unit,
  ~onWineQueryChange: string => unit,
  ~onSelectEntry: int => unit,
  ~onSelectCollection: int => unit,
  ~onLogout: unit => unit,
) => {
  let hasSelectedCollection = selectedCollection !== None
  let menuButtonClasses =
    "rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950"
  let primaryActionClasses =
    "rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-not-allowed disabled:bg-stone-400"
  let secondaryActionClasses =
    "rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950 disabled:cursor-not-allowed disabled:border-stone-200 disabled:text-stone-400"
  let (isMenuOpen, setIsMenuOpen) = React.useState(() => false)
  let (isShareOpen, setIsShareOpen) = React.useState(() => false)
  let (isAddActionsOpen, setIsAddActionsOpen) = React.useState(() => false)

  <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/80 p-8 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-12">
    <div className="flex items-start justify-between gap-4">
      <div>
        <p className="font-mono text-xs uppercase tracking-[0.35em] text-stone-600"> {React.string("Wine")} </p>
        <h1 className="mt-3 max-w-xl font-serif text-5xl leading-none tracking-[-0.04em] text-stone-950 md:text-6xl">
          {React.string("Remember the bottles worth coming back to.")}
        </h1>
        <div className="mt-5 flex flex-wrap items-center gap-3 text-sm text-stone-600">
          {switch selectedCollection {
          | Some(collection) =>
            <>
              <span className="rounded-full border border-stone-300 bg-stone-50 px-3 py-1 font-medium text-stone-800">
                {React.string("Collection: " ++ collection.name)}
              </span>
              <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
                {React.string(collection.role)}
              </span>
            </>
          | None =>
            <span className="rounded-full border border-dashed border-stone-300 px-3 py-1">
              {React.string("No collection selected")}
            </span>
          }}
        </div>
      </div>
      <button
        type_="button"
        ariaLabel="Open menu"
        onClick={_ => setIsMenuOpen(current => !current)}
        className=menuButtonClasses>
        {React.string(if isMenuOpen { "Close" } else { "Menu" })}
      </button>
    </div>
    <p className="mt-6 max-w-xl text-base leading-7 text-stone-700 md:text-lg">
      {React.string("Browse the wines you know first, then open the occasions behind them when you need more context.")}
    </p>
    <div className="mt-8">
      {if isMenuOpen {
         <section className="mb-6 rounded-[1.75rem] border border-stone-900/10 bg-stone-50/90 p-6">
           <div className="flex flex-col gap-6">
             <div className="rounded-2xl border border-stone-200 bg-white p-5">
               <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
                 {React.string("Signed in")}
               </p>
               <p className="mt-2 text-sm font-medium text-stone-900"> {React.string(user.email)} </p>
             </div>
             <CollectionList
               status=collectionStatus
               selectedCollectionId={selectedCollectionId->Js.Nullable.fromOption}
               onSelectCollection
             />
             <section className="rounded-2xl border border-stone-200 bg-white p-5">
               <h2 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
                 {React.string("Create collection")}
               </h2>
               <div className="mt-4 flex flex-col gap-4 md:flex-row md:items-end">
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
                   className=primaryActionClasses>
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
             {switch selectedCollection {
             | Some(collection) =>
               <section className="rounded-2xl border border-stone-200 bg-white p-5">
                 <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                   <div>
                     <h2 className="text-sm font-semibold uppercase tracking-[0.2em] text-stone-600">
                       {React.string("Selected collection")}
                     </h2>
                     <p className="mt-2 text-lg font-semibold text-stone-950"> {React.string(collection.name)} </p>
                     <p className="mt-1 text-xs uppercase tracking-[0.2em] text-stone-500">
                       {React.string(collection.role)}
                     </p>
                   </div>
                   {if collection->CollectionModel.isOwner {
                      <button
                        type_="button"
                        onClick={_ => setIsShareOpen(current => !current)}
                        className=secondaryActionClasses>
                        {React.string(if isShareOpen { "Close share" } else { "Share collection" })}
                      </button>
                    } else {
                      React.null
                    }}
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
                          className=primaryActionClasses>
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
             <button type_="button" onClick={_ => onLogout()} className=secondaryActionClasses>
               {React.string("Log out")}
             </button>
           </div>
         </section>
       } else {
         React.null
       }}
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="text-sm text-stone-600">
          {React.string(
             if hasSelectedCollection {
               "Add to the selected collection."
             } else {
               "Open the menu to choose or create a collection first."
             },
           )}
        </div>
        <div className="hidden gap-3 md:flex">
          <button
            type_="button"
            onClick={_ => onOpenWineComposer()}
            disabled={!hasSelectedCollection}
            className=secondaryActionClasses>
            {React.string("Add wine")}
          </button>
          <button
            type_="button"
            onClick={_ => onOpenEntryComposer()}
            disabled={!hasSelectedCollection}
            className=primaryActionClasses>
            {React.string("Add entry")}
          </button>
        </div>
        <div className="relative md:hidden">
          <button
            type_="button"
            ariaLabel="Open add menu"
            onClick={_ => setIsAddActionsOpen(current => !current)}
            disabled={!hasSelectedCollection}
            className="flex h-14 w-14 items-center justify-center rounded-full bg-stone-950 text-2xl font-semibold text-white shadow-lg transition hover:bg-stone-800 disabled:cursor-not-allowed disabled:bg-stone-400">
            {React.string("+")}
          </button>
          {if isAddActionsOpen && hasSelectedCollection {
             <div className="absolute right-0 top-16 z-10 w-44 rounded-2xl border border-stone-200 bg-white p-2 shadow-[0_24px_80px_rgba(81,46,23,0.2)]">
               <button
                 type_="button"
                 onClick={_ => {
                   setIsAddActionsOpen(_ => false)
                   onOpenWineComposer()
                 }}
                 className="block w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 transition hover:bg-stone-50 hover:text-stone-950">
                 {React.string("Add wine")}
               </button>
               <button
                 type_="button"
                 onClick={_ => {
                   setIsAddActionsOpen(_ => false)
                   onOpenEntryComposer()
                 }}
                 className="block w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 transition hover:bg-stone-50 hover:text-stone-950">
                 {React.string("Add entry")}
               </button>
             </div>
           } else {
             React.null
           }}
        </div>
      </div>
      <div className="mb-6">
        <WineList
          status=wineStatus
          wineQuery
          occasionFilter=wineOccasionFilter
          totalWineCount
          selectedWineId
          onSelectWine
          onSelectOccasionFilter
          onWineQueryChange
        />
      </div>
      <div className="mb-6">
        <WineDetail
          selectedWine
          entryStatus
          selectedEntry
          selectedEntryId
          onEditEntry
          onSelectEntry
        />
      </div>
      {switch entryComposerMode {
       | Some(mode) =>
         <EntryComposer
           mode
           entryForm
           selectedWine
           onEntryFormChange
           onUseSelectedWine=onUseSelectedWineForEntry
           onUseNewWine=onUseNewWineForEntry
           onSubmit=onCreateEntry
           onClose=onCloseEntryComposer
         />
       | None => React.null
       }}
      {switch wineComposerMode {
       | Some(mode) =>
         <WineComposer
           mode
           wineForm
           onWineFormChange
           onSubmit=onCreateWine
           onClose=onCloseWineComposer
         />
       | None => React.null
       }}
    </div>
  </section>
}
