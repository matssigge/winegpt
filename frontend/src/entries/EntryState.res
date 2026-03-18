type entry = EntryModel.entry

type status =
  | Idle
  | Loading
  | Ready(array<entry>)
  | Error(string)

type form = {
  wineName: string,
  producer: string,
  vintage: string,
  consumedAt: string,
  venueName: string,
  locationText: string,
  pairingNotes: string,
  tastingNotes: string,
  rating: string,
  isSubmitting: bool,
  error: option<string>,
  success: option<string>,
}

type error

@new
external makeError: string => error = "Error"

type date

@new
external makeDate: string => date = "Date"

@send
external getTime: date => float = "getTime"

@send
external toISOString: date => string = "toISOString"

let initialStatus = () => Idle
let loadingStatus = () => Loading
let emptyStatus = () => Ready([])
let readyStatus = entries => Ready(entries)
let errorStatus = message => Error(message)

let initialForm = {
  wineName: "",
  producer: "",
  vintage: "",
  consumedAt: "",
  venueName: "",
  locationText: "",
  pairingNotes: "",
  tastingNotes: "",
  rating: "",
  isSubmitting: false,
  error: None,
  success: None,
}

let updateForm = (form, field, value) =>
  switch field {
  | "wineName" => {...form, wineName: value, error: None, success: None}
  | "producer" => {...form, producer: value, error: None, success: None}
  | "vintage" => {...form, vintage: value, error: None, success: None}
  | "consumedAt" => {...form, consumedAt: value, error: None, success: None}
  | "venueName" => {...form, venueName: value, error: None, success: None}
  | "locationText" => {...form, locationText: value, error: None, success: None}
  | "pairingNotes" => {...form, pairingNotes: value, error: None, success: None}
  | "tastingNotes" => {...form, tastingNotes: value, error: None, success: None}
  | "rating" => {...form, rating: value, error: None, success: None}
  | _ => form
  }

let startSubmitting = form => {...form, isSubmitting: true, error: None, success: None}
let failForm = (form, message) => {...form, isSubmitting: false, error: Some(message), success: None}
let succeedForm = () => {...initialForm, success: Some("Entry saved.")}

let entries = status =>
  switch status {
  | Ready(entries) => entries
  | Idle | Loading | Error(_) => []
  }

let selectedEntry = (entries: array<entry>, selectedEntryId) =>
  switch selectedEntryId {
  | Some(selectedId) => entries->Belt.Array.getBy(entry => entry.id == selectedId)
  | None => None
  }

let resolveSelectedEntryId = (entries: array<entry>, selectedEntryId) =>
  if Belt.Array.length(entries) == 0 {
    None
  } else {
    switch selectedEntry(entries, selectedEntryId) {
    | Some(_) => selectedEntryId
    | None => Some(entries[0].id)
    }
  }

let appendEntry = (entries: array<entry>, entry: entry) => Belt.Array.concat([entry], entries)

let isReady = status =>
  switch status {
  | Ready(_) => true
  | Idle | Loading | Error(_) => false
  }

let stringOption = value =>
  switch value->String.trim {
  | "" => None
  | trimmed => Some(trimmed)
  }

let intOption = (value, ~errorCode) =>
  switch value->String.trim {
  | "" => Js.Promise2.resolve(None)
  | trimmed =>
    switch Belt.Int.fromString(trimmed) {
    | Some(number) => Js.Promise2.resolve(Some(number))
    | None => Js.Promise2.reject(makeError(errorCode)->Obj.magic)
    }
  }

let normalizeConsumedAt = value =>
  switch value->String.trim {
  | "" => Js.Promise2.reject(makeError("invalid_consumed_at")->Obj.magic)
  | trimmed =>
    let date = makeDate(trimmed)

    if Js.Float.isNaN(date->getTime) {
      Js.Promise2.reject(makeError("invalid_consumed_at")->Obj.magic)
    } else {
      Js.Promise2.resolve(date->toISOString)
    }
  }

let listEntries = (token, collectionId) =>
  Js.Promise2.then(
    EntryApi.listEntries(token, collectionId),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.entries) {
      | Some(entries) => Js.Promise2.resolve(entries)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )

let createEntry = (token, collectionId, form: form) =>
  Js.Promise2.then(normalizeConsumedAt(form.consumedAt), consumedAt =>
    Js.Promise2.then(intOption(form.vintage, ~errorCode="invalid_wine_vintage"), vintage =>
      Js.Promise2.then(intOption(form.rating, ~errorCode="invalid_rating"), rating =>
        {
          let producer = stringOption(form.producer)
          let venueName = stringOption(form.venueName)
          let locationText = stringOption(form.locationText)
          let pairingNotes = stringOption(form.pairingNotes)
          let tastingNotes = stringOption(form.tastingNotes)

          Js.Promise2.then(
            EntryApi.createEntry(
              token,
              collectionId,
              ~producer,
              ~name=form.wineName,
              ~vintage,
              ~consumedAt,
              ~venueName,
              ~locationText,
              ~pairingNotes,
              ~tastingNotes,
              ~rating,
              (),
            ),
            response =>
              switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.entry) {
              | Some(entry) => Js.Promise2.resolve(entry)
              | None => Js.Promise2.reject(ApiClient.invalidResponse())
              },
          )
        }
      )
    )
  )
