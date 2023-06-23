module Internal.Icon.Layout exposing (..)

import Internal.Icon.Icon as Icon
import Svg exposing (..)


view : Svg msg
view =
    Icon.view
        [ "M9 7H7V9H9V7Z"
        , "M7 13V11H9V13H7Z"
        , "M7 15V17H9V15H7Z"
        , "M11 15V17H17V15H11Z"
        , "M17 13V11H11V13H17Z"
        , "M17 7V9H11V7H17Z"
        ]
