module Internal.Icon.SubColumn exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, height, viewBox, width)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 24 24" ]
        [ path [ d "m22.5 24h-3c-.827 0-1.5-.673-1.5-1.5v-21c0-.827.673-1.5 1.5-1.5h3c.827 0 1.5.673 1.5 1.5v21c0 .827-.673 1.5-1.5 1.5zm-3-23c-.275 0-.5.224-.5.5v21c0 .276.225.5.5.5h3c.275 0 .5-.224.5-.5v-21c0-.276-.225-.5-.5-.5z" ] []
        , path [ d "m13.5 24h-3c-.827 0-1.5-.673-1.5-1.5v-21c0-.827.673-1.5 1.5-1.5h3c.827 0 1.5.673 1.5 1.5v21c0 .827-.673 1.5-1.5 1.5zm-3-23c-.275 0-.5.224-.5.5v21c0 .276.225.5.5.5h3c.275 0 .5-.224.5-.5v-21c0-.276-.225-.5-.5-.5z" ] []
        , path [ d "m4.5 24h-3c-.827 0-1.5-.673-1.5-1.5v-21c0-.827.673-1.5 1.5-1.5h3c.827 0 1.5.673 1.5 1.5v21c0 .827-.673 1.5-1.5 1.5zm-3-23c-.275 0-.5.224-.5.5v21c0 .276.225.5.5.5h3c.275 0 .5-.224.5-.5v-21c0-.276-.225-.5-.5-.5z" ] []
        ]
