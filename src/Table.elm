module Table exposing
    ( Model, Row, Rows, RowID, init, loaded, loading, failed, progressive
    , Pipe, State, Pagination, pagination, selected, subSelected, get
    , Config, Column, config
    , view, subscriptions
    )

{-| Full featured table.


# Data

@docs Model, Row, Rows, RowID, init, loaded, loading, failed, progressive


# State

@docs Pipe, State, Pagination, pagination, selected, subSelected, get


# Configuration

@docs Config, Column, config


# View

@docs view, subscriptions

-}

import Html exposing (Html)
import Internal.Column
import Internal.Config
import Internal.Data
import Internal.State
import Internal.Subscription
import Internal.Table
import Table.Types exposing (..)


{-| Model of component (opaque).
-}
type alias Model a =
    Internal.Data.Model a


{-| Pipe for the table's messages to change the state.
-}
type alias Pipe msg =
    Internal.Column.Pipe msg


{-| Internal table's state.
-}
type alias State =
    Internal.State.State


{-| Table's configuration (opaque).
-}
type alias Config a b msg =
    Internal.Config.Config a b msg


{-| Column's configuration (opaque).
-}
type alias Column a msg =
    Internal.Column.Column a msg


{-| Table's row (opaque).
-}
type alias Row a =
    Internal.Data.Row a


{-| List of table's rows (opaque).
-}
type alias Rows a =
    Internal.Data.Rows a


{-| Unique ID of one row.
-}
type alias RowID =
    Internal.State.RowID


{-| Pagination values.
-}
type alias Pagination =
    Internal.State.Pagination


{-| -}
config : (Model a -> msg) -> (a -> String) -> List (Column a msg) -> Config a () msg
config =
    Internal.Config.config


{-| Table's view.
-}
view : Config a b msg -> Model a -> Html msg
view =
    Internal.Table.view


{-| Initialize the table's model.
-}
init : Config a b msg -> Model a
init =
    Internal.Table.init


{-| Get the data from the model.
-}
get : Model a -> List a
get =
    Internal.Data.getItems << Internal.Data.getRows


{-| Load the data in the model with the total number of rows if the data are
incomplete.
-}
loaded : Model a -> List a -> Int -> Model a
loaded =
    Internal.Data.loaded


{-| Data loading is in progress.
-}
loading : Model a -> Model a
loading =
    Internal.Data.loading


{-| Data loading has failed.
-}
failed : Model a -> String -> Model a
failed =
    Internal.Data.failed


{-| Data loading is in progress for the progressive loading mode.
-}
progressive : Model a -> Model a
progressive =
    Internal.Data.progressive


{-| Get the pagination values from model.
-}
pagination : Model a -> Pagination
pagination =
    Internal.Data.pagination


{-| Table's subscriptions.
-}
subscriptions : Config a b msg -> Model a -> Sub msg
subscriptions =
    Internal.Subscription.subscriptions


{-| Return the list of selected rows.
-}
selected : Model a -> List RowID
selected =
    Internal.Data.selected


{-| Return the list of selected rows in the sub tables.
-}
subSelected : Model a -> List RowID
subSelected =
    Internal.Data.subSelected
