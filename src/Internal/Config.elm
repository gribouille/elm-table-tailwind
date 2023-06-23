module Internal.Config exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Internal.Column exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Table.Types exposing (..)


type Pagination
    = ByPage { capabilities : List Int, initial : Int }
    | Progressive { initial : Int, step : Int }
    | None


type SubTable a b msg
    = SubTable (a -> List b) (ConfTable b msg)


type Config a b msg
    = Config (ConfigInternal a b msg)


type alias ConfigInternal a b msg =
    { selection : Selection
    , onExternal : Model a -> Action -> msg
    , onInternal : Model a -> msg
    , table : ConfTable a msg
    , pagination : Pagination
    , subtable : Maybe (SubTable a b msg)
    , errorView : String -> Html msg
    , toolbar : List (Html msg)
    , actions : List Action
    }


type alias ConfTable a msg =
    { columns : List (Column a msg)
    , getID : a -> String
    , expand : Maybe (Column a msg)
    }


type alias Resolver msg =
    Action -> Pipe msg


config : (Model a -> msg) -> (a -> String) -> List (Column a msg) -> Config a () msg
config onInternal getID columns =
    Config
        { selection = Disable
        , onExternal = \m _ -> onInternal m
        , onInternal = onInternal
        , table = ConfTable columns getID Nothing
        , pagination = None
        , subtable = Nothing
        , errorView = errorView
        , toolbar = []
        , actions = []
        }


withActions : (Model a -> Action -> msg) -> List Action -> Config a b msg -> Config a b msg
withActions onExternal actions (Config c) =
    Config { c | actions = actions, onExternal = onExternal }


withExpand : Column a msg -> Config a b msg -> Config a b msg
withExpand col (Config c) =
    let
        t =
            c.table
    in
    Config { c | table = { t | expand = Just col } }


withSelection : Selection -> Config a b msg -> Config a b msg
withSelection s (Config c) =
    Config { c | selection = s }


withSelectionFree : Config a b msg -> Config a b msg
withSelectionFree (Config c) =
    Config { c | selection = Free }


withSelectionLinked : Config a b msg -> Config a b msg
withSelectionLinked (Config c) =
    Config { c | selection = Linked }


withSelectionLinkedStrict : Config a b msg -> Config a b msg
withSelectionLinkedStrict (Config c) =
    Config { c | selection = LinkedStrict }


withSelectionExclusive : Config a b msg -> Config a b msg
withSelectionExclusive (Config c) =
    Config { c | selection = Exclusive }


withSelectionExclusiveStrict : Config a b msg -> Config a b msg
withSelectionExclusiveStrict (Config c) =
    Config { c | selection = ExclusiveStrict }


withPagination : List Int -> Int -> Config a b msg -> Config a b msg
withPagination capabilities initial (Config c) =
    Config { c | pagination = ByPage { capabilities = capabilities, initial = initial } }


withProgressive : Int -> Int -> Config a b msg -> Config a b msg
withProgressive initial step (Config c) =
    Config { c | pagination = Progressive { initial = initial, step = step } }


withToolbar : List (Html msg) -> Config a b msg -> Config a b msg
withToolbar t (Config c) =
    Config { c | toolbar = t }


withErrorView : (String -> Html msg) -> Config a b msg -> Config a b msg
withErrorView t (Config c) =
    Config { c | errorView = t }


withSubtable :
    (a -> List b)
    -> (b -> String)
    -> List (Column b msg)
    -> Maybe (Column b msg)
    -> Config a () msg
    -> Config a b msg
withSubtable getValues getID columns expand (Config c) =
    Config
        { selection = c.selection
        , onExternal = c.onExternal
        , onInternal = c.onInternal
        , table = c.table
        , pagination = c.pagination
        , subtable = Just <| SubTable getValues { columns = columns, getID = getID, expand = expand }
        , errorView = c.errorView
        , toolbar = c.toolbar
        , actions = c.actions
        }


errorView : String -> Html msg
errorView msg =
    -- TODO: move
    div [ class "m-6 bg-red-100 text-red-700 p-6 border-t-2 border-b-2 border-red-700" ]
        [ text msg
        ]


resolve : Config a b msg -> Model a -> Action -> Pipe msg
resolve (Config c) (Model m) a fn =
    if List.member a c.actions then
        c.onExternal (Model { rows = m.rows, state = fn m.state }) a

    else
        c.onInternal <| Model { rows = m.rows, state = fn m.state }
