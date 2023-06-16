module Internal.Icon.Collapse exposing (..)

import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (d, fill, height, viewBox, width)


view : Svg msg
view =
    svg [ attribute "xmlns" "http://www.w3.org/2000/svg", viewBox "0 0 24 24", fill "none" ]
        [ path
            [ fill "currentColor"
            , d "M14.567 8.02947L20.9105 1.76929L22.3153 3.19282L15.9916 9.43352L19.5614 9.44772L19.5534 11.4477L12.5535 11.4199L12.5813 4.41992L14.5813 4.42788L14.567 8.02947Z"
            ]
            []
        , path
            [ fill "currentColor"
            , d "M7.97879 14.5429L4.40886 14.5457L4.40729 12.5457L11.4073 12.5402L11.4128 19.5402L9.41277 19.5417L9.40995 15.9402L3.09623 22.2306L1.68463 20.8138L7.97879 14.5429Z"
            ]
            []
        ]
