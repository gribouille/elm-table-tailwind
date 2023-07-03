module Internal.Subscription exposing (..)

import Browser.Events
import Internal.Column exposing (Pipe)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Json.Decode as Decode
import Table.Types exposing (Action(..))


subscriptions : Config a b msg -> Model a -> Sub msg
subscriptions config model =
    if isModal model then
        Browser.Events.onMouseDown (outsideTarget (resolve config model Neutral) "dropdown")

    else
        Sub.none


isModal : Model a -> Bool
isModal (Model { state }) =
    state.btColumns || state.btPagination || state.btSubColumns


outsideTarget : Pipe msg -> String -> Decode.Decoder msg
outsideTarget pipe dropdownId =
    Decode.field "target" (isOutsideDropdown dropdownId)
        |> Decode.andThen
            (\isOutside ->
                if isOutside then
                    Decode.succeed <|
                        pipe <|
                            \state ->
                                { state
                                    | btColumns = False
                                    , btPagination = False
                                    , btSubColumns = False
                                }

                else
                    Decode.fail "inside dropdown"
            )


isOutsideDropdown : String -> Decode.Decoder Bool
isOutsideDropdown dropdownId =
    Decode.oneOf
        [ Decode.field "id" Decode.string
            |> Decode.andThen
                (\id ->
                    if dropdownId == id then
                        -- found match by id
                        Decode.succeed False

                    else
                        -- try next decoder
                        Decode.fail "continue"
                )
        , Decode.lazy (\_ -> isOutsideDropdown dropdownId |> Decode.field "parentNode")

        -- fallback if all previous decoders failed
        , Decode.succeed True
        ]
