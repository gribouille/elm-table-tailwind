module Internal.Data exposing (..)

import Internal.State exposing (Pagination, RowID, State, lensProgressive, lensSubTableLoading)
import Internal.Util exposing (iff)
import Monocle.Lens exposing (Lens)
import Table.Types exposing (..)


type alias Statable p =
    Model { p | state : State }


type Model a
    = Model
        { state : State
        , rows : Rows a
        }


type Row a
    = Row a


type Rows a
    = Rows
        (Status
            { total : Int
            , rows : List (Row a)
            }
        )


loaded : Model a -> List a -> Int -> Model a
loaded (Model model) rows n =
    Model
        { model
            | rows = Rows <| Loaded { total = n, rows = List.map Row rows }
            , state = lensProgressive.set False model.state
        }


loading : Model a -> Model a
loading (Model model) =
    Model { model | rows = Rows <| Loading }


loadingSubtable : String -> Model a -> Model a
loadingSubtable id (Model model) =
    let
        ids =
            lensSubTableLoading.get model.state

        upd =
            if List.member id ids then
                List.filter ((/=) id) ids

            else
                iff (String.isEmpty id) ids (id :: ids)
    in
    Model { model | state = lensSubTableLoading.set upd model.state }


lastExpand : Model a -> String
lastExpand (Model { state }) =
    List.head state.table.subtable |> Maybe.withDefault ""


loadingSubtableLast : Model a -> Model a
loadingSubtableLast m =
    loadingSubtable (lastExpand m) m


failed : Model a -> String -> Model a
failed (Model model) msg =
    Model
        { model
            | rows = Rows <| Failed msg
            , state = lensProgressive.set False model.state
        }


progressive : Model a -> Model a
progressive (Model model) =
    Model { model | state = lensProgressive.set True model.state }


pagination : Model a -> Pagination
pagination (Model { state }) =
    Internal.State.pagination state


getState : Model a -> State
getState (Model { state }) =
    state


getRows : Model a -> Rows a
getRows (Model { rows }) =
    rows


getItems : Rows a -> List a
getItems (Rows s) =
    case s of
        Loaded { rows } ->
            List.map (\(Row x) -> x) rows

        _ ->
            []


length : Rows a -> Int
length (Rows s) =
    case s of
        Loaded { rows } ->
            List.length rows

        _ ->
            0


stateLens : Lens (Model a) State
stateLens =
    Lens getState (\b (Model { rows }) -> Model { state = b, rows = rows })


rowsLens : Lens (Model a) (Rows a)
rowsLens =
    Lens getRows (\b (Model { state }) -> Model { state = state, rows = b })


selected : Model a -> List RowID
selected (Model { state }) =
    Internal.State.selected state


subSelected : Model a -> List RowID
subSelected (Model { state }) =
    Internal.State.subSelected state
