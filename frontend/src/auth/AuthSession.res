type user = {email: string}

type authPayload = {
  token: string,
  user: user,
}

type restoredSession = {
  sessionToken: string,
  user: user,
}
