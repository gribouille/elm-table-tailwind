module Api.ReqRes exposing (..)

import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Url.Builder as Builder


type alias User =
    { id : Int
    , firstname : String
    , lastname : String
    , email : String
    , avatar : String
    }


type alias Payload =
    { page : Int
    , perPage : Int
    , totalPages : Int
    , data : List User
    }


decoder : Decoder Payload
decoder =
    Decode.succeed Payload
        |> required "page" Decode.int
        |> required "per_page" Decode.int
        |> required "total_pages" Decode.int
        |> required "data" (Decode.list decoderUser)


decoderUser : Decoder User
decoderUser =
    Decode.succeed User
        |> required "id" Decode.int
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "email" Decode.string
        |> required "avatar" Decode.string


get : (Result Error Payload -> msg) -> Int -> Cmd msg
get on page =
    Http.get
        { url = Builder.relative [ "api", "users" ] [ Builder.int "page" page ]
        , expect = Http.expectJson on decoder
        }
