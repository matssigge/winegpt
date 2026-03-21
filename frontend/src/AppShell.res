type managementPanel =
  | CollectionsPanel
  | CreateCollectionPanel
  | ShareCollectionPanel

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
  let canShareSelectedCollection =
    switch selectedCollection {
    | Some(collection) => collection->CollectionModel.isOwner
    | None => false
    }
  let menuButtonClasses =
    "rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950"
  let primaryActionClasses =
    "rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-not-allowed disabled:bg-stone-400"
  let secondaryActionClasses =
    "rounded-2xl border border-stone-300 px-4 py-3 text-sm font-medium text-stone-700 transition hover:border-stone-500 hover:text-stone-950 disabled:cursor-not-allowed disabled:border-stone-200 disabled:text-stone-400"
  let (isMenuOpen, setIsMenuOpen) = React.useState(() => false)
  let (isAddActionsOpen, setIsAddActionsOpen) = React.useState(() => false)
  let (activeManagementPanel, setActiveManagementPanel) = React.useState(() => None)

  let openManagementPanel = panel => {
    setIsMenuOpen(_ => false)
    setActiveManagementPanel(_ => Some(panel))
  }

  let closeManagementPanel = () => setActiveManagementPanel(_ => None)

  let managementPanel =
    switch activeManagementPanel {
    | Some(CollectionsPanel) =>
      Some((
        "Collections",
        <CollectionList
          status=collectionStatus
          selectedCollectionId={selectedCollectionId->Js.Nullable.fromOption}
          onSelectCollection={collectionId => {
            onSelectCollection(collectionId)
            closeManagementPanel()
          }}
        />,
      ))
    | Some(CreateCollectionPanel) =>
      Some((
        "Create collection",
        <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
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
        </section>,
      ))
    | Some(ShareCollectionPanel) =>
      Some((
        "Share collection",
        <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
          {switch selectedCollection {
          | Some(collection) =>
            <>
              <p className="text-sm text-stone-600">
                {React.string("Invite someone into " ++ collection.name ++ ".")}
              </p>
              <div className="mt-4 flex flex-col gap-4 md:flex-row md:items-end">
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
            </>
          | None =>
            <p className="text-sm text-stone-600">
              {React.string("Select a collection before you invite someone.")}
            </p>
          }}
        </section>,
      ))
    | None => None
    }

  <section className="w-full max-w-3xl rounded-[2rem] border border-stone-900/10 bg-white/80 p-6 shadow-[0_24px_80px_rgba(81,46,23,0.12)] backdrop-blur md:p-10">
    <div className="flex items-start justify-between gap-4">
      <div>
        <p className="font-mono text-xs uppercase tracking-[0.35em] text-stone-600"> {React.string("Wine")} </p>
        <div className="mt-3 flex flex-wrap items-center gap-3 text-sm text-stone-600">
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
      <div className="relative">
        <button
          type_="button"
          ariaLabel="Open menu"
          ariaExpanded={isMenuOpen}
          onClick={_ => setIsMenuOpen(current => !current)}
          className=menuButtonClasses>
          {React.string("Menu")}
        </button>
        {if isMenuOpen {
           <div className="absolute right-0 top-16 z-20 w-64 rounded-[1.5rem] border border-stone-200 bg-white p-2 shadow-[0_24px_80px_rgba(81,46,23,0.2)]">
             <div className="rounded-[1.25rem] border border-stone-200 bg-stone-50 px-4 py-3">
               <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
                 {React.string("Signed in")}
               </p>
               <p className="mt-1 text-sm font-medium text-stone-900"> {React.string(user.email)} </p>
             </div>
             <div className="mt-2 flex flex-col gap-1">
               <button
                 type_="button"
                 onClick={_ => openManagementPanel(CollectionsPanel)}
                 className="w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 transition hover:bg-stone-50 hover:text-stone-950">
                 {React.string("Collections")}
               </button>
               <button
                 type_="button"
                 onClick={_ => openManagementPanel(CreateCollectionPanel)}
                 className="w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 transition hover:bg-stone-50 hover:text-stone-950">
                 {React.string("Create collection")}
               </button>
               {if canShareSelectedCollection {
                  <button
                    type_="button"
                    onClick={_ => openManagementPanel(ShareCollectionPanel)}
                    className="w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 transition hover:bg-stone-50 hover:text-stone-950">
                    {React.string("Share collection")}
                  </button>
                } else {
                  React.null
                }}
               <button
                 type_="button"
                 onClick={_ => {
                   setIsMenuOpen(_ => false)
                   onLogout()
                 }}
                 className="w-full rounded-xl px-4 py-3 text-left text-sm font-medium text-stone-700 transition hover:bg-stone-50 hover:text-stone-950">
                 {React.string("Log out")}
               </button>
             </div>
           </div>
         } else {
           React.null
         }}
      </div>
    </div>
    <div className="mt-6">
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
      {switch managementPanel {
       | Some((title, content)) =>
         <div className="fixed inset-0 z-30 flex items-start justify-center bg-stone-950/35 px-4 py-8 md:py-16">
           <div className="w-full max-w-2xl rounded-[2rem] border border-stone-900/10 bg-white p-6 shadow-[0_24px_80px_rgba(81,46,23,0.24)] md:p-8">
             <div className="flex items-start justify-between gap-4">
               <div>
                 <p className="font-mono text-xs uppercase tracking-[0.3em] text-stone-500">
                   {React.string("Collection")}
                 </p>
                 <h2 className="mt-2 font-serif text-3xl tracking-[-0.03em] text-stone-950">
                   {React.string(title)}
                 </h2>
               </div>
               <button
                 type_="button"
                 onClick={_ => closeManagementPanel()}
                 className=menuButtonClasses>
                 {React.string("Close")}
               </button>
             </div>
             <div className="mt-6"> {content} </div>
           </div>
         </div>
       | None => React.null
       }}
    </div>
  </section>
}
