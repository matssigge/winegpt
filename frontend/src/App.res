@react.component
let make = () => {
  <main className="app-shell">
    <div className="hero">
      <p className="eyebrow">{"Wine"->React.string}</p>
      <h1>{"Scaffold is wired up."->React.string}</h1>
      <p className="body">
        {"Backend health endpoint: http://127.0.0.1:3000/api/health"->React.string}
      </p>
    </div>
  </main>
}
