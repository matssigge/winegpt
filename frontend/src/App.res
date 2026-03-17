module AuthApp = {
  @module("./AuthApp.jsx")
  @react.component
  external make: unit => React.element = "default"
}

@react.component
let make = () => <AuthApp />
