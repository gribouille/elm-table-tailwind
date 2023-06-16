module Internal.Icon.GridSmall exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, fill, height, viewBox, width)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 24 24", fill "none" ]
        [ p "M7 7H9V9H7V7Z"
        , p "M11 7H13V9H11V7Z"
        , p "M17 7H15V9H17V7Z"
        , p "M7 11H9V13H7V11Z"
        , p "M13 11H11V13H13V11Z"
        , p "M15 11H17V13H15V11Z"
        , p "M9 15H7V17H9V15Z"
        , p "M11 15H13V17H11V15Z"
        , p "M17 15H15V17H17V15Z"
        ]


p x =
    path [ fill "currentColor", d x ] []



{-

   <svg width="24" height="24" viewBox="0 0 24 24",
     p "M7 7H9V9H7V7Z",
     p "M11 7H13V9H11V7Z",
     p "M17 7H15V9H17V7Z",
     p "M7 11H9V13H7V11Z",
     p "M13 11H11V13H13V11Z",
     p "M15 11H17V13H15V11Z",
     p "M9 15H7V17H9V15Z",
     p "M11 15H13V17H11V15Z",
     p "M17 15H15V17H17V15Z",

-}
