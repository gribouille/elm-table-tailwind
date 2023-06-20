module Internal.Icon.Spinner exposing (..)

import Html exposing (div)
import Html.Attributes exposing (attribute, style)
import Svg exposing (Svg, g, path, svg)
import Svg.Attributes exposing (clipRule, d, fill, fillRule, height, opacity, viewBox, width)
import VirtualDom


view : Svg msg
view =
    div []
        [ keyframe
        , svg
            [ attribute "xmlns" "http://www.w3.org/2000/svg"
            , viewBox "0 0 24 24"
            , width "24"
            , height "24"
            , fill "none"
            , Svg.Attributes.style "animation: spinner 1s cubic-bezier(0.6, 0, 0.4, 1) infinite"
            ]
            [ g []
                [ path
                    [ fill "currentColor"
                    , opacity "0.2"
                    , fillRule "evenodd"
                    , clipRule "evenodd"
                    , d "M12 19C15.866 19 19 15.866 19 12C19 8.13401 15.866 5 12 5C8.13401 5 5 8.13401 5 12C5 15.866 8.13401 19 12 19ZM12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z"
                    ]
                    []
                , path
                    [ fill "currentColor"
                    , d "M12 22C17.5228 22 22 17.5228 22 12H19C19 15.866 15.866 19 12 19V22Z"
                    ]
                    []
                , path
                    [ fill "currentColor"
                    , d "M2 12C2 6.47715 6.47715 2 12 2V5C8.13401 5 5 8.13401 5 12H2Z"
                    ]
                    []
                ]
            ]
        ]


keyframe : VirtualDom.Node msg
keyframe =
    VirtualDom.node "style"
        []
        [ VirtualDom.text """
@keyframes spinner {
  0% {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(359deg);
  }
}
""" ]
