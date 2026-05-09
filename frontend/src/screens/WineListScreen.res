@react.component
let make = (
  ~wineStatus: WineState.status,
  ~wineQuery: string,
  ~wineOccasionFilter: WineState.occasionFilter,
  ~totalWineCount: int,
  ~selectedWineId: option<int>,
  ~onSelectWine: int => unit,
  ~onSelectOccasionFilter: WineState.occasionFilter => unit,
  ~onWineQueryChange: string => unit,
) =>
  <WineList
    status=wineStatus
    wineQuery
    occasionFilter=wineOccasionFilter
    totalWineCount
    selectedWineId
    onSelectWine
    onSelectOccasionFilter
    onWineQueryChange
  />
