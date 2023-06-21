module DynamicProgressive exposing (..)

import Api.Local exposing (..)
import Browser
import Html exposing (..)
import Http exposing (Error)
import Table
import Table.Column as Column
import Table.Config as Config
import Table.Types exposing (Action(..))


type alias Model =
    Table.Model User


type Msg
    = OnTableInternal Model
    | OnTableExternal Model
    | OnData (Result Error Payload)


config : Table.Config User () Msg
config =
    Table.config
        OnTableInternal
        .id
        [ Column.string .id "ID" "" ""
        , Column.string .firstname "Firstname" "" ""
        , Column.string .lastname "Lastname" "" ""
        , Column.string .email "Email" "" ""
        , Column.string .bio "bio" "" ""
        ]
        |> Config.withProgressive 10 5
        |> Config.withActions OnTableExternal [ EnterSearch ]


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
    ( Table.init config, get OnData 0 20 )


view : Model -> Html Msg
view model =
    div [] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTableExternal m ->
            ( Table.progressive m, get OnData ((Table.pagination m).page + 1) 20 )

        OnTableInternal m ->
            ( m, Cmd.none )

        OnData (Ok res) ->
            ( Table.loaded model (Table.get model ++ res.items) res.total, Cmd.none )

        OnData (Err _) ->
            ( model, Cmd.none )
