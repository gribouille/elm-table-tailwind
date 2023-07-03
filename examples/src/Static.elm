module Static exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Table
import Table.Column as Column
import Table.Config as Config
import Users exposing (..)


type alias Model =
    Table.Model User


type Msg
    = OnTable Model


config : Table.Config User () Msg
config =
    Table.config
        OnTable
        (String.fromInt << .id)
        [ Column.int .id "ID" ""
        , Column.string .firstname "Firstname" ""
        , Column.string .lastname "Lastname" ""
        , Column.int .age "Age" ""
        ]
        |> Config.withPagination [ 5, 10, 20, 50 ] 10


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = Table.subscriptions config
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Table.loaded (Table.init config) users (List.length users), Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "my-4" ] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        OnTable m ->
            ( m, Cmd.none )
