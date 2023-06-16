module Internal.Column exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Internal.Data exposing (..)
import Internal.Icon.Collapse as Collapse
import Internal.Icon.Expand as Expand
import Internal.Icon.Minus as Minus
import Internal.Icon.Plus as Plus
import Internal.State exposing (..)
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)
import Table.Types exposing (Sort(..))


type alias Pipe msg =
    (State -> State) -> msg


type alias ViewCell a msg =
    a -> ( State, Pipe msg ) -> List (Html msg)


type alias ViewHeader a msg =
    Column a msg -> ( State, Lens State StateTable, Pipe msg ) -> List (Html msg)


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
        , viewHeader : ViewHeader a msg
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


withHeaderView : ViewHeader a msg -> Column a msg -> Column a msg
withHeaderView view (Column col) =
    Column { col | viewHeader = view }


withClass : String -> Column a msg -> Column a msg
withClass name (Column col) =
    Column { col | class = name }


default : String -> String -> String -> ViewCell a msg -> Column a msg
default name abbrev field view =
    Column
        { name = name
        , abbrev = abbrev
        , field = field
        , width = ""
        , class = ""
        , sortable = Nothing
        , hiddable = True
        , searchable = Nothing
        , visible = True
        , viewCell = view
        , viewHeader = viewHeader
        , default = True
        }


int : (a -> Int) -> String -> String -> String -> Column a msg
int get name abbrev field =
    Column
        { name = name
        , abbrev = abbrev
        , field = field
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just (String.fromInt << get)
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text <| String.fromInt (get x) ]
        , viewHeader = viewHeader
        , default = True
        }


string : (a -> String) -> String -> String -> String -> Column a msg
string get name abbrev field =
    Column
        { name = name
        , abbrev = abbrev
        , field = field
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just get
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text (get x) ]
        , viewHeader = viewHeader
        , default = True
        }


bool : (a -> Bool) -> String -> String -> String -> Column a msg
bool get name abbrev field =
    Column
        { name = name
        , abbrev = abbrev
        , field = field
        , width = ""
        , class = "text-xl"
        , sortable = Nothing
        , searchable = Nothing
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text <| iff (get x) "☑" "☐" ]
        , viewHeader = viewHeader
        , default = True
        }


float : (a -> Float) -> String -> String -> String -> Column a msg
float get name abbrev field =
    Column
        { name = name
        , abbrev = abbrev
        , field = field
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just (String.fromFloat << get)
        , visible = True
        , hiddable = True
        , viewCell = \x _ -> [ text <| String.fromFloat (get x) ]
        , viewHeader = viewHeader
        , default = True
        }


clipboard : (a -> String) -> String -> String -> String -> Column a msg
clipboard get name abbrev field =
    Column
        { name = name
        , abbrev = abbrev
        , field = field
        , width = ""
        , class = ""
        , sortable = Just <| \a b -> compare (get a) (get b)
        , searchable = Just get
        , visible = True
        , hiddable = True
        , viewCell = viewClipboard << get
        , viewHeader = viewHeader
        , default = True
        }


expand : Pipe msg -> Lens State StateTable -> (a -> String) -> Column a msg
expand pipe lens getID =
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
        , viewCell = \v ( s, _ ) -> viewExpand lens getID v ( s, pipe )
        , viewHeader = viewHeader
        , default = True
        }


subtable : (a -> Bool) -> Pipe msg -> Lens State StateTable -> (a -> String) -> Column a msg
subtable isDisable pipe lens getID =
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
        , viewCell = \v ( s, _ ) -> viewSubtable isDisable lens getID v ( s, pipe )
        , viewHeader = viewHeader
        , default = True
        }


viewExpand : Lens State StateTable -> (a -> String) -> a -> ( State, Pipe msg ) -> List (Html msg)
viewExpand lens getID v ( state, pipe ) =
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
    [ button
        [ class "w-6 h-6 pl-3 text-blue-600 hover:text-blue-300"
        , type_ "button"
        , onClick <| pipe <| \s -> lens.set { conf | expanded = updatedExpand } s
        ]
        [ iff isExpanded Collapse.view Expand.view ]
    ]


viewSubtable : (a -> Bool) -> Lens State StateTable -> (a -> String) -> a -> ( State, Pipe msg ) -> List (Html msg)
viewSubtable isDisable lens getID v ( state, pipe ) =
    if isDisable v then
        [ a [ class <| "w-6 h-6 " ++ isDisabled, disabled True ]
            [ Plus.view ]
        ]

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
        [ button
            [ class "w-6 h-6 text-blue-600 hover:text-blue-300"
            , type_ "button"
            , onClick <| pipe <| \s -> lens.set { conf | subtable = updatedExpand } s
            ]
            [ iff isExpanded Minus.view Plus.view ]
        ]


viewHeader : Column a msg -> ( State, Lens State StateTable, Pipe msg ) -> List (Html msg)
viewHeader (Column col) ( state, lens, pipe ) =
    [ iff (String.isEmpty col.abbrev)
        (span [] [ text col.name ])
        (abbr [ title col.name ] [ text col.abbrev ])
    , iff (col.sortable /= Nothing)
        (iff ((lens.get state).orderBy == Just col.field)
            (a
                [ class "ml-2 text-gray-400 hover:text-blue-500 hover:cursor-pointer"
                , onClick <|
                    pipe <|
                        \s ->
                            let
                                st =
                                    lens.get s
                            in
                            lens.set { st | order = next st.order } s
                ]
                [ text <|
                    case (lens.get state).order of
                        Ascending ->
                            "↿"

                        Descending ->
                            "⇂"

                        StandBy ->
                            "⇅"
                ]
            )
            (a
                [ class "ml-2 text-gray-400 hover:text-blue-500 hover:cursor-pointer"
                , onClick <|
                    pipe <|
                        \s ->
                            let
                                st =
                                    lens.get s
                            in
                            lens.set { st | order = Ascending, orderBy = Just col.field } s
                ]
                [ text "⇅" ]
            )
        )
        (text "")
    ]


viewClipboard : String -> ( State, Pipe msg ) -> List (Html msg)
viewClipboard _ _ =
    -- TODO
    [ div [] [ text "📋" ] ]
