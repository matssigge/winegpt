type collection = CollectionModel.collection

type status =
  | Loading
  | Ready(array<collection>)
  | Error(string)

type collectionForm = {
  name: string,
  isSubmitting: bool,
  error: option<string>,
}

let initialCollectionStatus = () => {
  Loading
}

let emptyCollectionStatus = () => {
  Ready([])
}

let loadingCollectionStatus = () => {
  Loading
}

let readyCollectionStatus = collections => {
  Ready(collections)
}

let errorCollectionStatus = message => {
  Error(message)
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
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.collections) {
      | Some(collections) => Js.Promise2.resolve(collections)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )

let createCollection = (token, name) =>
  Js.Promise2.then(
    CollectionApi.createCollection(token, name),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.collection) {
      | Some(collection) => Js.Promise2.resolve(collection)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )

let appendCollection = (collections: array<collection>, collection: collection) =>
  Belt.Array.concat(collections, [collection])

let isReady = status =>
  switch status {
  | Ready(_) => true
  | Loading | Error(_) => false
  }

let collections = status =>
  switch status {
  | Ready(collections) => collections
  | Loading | Error(_) => []
  }

let selectedCollection = (collections: array<collection>, selectedCollectionId) =>
  switch selectedCollectionId {
  | Some(selectedId) => collections->Belt.Array.getBy(collection => collection.id == selectedId)
  | None => None
  }

let errorMessage = status =>
  switch status {
  | Error(message) => Some(message)
  | Loading | Ready(_) => None
  }

let resolveSelectedCollectionId = (
  collections: array<collection>,
  selectedCollectionId,
  persistedCollectionId,
) => {
  if Belt.Array.length(collections) == 0 {
    None
  } else {
    let currentSelectionStillExists = collections->Belt.Array.some(collection =>
      switch selectedCollectionId {
      | Some(selectedId) => collection.id == selectedId
      | None => false
      }
    )

    if currentSelectionStillExists {
      selectedCollectionId
    } else {
      let persistedSelectionStillExists = collections->Belt.Array.some(collection =>
        switch persistedCollectionId {
        | Some(persistedId) => collection.id == persistedId
        | None => false
        }
      )

      if persistedSelectionStillExists {
        persistedCollectionId
      } else {
        Some(collections[0].id)
      }
    }
  }
}
