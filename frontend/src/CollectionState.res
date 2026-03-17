type collection

@get
external id: collection => int = "id"

type collectionForm = {
  name: string,
  isSubmitting: bool,
  error: option<string>,
}

let initialCollectionStatus = () => {
  "kind": "loading",
  "collections": [],
}

let emptyCollectionStatus = () => {
  "kind": "ready",
  "collections": [],
}

let loadingCollectionStatus = () => {
  "kind": "loading",
  "collections": [],
}

let readyCollectionStatus = collections => {
  "kind": "ready",
  "collections": collections,
}

let errorCollectionStatus = message => {
  "kind": "error",
  "message": message,
}

let initialCollectionForm = {
  name: "",
  isSubmitting: false,
  error: None,
}

let updateCollectionForm = (form, value) => {...form, name: value, error: None}

let startSubmittingCollectionForm = form => {...form, isSubmitting: true, error: None}

let resetCollectionForm = () => initialCollectionForm

let failCollectionForm = (form, message) => {...form, isSubmitting: false, error: Some(message)}

let finishCollectionForm = () => initialCollectionForm

let listCollections = token =>
  Js.Promise2.then(
    CollectionApi.listCollections(token),
    response => Js.Promise2.resolve(response->AuthAppSupport.parseJson),
  )

let createCollection = (token, name) =>
  Js.Promise2.then(
    CollectionApi.createCollection(token, name),
    response => Js.Promise2.resolve(response->AuthAppSupport.parseJson),
  )

let appendCollection = (collections, collection) => Belt.Array.concat(collections, [collection])

let resolveSelectedCollectionId = (collections, selectedCollectionId, persistedCollectionId) => {
  if Belt.Array.length(collections) == 0 {
    None
  } else {
    let currentSelectionStillExists = collections->Belt.Array.some(collection =>
      switch selectedCollectionId {
      | Some(selectedId) => collection->id == selectedId
      | None => false
      }
    )

    if currentSelectionStillExists {
      selectedCollectionId
    } else {
      let persistedSelectionStillExists = collections->Belt.Array.some(collection =>
        switch persistedCollectionId {
        | Some(persistedId) => collection->id == persistedId
        | None => false
        }
      )

      if persistedSelectionStillExists {
        persistedCollectionId
      } else {
        Some(collections[0]->id)
      }
    }
  }
}
