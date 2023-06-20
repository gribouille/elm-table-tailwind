module Internal.Icon.Grid exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, fill, height, viewBox, width)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 24 24", fill "none" ]
        [ p "M11 7H7V11H11V7Z"
        , p "M11 13H7V17H11V13Z"
        , p "M13 13H17V17H13V13Z"
        , p "M17 7H13V11H17V7Z"
        ]


p x =
    path [ fill "currentColor", d x ] []
