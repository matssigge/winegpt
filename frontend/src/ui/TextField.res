@get
external target: ReactEvent.Form.t => Dom.eventTarget = "target"

@get
external targetValue: Dom.eventTarget => string = "value"

@react.component
let make = (~label, ~value, ~onChange: string => unit, ~autoComplete, ~type_="text") => (
  <label className="block">
    <span className="mb-2 block text-sm font-medium text-stone-700"> {React.string(label)} </span>
    <input
      type_=type_
      value
      onChange={event => onChange(event->target->targetValue)}
      autoComplete
      className="w-full rounded-2xl border border-stone-300 bg-white px-4 py-3 text-base text-stone-950 outline-none transition focus:border-stone-500"
    />
  </label>
)
