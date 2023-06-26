module Internal.Column exposing (..)

import Html exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Internal.Tailwind.Column
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)
import Table.Types exposing (Sort(..))


type alias Pipe msg =
    (State -> State) -> msg


type alias ViewCell a msg =
    a -> State -> List (Html msg)


type alias ViewHeader a msg =
    Column a msg -> State -> List (Html msg)


type Column a msg
    = Column
        { name : String
        , abbrev : String
        , field : String
        , class : String
        , width : String
        , sortable : Maybe (a -> a -> Order)
        , hiddable : Bool
        , searchable : Maybe (a -> String)
        , visible : Bool
        , viewCell : ViewCell a msg
        , default : Bool
        }


withUnSortable : Column a msg -> Column a msg
withUnSortable (Column col) =
    Column { col | sortable = Nothing }


withSortable : Maybe (a -> a -> Order) -> Column a msg -> Column a msg
withSortable value (Column col) =
    Column { col | sortable = value }


withSearchable : Maybe (a -> String) -> Column a msg -> Column a msg
withSearchable value (Column col) =
    Column { col | searchable = value }


withHiddable : Bool -> Column a msg -> Column a msg
withHiddable value (Column col) =
    Column { col | hiddable = value }


withDefault : Bool -> Column a msg -> Column a msg
withDefault value (Column col) =
    Column { col | default = value }


withWidth : String -> Column a msg -> Column a msg
withWidth w (Column col) =
    Column { col | width = w }


withHidden : Column a msg -> Column a msg
withHidden (Column col) =
    Column { col | visible = False }


withView : ViewCell a msg -> Column a msg -> Column a msg
withView view (Column col) =
    Column { col | viewCell = view }


withClass : String -> Column a msg -> Column a msg
withClass name (Column col) =
    Column { col | class = name }


withField : String -> Column a msg -> Column a msg
withField name (Column col) =
    Column { col | field = name }


withAbbreviation : String -> Column a msg -> Column a msg
withAbbreviation abbrev (Column col) =
    Column { col | abbrev = abbrev }


default : String -> String -> ViewCell a msg -> Column a msg
default name abbrev view =
    Column
        { name = name
        , abbrev = abbrev
        , field = name
        , width = ""
        , class = ""
        , sortable = Nothing
        , hiddable = True
        , searchable = Nothing
        , visible = True
        , viewCell = view
        , default = True
        }


int : (a -> Int) -> String -> String -> Column a msg
int get name abbrev =
    Column
        { name = name
        , abbrev = abbrev
        , field = name
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just (String.fromInt << get)
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text <| String.fromInt (get x) ]
        , default = True
        }


string : (a -> String) -> String -> String -> Column a msg
string get name abbrev =
    Column
        { name = name
        , abbrev = abbrev
        , field = name
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just get
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text (get x) ]
        , default = True
        }


bool : (a -> Bool) -> String -> String -> Column a msg
bool get name abbrev =
    Column
        { name = name
        , abbrev = abbrev
        , field = name
        , width = ""
        , class = "text-xl"
        , sortable = Nothing
        , searchable = Nothing
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text <| iff (get x) "☑" "☐" ]
        , default = True
        }


float : (a -> Float) -> String -> String -> Column a msg
float get name abbrev =
    Column
        { name = name
        , abbrev = abbrev
        , field = name
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just (String.fromFloat << get)
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text <| String.fromFloat (get x) ]
        , default = True
        }


expand : Pipe msg -> Pipe msg -> Lens State StateTable -> (a -> String) -> Column a msg
expand onExpand onCollapse lens getID =
    Column
        { name = ""
        , abbrev = ""
        , field = ""
        , width = "30px"
        , class = "px-2"
        , sortable = Nothing
        , searchable = Nothing
        , visible = True
        , hiddable = False
        , viewCell = viewExpand onExpand onCollapse lens getID
        , default = True
        }


subtable : (a -> Bool) -> Pipe msg -> Lens State StateTable -> (a -> String) -> Column a msg
subtable isDisable onShowSubtable lens getID =
    Column
        { name = ""
        , abbrev = ""
        , field = ""
        , width = "30px"
        , class = "px-2"
        , sortable = Nothing
        , searchable = Nothing
        , visible = True
        , hiddable = False
        , viewCell = \v -> viewSubtable onShowSubtable isDisable lens getID v
        , default = True
        }


viewExpand : Pipe msg -> Pipe msg -> Lens State StateTable -> (a -> String) -> a -> State -> List (Html msg)
viewExpand onExpand onCollapse lens getID v state =
    let
        id =
            getID v

        conf =
            lens.get state

        isExpanded =
            List.member id conf.expanded

        updatedExpand =
            iff isExpanded (List.filter ((/=) id) conf.expanded) (id :: conf.expanded)
    in
    Internal.Tailwind.Column.expand isExpanded <|
        iff isExpanded onCollapse onExpand <|
            \s -> lens.set { conf | expanded = updatedExpand } s


viewSubtable : Pipe msg -> (a -> Bool) -> Lens State StateTable -> (a -> String) -> a -> State -> List (Html msg)
viewSubtable onShowSubtable isDisable lens getID v state =
    if isDisable v then
        Internal.Tailwind.Column.subtableDisable

    else
        let
            id =
                getID v

            conf =
                lens.get state

            isExpanded =
                List.member id conf.subtable

            updatedExpand =
                iff isExpanded (List.filter ((/=) id) conf.subtable) (id :: conf.subtable)
        in
        Internal.Tailwind.Column.subtable isExpanded <|
            onShowSubtable <|
                \s -> lens.set { conf | subtable = updatedExpand } s


viewHeader : Lens State StateTable -> Pipe msg -> Column a msg -> State -> List (Html msg)
viewHeader lens onSort (Column col) state =
    Internal.Tailwind.Column.header
        { abbrev = col.abbrev
        , name = col.name
        , isSortable = col.sortable /= Nothing
        , sort = iff ((lens.get state).orderBy == Just col.field) (lens.get state).order StandBy
        , click =
            onSort <|
                \s ->
                    let
                        st =
                            lens.get s
                    in
                    lens.set
                        { st
                            | order =
                                iff ((lens.get state).orderBy == Just col.field)
                                    (next st.order)
                                    Ascending
                            , orderBy = Just col.field
                        }
                        s
        }
