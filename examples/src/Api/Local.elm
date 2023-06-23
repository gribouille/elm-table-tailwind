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


type alias Reservation =
    { id : String
    , airline : Airline
    , airplane : Airplane
    , number : Int
    , seat : String
    }


type alias Airline =
    { name : String, code : String }


type alias Airplane =
    { name : String, code : String }


type alias Users =
    { total : Int
    , items : List User
    }


type alias Reservations =
    { index : Int
    , items : List Reservation
    }


decoderUsers : Decoder Users
decoderUsers =
    Decode.succeed Users
        |> required "total" Decode.int
        |> required "items" (Decode.list decoderUser)


decoderReservations : Decoder Reservations
decoderReservations =
    Decode.succeed Reservations
        |> required "index" Decode.int
        |> required "items" (Decode.list decoderReservation)


decoderUser : Decoder User
decoderUser =
    Decode.succeed User
        |> required "id" Decode.string
        |> required "firstname" Decode.string
        |> required "lastname" Decode.string
        |> required "email" Decode.string
        |> required "bio" Decode.string


decoderReservation : Decoder Reservation
decoderReservation =
    Decode.succeed Reservation
        |> required "id" Decode.string
        |> required "airline" decoderAirline
        |> required "airplane" decoderAirplane
        |> required "number" Decode.int
        |> required "seat" Decode.string


decoderAirline : Decoder Airline
decoderAirline =
    Decode.succeed Airline
        |> required "name" Decode.string
        |> required "iataCode" Decode.string


decoderAirplane : Decoder Airplane
decoderAirplane =
    Decode.succeed Airplane
        |> required "name" Decode.string
        |> required "iataTypeCode" Decode.string


getUsers : (Result Error Users -> msg) -> Int -> Int -> Cmd msg
getUsers on page perPage =
    Http.get
        { url =
            Builder.relative [ "api2", "users" ]
                [ Builder.int "page" page
                , Builder.int "per_page" perPage
                ]
        , expect = Http.expectJson on decoderUsers
        }


getReservations : (Result Error Reservations -> msg) -> Int -> Int -> Cmd msg
getReservations on index perPage =
    Http.get
        { url =
            Builder.relative [ "api2", "reservations" ]
                [ Builder.int "index" index
                , Builder.int "per_page" perPage
                ]
        , expect = Http.expectJson on decoderReservations
        }
