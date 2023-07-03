module Internal.Icon.GridSmall exposing (..)

import Internal.Icon.Icon as Icon
import Svg exposing (..)


view : Svg msg
view =
    Icon.view
        [ "M7 7H9V9H7V7Z"
        , "M11 7H13V9H11V7Z"
        , "M17 7H15V9H17V7Z"
        , "M7 11H9V13H7V11Z"
        , "M13 11H11V13H13V11Z"
        , "M15 11H17V13H15V11Z"
        , "M9 15H7V17H9V15Z"
        , "M11 15H13V17H11V15Z"
        , "M17 15H15V17H17V15Z"
        ]
