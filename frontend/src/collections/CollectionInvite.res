type invitedMember = CollectionInviteModel.invitedMember

type form = {
  email: string,
  isSubmitting: bool,
  error: option<string>,
  success: option<string>,
}

let initialForm = {
  email: "",
  isSubmitting: false,
  error: None,
  success: None,
}

let updateForm = (form: form, email) => {...form, email: email, error: None, success: None}

let startSubmitting = (form: form) => {...form, isSubmitting: true, error: None, success: None}

let failForm = (form: form, message) => {
  ...form,
  isSubmitting: false,
  error: Some(message),
  success: None,
}

let succeedForm = (invitedMember: invitedMember): form => {
  email: "",
  isSubmitting: false,
  error: None,
  success: Some("Invited " ++ invitedMember.email ++ "."),
}

let invite = (token, collectionId, email) =>
  Js.Promise2.then(
    CollectionApi.inviteCollectionMember(token, collectionId, email),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.invitedCollectionMember) {
      | Some(invitedMember) => Js.Promise2.resolve(invitedMember)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )
