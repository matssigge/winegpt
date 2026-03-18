@get
external target: ReactEvent.Form.t => Dom.eventTarget = "target"

@get
external targetValue: Dom.eventTarget => string = "value"

@react.component
let make = (
  ~user: AuthSession.user,
  ~collectionStatus,
  ~collectionForm: CollectionState.collectionForm,
  ~selectedCollection: option<CollectionModel.collection>,
  ~selectedCollectionId: option<int>,
  ~inviteForm: CollectionInvite.form,
  ~entryStatus: EntryState.status,
  ~entryForm: EntryState.form,
  ~selectedEntry: option<EntryModel.entry>,
  ~selectedEntryId: option<int>,
  ~onCollectionFormChange: string => unit,
  ~onCreateCollection: unit => unit,
  ~onInviteFormChange: string => unit,
  ~onInvite: unit => unit,
  ~onEntryFormChange: (. string, string) => unit,
  ~onCreateEntry: unit => unit,
  ~onSelectEntry: int => unit,
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
          <span className="font-semibold text-stone-900"> {React.string(user.email)} </span>
          {React.string(". Capture bottles and notes inside each collection.")}
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
      {switch selectedCollection {
      | Some(collection) =>
        <section className="mb-6 rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
          <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
            <div>
              <p className="text-xs font-medium uppercase tracking-[0.25em] text-stone-500">
                {React.string("Selected collection")}
              </p>
              <h2 className="mt-2 text-2xl font-semibold text-stone-950">
                {React.string(collection.name)}
              </h2>
              <p className="mt-2 text-sm text-stone-600">
                {React.string(
                   if collection->CollectionModel.isOwner {
                     "You can invite another account into this collection."
                   } else {
                     "You currently have member access to this collection."
                   },
                 )}
              </p>
            </div>
            <span className="rounded-full border border-stone-300 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-600">
              {React.string(collection.role)}
            </span>
          </div>
          {if collection->CollectionModel.isOwner {
             <div className="mt-6 border-t border-stone-200 pt-6">
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
          <div className="mt-6 border-t border-stone-200 pt-6">
            <h3 className="text-lg font-semibold text-stone-950"> {React.string("New entry")} </h3>
            <div className="mt-4 grid gap-4 md:grid-cols-2">
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
                label="Vintage"
                type_="number"
                value=entryForm.vintage
                onChange={value => onEntryFormChange(. "vintage", value)}
                autoComplete="off"
              />
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
            <div className="mt-4 flex flex-col gap-4 md:flex-row md:items-end">
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
                onClick={_ => onCreateEntry()}
                disabled={entryForm.isSubmitting}
                className="rounded-2xl bg-stone-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-stone-800 disabled:cursor-wait disabled:bg-stone-400">
                {React.string(if entryForm.isSubmitting { "Saving..." } else { "Save entry" })}
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
          </div>
        </section>
      | None => React.null
      }}
      <div className="mb-6">
        <EntryDetail entry=selectedEntry />
      </div>
      <div className="mb-6">
        <EntryHistory status=entryStatus selectedEntryId onSelectEntry />
      </div>
      <CollectionList
        status=collectionStatus
        selectedCollectionId={selectedCollectionId->Js.Nullable.fromOption}
        onSelectCollection
      />
    </div>
  </section>
}
