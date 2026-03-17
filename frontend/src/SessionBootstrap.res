type restoredSession<'user> = {
  sessionToken: string,
  user: 'user,
}

let loadSessionToken = () => SessionStorage.loadSessionToken()

let restoreSession = sessionToken =>
  Js.Promise2.then(
    AuthApi.me(sessionToken),
    response =>
      Js.Promise2.resolve({
        sessionToken: sessionToken,
        user: response->AuthAppSupport.parseJson,
      }),
  )
