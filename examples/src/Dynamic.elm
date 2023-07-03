module Dynamic exposing (..)

import Api.ReqRes exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (src)
import Http exposing (Error)
import Table
import Table.Column as Column
import Table.Config as Config
import Table.Types exposing (Action(..))


type alias Model =
    Table.Model User


type Msg
    = OnTableInternal Model
    | OnTableExternal Model Action
    | OnData (Result Error Payload)


config : Table.Config User () Msg
config =
    Table.config
        OnTableInternal
        (String.fromInt << .id)
        columns
        |> Config.withSelectionExclusive
        |> Config.withPagination [ 5, 10, 20, 50 ] 10
        |> Config.withActions OnTableExternal [ SearchEnter, ChangePage ]


columns =
    [ Column.int .id "ID" "" |> Column.withWidth "10px"
    , Column.string .firstname "Firstname" ""
    , Column.string .lastname "Lastname" ""
    , Column.string .email "Email" ""
    , Column.string .avatar "Avatar" "" |> Column.withView viewCellAvatar
    ]


viewCellAvatar v _ =
    [ img [ src v.avatar ] [] ]


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
    ( Table.init config, get OnData 1 )


view : Model -> Html Msg
view model =
    div [] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTableExternal m _ ->
            ( Table.loading m, get OnData ((Table.pagination m).page + 1) )

        OnTableInternal m ->
            ( m, Cmd.none )

        OnData (Ok res) ->
            ( Table.loaded model res.data (res.totalPages * res.perPage), Cmd.none )

        OnData (Err _) ->
            ( model, Cmd.none )
