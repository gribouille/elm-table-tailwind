module Internal.Tailwind.Selection exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck)


parentHeader : (Bool -> msg) -> List (Html msg)
parentHeader check =
    [ div [ class "flex items-center" ]
        [ input
            [ class "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
            , type_ "checkbox"
            , id "checkbox-all"
            , onCheck check
            ]
            []
        , label [ for "checkbox-all", class "sr-only" ] [ text "checkbox" ]
        ]
    ]


parentCell : { isCheck : Bool, check : Bool -> msg } -> List (Html msg)
parentCell { isCheck, check } =
    [ div [ class "flex items-center" ]
        [ input
            [ class "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
            , type_ "checkbox"
            , checked isCheck
            , onCheck check
            ]
            []
        , label [ class "sr-only" ] [ text "checkbox" ]
        ]
    ]


childHeader { isDisable, check } =
    [ input
        [ class "checkbox"
        , type_ "checkbox"
        , onCheck check
        , disabled isDisable
        ]
        []
    ]


childCell { isDisable, check, value } =
    [ input
        [ class "checkbox"
        , type_ "checkbox"
        , checked value
        , onCheck check
        , disabled isDisable
        ]
        []
    ]
