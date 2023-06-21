module Internal.Icon.Layout exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, fill, viewBox)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 24 24", fill "none" ]
        [ p "M9 7H7V9H9V7Z"
        , p "M7 13V11H9V13H7Z"
        , p "M7 15V17H9V15H7Z"
        , p "M11 15V17H17V15H11Z"
        , p "M17 13V11H11V13H17Z"
        , p "M17 7V9H11V7H17Z"
        ]


p x =
    path [ fill "currentColor", d x ] []
