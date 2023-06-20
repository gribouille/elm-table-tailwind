module Internal.Icon.Expand exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, fill, height, viewBox, width)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 24 24", fill "none" ]
        [ path
            [ fill "currentColor"
            , d "M13.8995 4.10052V2.10052H21.8995V10.1005H19.8995V5.51477L14.1213 11.293L12.7071 9.87878L18.4854 4.10052H13.8995Z"
            ]
            []
        , path
            [ fill "currentColor"
            , d "M4.10046 13.8995H2.10046V21.8995H10.1005V19.8995H5.51468L11.2929 14.1212L9.87872 12.707L4.10046 18.4853V13.8995Z"
            ]
            []
        ]
