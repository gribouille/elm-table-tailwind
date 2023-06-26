module Internal.Pagination exposing (..)

import Html exposing (..)
import Internal.Column exposing (Pipe)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Icon.Spinner as Spinner
import Internal.Selection exposing (..)
import Internal.State exposing (..)
import Internal.Tailwind.Pagination
import Internal.Util exposing (..)
import Table.Types exposing (..)


progressive : Pipe msg -> Bool -> Int -> Int -> Int -> Html msg
progressive onShowMore isLoading byPage step total =
    Internal.Tailwind.Pagination.progressive <|
        case ( isLoading, byPage < total ) of
            ( True, _ ) ->
                Spinner.view

            ( False, True ) ->
                Internal.Tailwind.Pagination.btnProgressive (total - byPage) <|
                    onShowMore (\state -> { state | byPage = byPage + step })

            _ ->
                text ""


pagination : Pipe msg -> Int -> Int -> Int -> Html msg
pagination onChange byPage page total =
    let
        nb =
            ceiling (toFloat total / toFloat byPage)

        ( ia, ib, ic ) =
            iff (nb == 1) ( 0, 0, 0 ) (pagIndex nb page)
    in
    Internal.Tailwind.Pagination.pagination
        [ ifh (nb > 1) <|
            Internal.Tailwind.Pagination.btnPrevious (page == 0) <|
                onChange (\state -> iff (page == 0) state { state | page = state.page - 1 })

        -- First page
        , ifh (nb > 3) <| link onChange page 0
        , ifh (nb > 3) <| Internal.Tailwind.Pagination.ellipsis

        -- Middle (m-1) m (m+1)
        , ifh (nb > 1) <| link onChange page ia
        , ifh (nb > 0) <| link onChange page ib
        , ifh (nb > 2) <| link onChange page ic

        -- Last page
        , ifh (nb > 4) <| Internal.Tailwind.Pagination.ellipsis
        , ifh (nb > 4) <| link onChange page (nb - 1)
        , ifh (nb > 1) <|
            Internal.Tailwind.Pagination.btnNext (page == nb - 1) <|
                onChange (\state -> iff (page == nb - 1) state { state | page = page + 1 })
        ]


link : (({ a | page : Int } -> { a | page : Int }) -> msg) -> Int -> Int -> Html msg
link pipe page i =
    Internal.Tailwind.Pagination.link (page == i) (i + 1) <| pipe <| \state -> { state | page = i }


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
