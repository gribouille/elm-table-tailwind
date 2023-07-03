module Internal.Tailwind.Pagination exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Internal.Tailwind.Util exposing (isDisabled)
import Internal.Util exposing (iff)
import Table.Types exposing (..)


progressive : Html msg -> Html msg
progressive item =
    div [ class "my-5 w-full flex flex-col items-center" ]
        [ item
        ]


btnProgressive : Int -> msg -> Html msg
btnProgressive n click =
    a
        [ class "text-base text-gray-400 bg-white rounded-r-lg hover:text-gray-700 hover:cursor-pointer"
        , onClick click
        ]
        [ text <| "Show more (" ++ String.fromInt n ++ ") ..." ]


pagination items =
    div [ class "my-5 w-full flex flex-col items-center" ]
        [ nav [ attribute "role" "navigation", attribute "aria-label" "pagination" ]
            [ ul [ class "inline-flex items-center -space-x-px" ] items ]
        ]


btnPrevious isDisable click =
    li []
        [ a
            [ class <|
                """py-2 px-3 ml-0 leading-tight text-gray-500 bg-white
                                   rounded-l-lg border border-gray-300 hover:bg-gray-100
                                   hover:text-gray-700 hover:cursor-pointer """
                    ++ iff isDisable isDisabled ""
            , onClick click
            ]
            [ text "Previous" ]
        ]


btnNext isDisable click =
    li []
        [ a
            [ class <|
                """py-2 px-3 leading-tight text-gray-500 bg-white rounded-r-lg
                                   border border-gray-300 hover:bg-gray-100 hover:text-gray-700
                                   hover:cursor-pointer """
                    ++ iff isDisable isDisabled ""
            , onClick click
            ]
            [ text "Next" ]
        ]


ellipsis : Html msg
ellipsis =
    li [] [ span [ class "py-2 px-3 ml-0 leading-tight text-gray-300 bg-white border border-gray-300" ] [ text "…" ] ]


link : Bool -> Int -> msg -> Html msg
link isActive n click =
    li []
        [ a
            [ class <|
                "py-2 px-3 bg-white border border-gray-300 hover:cursor-pointer "
                    ++ iff isActive
                        "text-blue-600 bg-blue-50 hover:bg-blue-100 hover:text-blue-700"
                        "leading-tight text-gray-500 hover:bg-gray-100 hover:text-gray-700"
            , attribute "aria-label" <| "Goto page " ++ String.fromInt n
            , attribute "aria-current" <| iff isActive "page" ""
            , onClick <| click
            ]
            [ text <| String.fromInt n ]
        ]
