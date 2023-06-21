module Api.Local exposing (..)

import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Url.Builder as Builder


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


get : (Result Error Payload -> msg) -> Int -> Int -> Cmd msg
get on page perPage =
    Http.get
        { url =
            Builder.relative [ "api2", "users" ]
                [ Builder.int "page" page
                , Builder.int "per_page" perPage
                ]
        , expect = Http.expectJson on decoder
        }
