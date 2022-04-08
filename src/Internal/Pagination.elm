module Internal.Pagination exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Internal.Column exposing (Pipe)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Selection exposing (..)
import Internal.State exposing (..)
import Internal.Util exposing (..)
import Table.Types exposing (..)


tableFooterContent : Type -> Pipe msg -> Pipe msg -> Int -> Int -> Int -> Html msg
tableFooterContent type_ pipeInt pipeExt byPage page total =
    let
        nb =
            ceiling (toFloat total / toFloat byPage)

        ( ia, ib, ic ) =
            iff (nb == 1) ( 0, 0, 0 ) (pagIndex nb page)

        pipe =
            iff (type_ == Static) pipeInt pipeExt
    in
    div [ class "my-5 w-full flex flex-col items-center" ]
        [ nav
            [ attribute "role" "navigation"
            , attribute "aria-label" "pagination"
            ]
            [ ul [ class "inline-flex items-center -space-x-px" ]
                [ ifh (nb > 1) <|
                    li []
                        [ a
                            [ class <| "py-2 px-3 ml-0 leading-tight text-gray-500 bg-white rounded-l-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 hover:cursor-pointer" ++ iff (page == 0) " is-disabled" ""
                            , onClick <| pipe <| \state -> { state | page = state.page - 1 }
                            ]
                            [ text "Previous" ]
                        ]

                -- First page
                , ifh (nb > 3) <| paginationLink pipe page 0
                , ifh (nb > 3) <| paginationEllipsis

                -- Middle (m-1) m (m+1)
                , ifh (nb > 1) <| paginationLink pipe page ia
                , ifh (nb > 0) <| paginationLink pipe page ib
                , ifh (nb > 2) <| paginationLink pipe page ic

                -- Last page
                , ifh (nb > 4) <| paginationEllipsis
                , ifh (nb > 4) <| paginationLink pipe page (nb - 1)
                , ifh (nb > 1) <|
                    li []
                        [ a
                            [ class <| "py-2 px-3 leading-tight text-gray-500 bg-white rounded-r-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 hover:cursor-pointer" ++ iff (page == nb - 1) " is-disabled" ""
                            , onClick <| pipe <| \state -> { state | page = page + 1 }
                            ]
                            [ text "Next" ]
                        ]
                ]
            ]
        ]


paginationEllipsis : Html msg
paginationEllipsis =
    li [] [ span [ class "py-2 px-3 ml-0 leading-tight text-gray-300 bg-white border border-gray-300" ] [ text "…" ] ]


paginationLink : (({ a | page : Int } -> { a | page : Int }) -> msg) -> Int -> Int -> Html msg
paginationLink pipe page i =
    li []
        [ a
            [ class <|
                "py-2 px-3 bg-white border border-gray-300 hover:cursor-pointer "
                    ++ iff (page == i)
                        "text-blue-600 bg-blue-50 hover:bg-blue-100 hover:text-blue-700"
                        "leading-tight text-gray-500 hover:bg-gray-100 hover:text-gray-700"
            , attribute "aria-label" <| "Goto page " ++ String.fromInt (i + 1)
            , attribute "aria-current" <| iff (page == i) "page" ""
            , onClick <| pipe <| \state -> { state | page = i }
            ]
            [ text <| String.fromInt (i + 1) ]
        ]


pagIndex : Int -> Int -> ( Int, Int, Int )
pagIndex n c =
    if c == 0 then
        if n > 3 then
            let
                m =
                    floor (toFloat n / 2)
            in
            ( m - 1, m, m + 1 )

        else
            ( 0, 1, 2 )

    else if c == 1 then
        if n > 3 then
            ( 1, 2, 3 )

        else
            ( 0, 1, 2 )

    else if c == n - 1 then
        if n > 3 then
            ( n - 4, n - 3, n - 2 )

        else
            ( n - 3, n - 2, n - 1 )

    else if c == n - 2 then
        ( n - 4, n - 3, n - 2 )

    else
        ( c - 1, c, c + 1 )
