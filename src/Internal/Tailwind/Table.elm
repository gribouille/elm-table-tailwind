module Internal.Tailwind.Table exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Internal.Icon.Search as Search
import Internal.Icon.Spinner as Spinner
import Internal.Util exposing (onKeyDown)



{-

   frame
     | loading

-}


frame : List (Html msg) -> Html msg
frame items =
    div [ class "relative overflow-x-auto shadow-md sm:rounded-lg w-full h-full p-1" ] items


loading : Html msg
loading =
    div [ class "flex flex-col items-center my-11" ] [ Spinner.view ]


header : { search : List (Html msg), custom : List (Html msg), internal : List (Html msg) } -> Html msg
header x =
    div [ class "mb-4 mt-2 flex gap-2" ]
        [ div [ class "grow" ] x.search
        , div [ class "flex gap-2" ] x.custom
        , div [ class "flex gap-2" ] x.internal
        ]


search : { input : String -> msg, keyDown : Int -> msg } -> List (Html msg)
search x =
    [ label [ for "elm-table-tailwind-search", class "sr-only" ] [ text "Search" ]
    , div [ class "relative" ]
        [ div [ class "absolute inset-y-0 right-4 flex items-center pl-3 pointer-events-none" ]
            [ Search.view
            ]
        , input
            [ class """bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg
                       focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2"""
            , type_ "text"
            , placeholder "Search..."
            , id "elm-table-tailwind-search"
            , onInput x.input
            , onKeyDown x.keyDown
            ]
            []
        ]
    ]


content : List (Html msg) -> Html msg
content items =
    table [ class "table-auto w-full text-sm text-left text-gray-600" ] items


head : List (Html msg) -> Html msg
head items =
    thead [ class "text-xs text-gray-700 uppercase bg-gray-50" ] [ tr [] items ]


headItem width items =
    th [ scope "col", class "px-4 py-3", style "width" width ] items


body items =
    tbody [] items


bodyContent x =
    [ tr [ class "bg-white border-b hover:bg-gray-50" ] x.cells
    , x.expand
    , x.subtable
    ]


cell cls width items =
    td [ class <| "px-4 py-2 " ++ cls, style "width" width ] items


expandRow span items =
    tr [ class "bg-white border-b hover:bg-gray-50" ]
        [ td [ class "px-4 py-2", colspan span ] items
        ]


subtableRow span tbl =
    tr []
        [ td [ class "px-4 py-2", colspan span ] [ tbl ] ]


subtable item =
    div [ class "relative overflow-x-auto shadow-md sm:rounded-lg" ]
        [ item ]


subtableLoading =
    div [ class "m-4 flex flex-col items-center" ] [ Spinner.view ]


subtableContent items =
    table [ class "w-full text-sm text-left text-gray-500" ] items


subtableBodyContent x =
    [ tr [ class "hover:bg-slate-100" ] x.cells
    , x.expand
    ]


errorView : String -> Html msg
errorView msg =
    div [ class "m-6 bg-red-100 text-red-700 p-6 border-t-2 border-b-2 border-red-700" ]
        [ text msg
        ]
