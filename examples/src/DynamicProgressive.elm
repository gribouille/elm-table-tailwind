module DynamicProgressive exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Table
import Table.Column as Column
import Table.Config as Config
import Url.Builder as Builder


type alias Model =
    Table.Model User


type alias User =
    { id : String
    , firstname : String
    , lastname : String
    , email : String
    , bio : String
    }


type alias Payload =
    { total : Int
    , items : List User
    }


decoder : Decoder Payload
decoder =
    Decode.succeed Payload
        |> required "total" Decode.int
        |> required "items" (Decode.list decoderUser)


decoderUser : Decoder User
decoderUser =
    Decode.succeed User
        |> required "id" Decode.string
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "email" Decode.string
        |> required "bio" Decode.string


type Msg
    = OnTableInternal Model
    | OnTableExternal Model
    | OnData (Result Error Payload)


get : Int -> Int -> Cmd Msg
get page perPage =
    Http.get
        { url = Builder.relative [ "api2", "users" ]
            [ Builder.int "page" page
            , Builder.int "per_page" perPage
            ]
        , expect = Http.expectJson OnData decoder
        }


config : Table.Config User () Msg
config =
    Table.dynamic
        OnTableExternal
        OnTableInternal
        (.id)
        [ Column.string .id "ID" "" ""
        , Column.string .firstname "Firstname" "" ""
        , Column.string .lastname "Lastname" "" ""
        , Column.string .email "Email" "" ""
        , Column.string .bio "bio" "" ""
        ]
        |> Config.withProgressive 10 5


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
    ( Table.init config, get 0 20 )


view : Model -> Html Msg
view model =
    div [] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTableExternal m ->
            ( Table.progressive m, get ((Table.pagination m).page + 1) 20 )

        OnTableInternal m ->
            ( m, Cmd.none )

        OnData (Ok res) ->
            ( model |> Table.loadedDynamic (Table.get model ++ res.items) res.total, Cmd.none )

        OnData (Err e) ->
            ( model, Cmd.none )
