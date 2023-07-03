module Internal.Icon.Icon exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, fill, height, viewBox, width)


view : List String -> Svg msg
view ps =
    svg
        [ attribute "xmlns" "http://www.w3.org/2000/svg"
        , viewBox "0 0 24 24"
        , height "24px"
        , width "24px"
        , fill "none"
        ]
    <|
        List.map p ps


p : String -> Svg msg
p x =
    path [ fill "currentColor", d x ] []
