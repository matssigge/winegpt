open ReactDOM

switch querySelector("#root") {
| Some(root) => Client.createRoot(root)->Client.Root.render(<App />)
| None => Js.Exn.raiseError("Missing #root element")
}
