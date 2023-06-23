module Internal.Icon.Grid exposing (..)

import Internal.Icon.Icon as Icon
import Svg exposing (..)


view : Svg msg
view =
    Icon.view
        [ "M11 7H7V11H11V7Z"
        , "M11 13H7V17H11V13Z"
        , "M13 13H17V17H13V13Z"
        , "M17 7H13V11H17V7Z"
        ]
