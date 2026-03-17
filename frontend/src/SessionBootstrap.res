let loadSessionToken = () => SessionStorage.loadSessionToken()

let restoreSession = sessionToken =>
  Js.Promise2.then(
    AuthApi.me(sessionToken),
    response =>
      switch response->ResponseDecoder.parse->Belt.Option.flatMap(ResponseDecoder.user) {
      | Some(user) =>
        Js.Promise2.resolve({
          sessionToken: sessionToken,
          user: user,
        }: AuthSession.restoredSession)
      | None => Js.Promise2.reject(ApiClient.invalidResponse())
      },
  )
