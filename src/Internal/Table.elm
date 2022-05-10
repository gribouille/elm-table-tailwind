module Internal.Table exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Pagination exposing (..)
import Internal.Selection exposing (..)
import Internal.State exposing (..)
import Internal.Toolbar
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)
import Svg as S
import Svg.Attributes as SA
import Table.Types exposing (..)



--
-- Initialize
--


init : Config a b msg -> Model a
init (Config cfg) =
    let
        fnVisible =
            \(Column { name, default }) -> iff default (Just name) Nothing

        visibleColumns =
            List.filterMap fnVisible cfg.table.columns

        visibleSubColumns =
            Maybe.map
                (\(SubTable _ c) -> List.filterMap fnVisible c.columns)
                cfg.subtable
                |> Maybe.withDefault []
    in
    Model
        { state =
            { page = 0
            , byPage =
                case cfg.pagination of
                    ByPage { initial } ->
                        initial

                    Progressive { initial } ->
                        initial

                    _ ->
                        0
            , search = ""
            , btPagination = False
            , btColumns = False
            , btSubColumns = False
            , table = StateTable visibleColumns [] [] [] Nothing Ascending
            , subtable = StateTable visibleSubColumns [] [] [] Nothing Ascending
            }
        , rows = Rows Loading
        }



--
-- View
--


view : Config a b msg -> Model a -> Html msg
view config ((Model m) as model) =
    let
        pipeInt =
            pipeInternal config model

        pipeExt =
            pipeExternal config model
    in
    div [ class "relative overflow-x-auto shadow-md sm:rounded-lg w-full h-full" ] <|
        tableHeader config pipeExt pipeInt m.state
            :: (case m.rows of
                    Rows Loading ->
                        [ div [ class "flex flex-col items-center my-11" ] [ span [ class "gg-spinner" ] [] ]
                        ]

                    Rows (Loaded { total, rows }) ->
                        [ tableContent config pipeExt pipeInt m.state rows
                        , tableFooter config pipeInt pipeExt m.state total
                        ]

                    Rows (Failed msg) ->
                        [ errorView msg ]
               )



--
-- Header
--


tableHeader : Config a b msg -> Pipe msg -> Pipe msg -> State -> Html msg
tableHeader ((Config cfg) as config) pipeExt pipeInt state =
    div [ class "mb-4 mt-2 flex gap-2" ]
        [ div [ class "grow" ] <| headerSearch pipeExt pipeInt
        , div [ class "flex gap-2" ] cfg.toolbar
        , div [ class "flex gap-2" ] <| Internal.Toolbar.view config pipeExt pipeInt state
        ]


headerSearch : Pipe msg -> Pipe msg -> List (Html msg)
headerSearch pipeExt pipeInt =
    [ label [ for "elm-table-tailwind-search", class "sr-only" ] [ text "Search" ]
    , div [ class "relative" ]
        [ div [ class "absolute inset-y-0 right-0 flex items-center mr-3 pointer-events-none" ]
            [ search
            ]
        , input
            [ class "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2"
            , type_ "text"
            , placeholder "Search..."
            , id "elm-table-tailwind-search"
            , onInput
                (\s ->
                    pipeInt <|
                        \state ->
                            { state
                                | search = s
                                , btPagination = False
                                , btColumns = False
                                , btSubColumns = False
                            }
                )
            , onKeyDown
                (\i ->
                    iff (i == 13)
                        (pipeExt <|
                            \state ->
                                { state
                                    | search = state.search
                                    , page = iff (state.search /= "") 0 state.page
                                }
                        )
                        (pipeInt <| \state -> state)
                )
            ]
            []
        ]
    ]


search : S.Svg msg
search =
    S.svg
        [ SA.class "w-4 h-4 text-gray-500"
        , SA.fill "currentColor"
        , SA.viewBox "0 0 20 20"
        , attribute "xmlns" "http://www.w3.org/2000/svg"
        ]
        [ S.path
            [ SA.fillRule "evenodd"
            , SA.clipRule "evenodd"
            , SA.d "M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
            ]
            []
        ]



--
-- Content
--


tableContent : Config a b msg -> Pipe msg -> Pipe msg -> State -> List (Row a) -> Html msg
tableContent ((Config cfg) as config) pipeExt pipeInt state rows =
    let
        expandColumn =
            ifMaybe (cfg.table.expand /= Nothing) (expand pipeInt lensTable cfg.table.getID)

        subtableColumn =
            case cfg.subtable of
                Just (SubTable get _) ->
                    Just <| subtable (get >> List.isEmpty) pipeInt lensTable cfg.table.getID

                _ ->
                    Nothing

        selectColumn =
            ifMaybe (cfg.selection /= Disable) (selectionParent pipeInt config rows)

        visibleColumns =
            List.filter
                (\(Column c) -> List.member c.name state.table.visible)
                cfg.table.columns

        columns =
            visibleColumns
                |> prependMaybe subtableColumn
                |> prependMaybe expandColumn
                |> prependMaybe selectColumn

        -- sort by columns
        srows =
            iff (cfg.type_ == Static) (sort cfg.table.columns state.table rows) rows

        -- filter by search
        filter =
            \rs ->
                iff (String.isEmpty state.search)
                    rs
                    (List.filter
                        (\(Row a) ->
                            List.any
                                (\(Column c) ->
                                    case c.searchable of
                                        Nothing ->
                                            False

                                        Just fn ->
                                            String.contains state.search (fn a)
                                )
                                cfg.table.columns
                        )
                        rows
                    )

        frows =
            iff (cfg.type_ == Static) (filter srows) srows

        -- cut the results for the pagination
        cut =
            \rs ->
                rs
                    |> Array.fromList
                    |> Array.slice (state.page * state.byPage) ((state.page + 1) * state.byPage)
                    |> Array.toList

        prows =
            iff (cfg.type_ == Static && cfg.pagination /= None) (cut frows) frows
    in
    table [ class "w-full text-sm text-left text-gray-600" ]
        [ tableContentHead lensTable (cfg.selection /= Disable) pipeExt pipeInt columns state
        , tableContentBody config pipeExt pipeInt columns state prows
        ]


tableContentHead :
    Lens State StateTable
    -> Bool
    -> Pipe msg
    -> Pipe msg
    -> List (Column a msg)
    -> State
    -> Html msg
tableContentHead lens hasSelection pipeExt pipeInt columns state =
    thead [ class "text-xs text-gray-700 uppercase bg-gray-50" ]
        [ tr [] <|
            List.indexedMap
                (\i ((Column c) as col) ->
                    if i == 0 && hasSelection then
                        th [ scope "col", class "px-4 py-3", style "width" c.width ] <|
                            c.viewHeader col ( state, lens, pipeInt )

                    else
                        th [ scope "col", class "px-4 py-3", style "width" c.width ] <|
                            c.viewHeader col ( state, lens, pipeExt )
                )
                columns
        ]


tableContentBody :
    Config a b msg
    -> Pipe msg
    -> Pipe msg
    -> List (Column a msg)
    -> State
    -> List (Row a)
    -> Html msg
tableContentBody config pipeExt pipeInt columns state rows =
    tbody [] <| List.concat (List.map (tableContentBodyRow config pipeExt pipeInt columns state) rows)


tableContentBodyRow :
    Config a b msg
    -> Pipe msg
    -> Pipe msg
    -> List (Column a msg)
    -> State
    -> Row a
    -> List (Html msg)
tableContentBodyRow ((Config cfg) as config) pipeExt pipeInt columns state (Row r) =
    [ tr [ class "bg-white border-b hover:bg-gray-50" ] <|
        List.map
            (\(Column c) ->
                td [ class <| "px-4 py-2 " ++ c.class, style "width" c.width ] <|
                    c.viewCell r ( state, pipeExt )
            )
            columns
    , case ( cfg.table.expand, List.member (cfg.table.getID r) state.table.expanded ) of
        ( Just (Column c), True ) ->
            tr [ class "bg-white border-b hover:bg-gray-50" ]
                [ td [ class "px-4 py-2", colspan (List.length columns) ] <|
                    c.viewCell r ( state, pipeExt )
                ]

        _ ->
            text ""
    , case ( cfg.subtable, List.member (cfg.table.getID r) state.table.subtable ) of
        ( Just (SubTable getValue conf), True ) ->
            tr []
                [ td [ class "px-4 py-2", colspan (List.length columns) ]
                    [ subtableContent config
                        pipeExt
                        pipeInt
                        (cfg.table.getID r)
                        conf
                        state
                        (getValue r)
                    ]
                ]

        _ ->
            text ""
    ]


subtableContent :
    Config a b msg
    -> Pipe msg
    -> Pipe msg
    -> RowID
    -> ConfTable b msg
    -> State
    -> List b
    -> Html msg
subtableContent ((Config cfg) as config) pipeExt pipeInt parent subConfig state data =
    let
        expandColumn =
            ifMaybe (subConfig.expand /= Nothing) (expand pipeInt lensTable subConfig.getID)

        rows =
            sort subConfig.columns state.subtable <| List.map Row data

        selectColumn =
            ifMaybe (cfg.selection /= Disable) (selectionChild pipeInt config rows parent)

        visibleColumns =
            List.filter
                (\(Column c) -> List.member c.name state.subtable.visible)
                subConfig.columns

        columns =
            visibleColumns
                |> prependMaybe expandColumn
                |> prependMaybe selectColumn
    in
    div [ class "relative overflow-x-auto shadow-md sm:rounded-lg" ]
        [ table [ class "w-full text-sm text-left text-gray-500" ]
            [ tableContentHead lensSubTable (cfg.selection /= Disable) pipeInt pipeExt columns state
            , subtableContentBody pipeExt subConfig columns state rows
            ]
        ]


subtableContentBody :
    Pipe msg
    -> ConfTable a msg
    -> List (Column a msg)
    -> State
    -> List (Row a)
    -> Html msg
subtableContentBody pipeExt cfg columns state rows =
    tbody [] <| List.concat (List.map (subtableContentBodyRow pipeExt cfg columns state) rows)


subtableContentBodyRow :
    Pipe msg
    -> ConfTable a msg
    -> List (Column a msg)
    -> State
    -> Row a
    -> List (Html msg)
subtableContentBodyRow pipeExt cfg columns state (Row r) =
    [ tr [ class "hover:bg-slate-100" ] <|
        List.map
            (\(Column c) ->
                td [ class ("px-4 py-2 " ++ c.class), style "width" c.width ] <| c.viewCell r ( state, pipeExt )
            )
            columns
    , case ( cfg.expand, List.member (cfg.getID r) state.subtable.expanded ) of
        ( Just (Column c), True ) ->
            tr [ class "hover:bg-slate-100" ]
                [ td [ class "px-4 py-2", colspan (List.length columns) ] <| c.viewCell r ( state, pipeExt )
                ]

        _ ->
            text ""
    ]



--
-- Footer
--


tableFooter : Config a b msg -> Pipe msg -> Pipe msg -> State -> Int -> Html msg
tableFooter (Config cfg) pipeInt pipeExt state total =
    if cfg.pagination == None then
        text ""

    else
        tableFooterContent cfg.type_ pipeInt pipeExt state.byPage state.page total



--
-- SORT
--


sort : List (Column a msg) -> StateTable -> List (Row a) -> List (Row a)
sort columns state rows =
    let
        compFn =
            Maybe.andThen (\(Column c) -> c.sortable) <|
                find (\(Column c) -> Just c.field == state.orderBy) columns
    in
    maybe rows (sortRowsFromStatus state.order rows) compFn


sortRowsFromStatus : Sort -> List (Row a) -> (a -> a -> Order) -> List (Row a)
sortRowsFromStatus order rows comp =
    case order of
        StandBy ->
            rows

        Descending ->
            sortRows comp rows

        Ascending ->
            List.reverse (sortRows comp rows)


sortRows : (a -> a -> Order) -> List (Row a) -> List (Row a)
sortRows comp rows =
    List.sortWith (\(Row a) (Row b) -> comp a b) rows
