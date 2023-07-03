module DynamicSubtable exposing (..)

import Api.Local exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (src)
import Http exposing (Error)
import Table
import Table.Column as Column
import Table.Config as Config
import Table.Types exposing (Action(..))


type alias Model =
    Table.Model MyUser


type alias MyUser =
    { user : User
    , reservations : List Reservation
    }


type Msg
    = OnTableInternal Model
    | OnTableExternal Model Action
    | OnGotUsers (Result Error Users)
    | OnGotReservations String (Result Error Reservations)


config : Table.Config MyUser Reservation Msg
config =
    Table.config
        OnTableInternal
        (.id << .user)
        columnsUsers
        |> Config.withPagination [ 5, 10, 20, 50 ] 10
        |> Config.withActions OnTableExternal [ SearchEnter, ChangePage, ShowSubtable ]
        |> Config.withSubtable .reservations .id columnsReservations Nothing


columnsUsers : List (Column.Column MyUser msg)
columnsUsers =
    [ Column.string (.id << .user) "ID" ""
    , Column.string (.firstname << .user) "Firstname" ""
    , Column.string (.lastname << .user) "Lastname" ""
    , Column.string (.email << .user) "Email" ""
    , Column.string (.bio << .user) "bio" ""
    ]


columnsReservations : List (Column.Column Reservation msg)
columnsReservations =
    [ Column.string .id "ID" ""
    , Column.string (.name << .airline) "Airline" ""
    , Column.string (.name << .airplane) "Airplane" ""
    , Column.int .number "Number" ""
    , Column.string .seat "Seat" ""
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
    ( Table.init config, getUsers OnGotUsers 0 10 )


view : Model -> Html Msg
view model =
    div [] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTableExternal m a ->
            case a of
                ShowSubtable ->
                    let

                        id =
                            Table.lastExpand m
                    in
                    ( Table.loadingSubtable id m, getReservations (OnGotReservations id) 0 10 )

                _ ->
                    ( Table.loading m, getUsers OnGotUsers ((Table.pagination m).page + 1) 10 )

        OnTableInternal m ->
            ( m, Cmd.none )

        OnGotUsers (Ok res) ->
            ( Table.loaded model (List.map (\x -> { user = x, reservations = [] }) res.items) res.total, Cmd.none )

        OnGotUsers (Err _) ->
            ( model, Cmd.none )

        OnGotReservations id (Ok res) ->
            ( Table.loaded (Table.loadingSubtable id model)
                (List.map
                    (\x ->
                        if x.user.id == id then
                            { x | reservations = res.items }

                        else
                            x
                    )
                    (Table.get model)
                )
                (Table.length model)
            , Cmd.none
            )

        OnGotReservations _ (Err _) ->
            ( model, Cmd.none )
