module Internal.State exposing (..)

import Monocle.Lens exposing (Lens, compose)
import Table.Types exposing (Sort(..))


type alias RowID =
    String


type alias ColumnName =
    String


type alias Pagination =
    { search : String
    , orderBy : String
    , order : Sort
    , page : Int
    , byPage : Int
    }


type alias State =
    { page : Int -- TODO: move to StateTable
    , byPage : Int -- TODO: move to StateTable
    , progressive : Bool
    , search : String
    , btPagination : Bool
    , btColumns : Bool
    , btSubColumns : Bool
    , table : StateTable
    , subtable : StateTable
    }


type alias StateTable =
    { visible : List ColumnName
    , selected : List RowID
    , expanded : List RowID
    , subtable : List RowID
    , orderBy : Maybe String
    , order : Sort
    }


selected : State -> List RowID
selected state =
    (compose lensTable lensSelected).get state


subSelected : State -> List RowID
subSelected state =
    (compose lensSubTable lensSelected).get state


lensSelected : Lens StateTable (List RowID)
lensSelected =
    Lens .selected (\b a -> { a | selected = b })


lensProgressive : Lens State Bool
lensProgressive =
    Lens .progressive (\b a -> { a | progressive = b })


lensTable : Lens State StateTable
lensTable =
    Lens .table (\b a -> { a | table = b })


lensSubTable : Lens State StateTable
lensSubTable =
    Lens .subtable (\b a -> { a | subtable = b })


next : Sort -> Sort
next status =
    case status of
        StandBy ->
            Descending

        Descending ->
            Ascending

        Ascending ->
            Descending


pagination : State -> Pagination
pagination state =
    Pagination state.search
        (Maybe.withDefault "" state.table.orderBy)
        state.table.order
        state.page
        state.byPage
