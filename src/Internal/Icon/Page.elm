module Internal.Icon.Page exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, height, viewBox, width)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 32 32" ]
        [ path [ d "M25,22V6a3,3,0,0,0-3-3H6A3,3,0,0,0,3,6V22a3,3,0,0,0,3,3H22A3,3,0,0,0,25,22ZM5,22V6A1,1,0,0,1,6,5H22a1,1,0,0,1,1,1V22a1,1,0,0,1-1,1H6A1,1,0,0,1,5,22Z" ] []
        , path [ d "M28,8a1,1,0,0,0-1,1V22.494A4.511,4.511,0,0,1,22.494,27H9a1,1,0,0,0,0,2H22.494A6.514,6.514,0,0,0,29,22.494V9A1,1,0,0,0,28,8Z" ] []
        ]
