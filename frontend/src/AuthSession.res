type user
type authPayload

type restoredSession = {
  sessionToken: string,
  user: user,
}

@get
external email: user => string = "email"

@get
external token: authPayload => string = "token"

@get
external user: authPayload => user = "user"
