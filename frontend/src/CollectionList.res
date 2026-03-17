type collection = CollectionState.collection
type status = {
  "collections": array<collection>,
  "kind": string,
  "message": string,
}

@get
external id: collection => int = "id"

@get
external name: collection => string = "name"

@get
external role: collection => string = "role"

@get
external kind: status => string = "kind"

@get
external message: status => string = "message"

@get
external collections: status => array<collection> = "collections"

let selectedClasses =
  "rounded-2xl border px-4 py-3 transition border-stone-950 bg-stone-950 text-white"

let unselectedClasses =
  "rounded-2xl border px-4 py-3 transition border-stone-200 bg-white text-stone-950"

let selectedRoleClasses = "mt-1 text-xs uppercase tracking-[0.2em] text-stone-300"
let unselectedRoleClasses = "mt-1 text-xs uppercase tracking-[0.2em] text-stone-500"

@react.component
let make = (~status, ~selectedCollectionId: Js.Nullable.t<int>, ~onSelectCollection: int => unit) => {
  let selectedCollectionId = selectedCollectionId->Js.Nullable.toOption

  switch status->kind {
  | "loading" =>
    <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
      <p className="text-sm text-stone-600"> {React.string("Loading your collections...")} </p>
    </section>
  | "error" =>
    <section className="rounded-[1.75rem] border border-rose-200 bg-rose-50 p-6">
      <p className="text-sm text-rose-700"> {React.string(status->message)} </p>
    </section>
  | "ready" =>
    if Belt.Array.length(status->collections) == 0 {
      <section className="rounded-[1.75rem] border border-dashed border-stone-300 bg-stone-50/80 p-6">
        <h2 className="text-lg font-semibold text-stone-950"> {React.string("No collections yet")} </h2>
        <p className="mt-2 text-sm leading-6 text-stone-600">
          {React.string("Your collections will appear here once you create your first shared wine journal.")}
        </p>
      </section>
    } else {
      let collections = status->collections

      <section className="rounded-[1.75rem] border border-stone-900/10 bg-stone-50/80 p-6">
        <h2 className="text-lg font-semibold text-stone-950"> {React.string("Your collections")} </h2>
        <ul className="mt-4 space-y-3">
          {collections
           ->Belt.Array.map(collection => {
             let isSelected =
               switch selectedCollectionId {
               | Some(selectedId) => collection->id == selectedId
               | None => false
               }

             <li
               key={collection->id->Belt.Int.toString}
               className={if isSelected { selectedClasses } else { unselectedClasses }}>
               <button
                 type_="button"
                 onClick={_ => onSelectCollection(collection->id)}
                 className="flex w-full items-center justify-between text-left">
                 <div>
                   <p className="font-medium"> {React.string(collection->name)} </p>
                   <p className={if isSelected { selectedRoleClasses } else { unselectedRoleClasses }}>
                     {React.string(collection->role)}
                   </p>
                 </div>
                 {if isSelected {
                    <span className="rounded-full border border-white/20 px-3 py-1 text-xs font-medium uppercase tracking-[0.2em] text-stone-100">
                      {React.string("Selected")}
                    </span>
                  } else {
                    React.null
                  }}
               </button>
             </li>
           })
           ->React.array}
        </ul>
      </section>
    }
  | _ => React.null
  }
}
