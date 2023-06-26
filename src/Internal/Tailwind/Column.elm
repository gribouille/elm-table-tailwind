module Internal.Tailwind.Column exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Internal.Icon.Collapse as Collapse
import Internal.Icon.Expand as Expand
import Internal.Icon.Minus as Minus
import Internal.Icon.Plus as Plus
import Internal.Tailwind.Util exposing (isDisabled)
import Internal.Util exposing (iff, ifh)
import Table.Types exposing (Sort(..))


expand : Bool -> msg -> List (Html msg)
expand isExpanded click =
    [ button
        [ class "w-6 h-6 pl-3 text-blue-600 hover:text-blue-300"
        , type_ "button"
        , onClick click
        ]
        [ iff isExpanded Collapse.view Expand.view ]
    ]


subtableDisable : List (Html msg)
subtableDisable =
    [ a [ class <| "w-6 h-6 " ++ isDisabled, disabled True ]
        [ Plus.view ]
    ]


subtable : Bool -> msg -> List (Html msg)
subtable isExpanded click =
    [ button
        [ class "w-6 h-6 text-blue-600 hover:text-blue-300"
        , type_ "button"
        , onClick click
        ]
        [ iff isExpanded Minus.view Plus.view ]
    ]


header : { abbrev : String, name : String, isSortable : Bool, sort : Sort, click : msg } -> List (Html msg)
header { abbrev, name, isSortable, sort, click } =
    [ iff (String.isEmpty abbrev) (span [] [ text name ]) (abbr [ title name ] [ text abbrev ])
    , ifh isSortable <|
        a
            [ class "ml-2 text-gray-400 hover:text-blue-500 hover:cursor-pointer"
            , onClick click
            ]
            [ text <| symbolSort sort ]
    ]


symbolSort : Sort -> String
symbolSort order =
    case order of
        Ascending ->
            "↿"

        Descending ->
            "⇂"

        StandBy ->
            "⇅"
