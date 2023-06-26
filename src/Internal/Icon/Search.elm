module Internal.Icon.Search exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (class, clipRule, d, fill, fillRule, viewBox)


view : Svg msg
view =
    svg
        [ class "w-4 h-4 text-gray-500"
        , fill "currentColor"
        , viewBox "0 0 20 20"
        , attribute "xmlns" "http://www.w3.org/2000/svg"
        ]
        [ path
            [ fillRule "evenodd"
            , clipRule "evenodd"
            , d "M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
            ]
            []
        ]
