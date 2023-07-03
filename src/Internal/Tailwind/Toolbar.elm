module Internal.Tailwind.Toolbar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
import Internal.Util exposing (iff, ifh)
import Svg exposing (Svg)


paginationMenuItem : Bool -> msg -> Int -> Html msg
paginationMenuItem isSelected click i =
    li
        []
        [ a
            [ class "block py-2 px-4 hover:bg-gray-100 hover:cursor-pointer"
            , onClick click
            ]
            [ text (String.fromInt i)
            , ifh isSelected (span [ class "text-green-700 font-bold float-right" ] [ text "✓" ])
            ]
        ]


dropdownItem : String -> msg -> (Bool -> msg) -> Bool -> Html msg
dropdownItem name click check isChecked =
    li []
        [ a
            [ class "block py-2 px-4 hover:bg-gray-100 hover:cursor-pointer"
            , onClick click
            ]
            [ text name
            , input
                [ class "is-checkradio float-right"
                , type_ "checkbox"
                , checked isChecked
                , onCheck check
                ]
                []
            ]
        ]


dropdown : { btn : Svg msg, tooltip : String, click : msg, isActive : Bool, items : List (Html msg) } -> Html msg
dropdown { btn, tooltip, click, isActive, items } =
    div [ class "relative", id "dropdown" ]
        [ button
            [ type_ "button"
            , onClick click
            , attribute "tooltip" tooltip
            , class """text-gray-900 bg-white border border-gray-200 hover:bg-gray-100
                       hover:text-blue-700 focus:ring-4 focus:outline-none focus:ring-blue-300
                       font-medium rounded-lg text-sm flex justify-center items-center p-0.5
                       w-10 h-9
                    """
            ]
            [ btn ]
        , div
            [ class <|
                "z-10 w-44 bg-white rounded divide-y divide-gray-100 shadow origin-top-right absolute right-0"
                    ++ iff isActive "" " hidden"
            ]
            [ ul [ class "py-1 text-sm text-gray-700" ] items ]
        ]
