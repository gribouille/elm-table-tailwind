module Internal.Table exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Icon.Spinner as Spinner
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
            , progressive = False
            , search = ""
            , btPagination = False
            , btColumns = False
            , btSubColumns = False
            , table = StateTable visibleColumns [] [] [] Nothing Ascending []
            , subtable = StateTable visibleSubColumns [] [] [] Nothing Ascending []
            }
        , rows = Rows Loading
        }



--
-- View
--


view : Config a b msg -> Model a -> Html msg
view config ((Model m) as model) =
    let
        resolver =
            resolve config model
    in
    div [ class "relative overflow-x-auto shadow-md sm:rounded-lg w-full h-full p-1" ] <|
        tableHeader config resolver m.state
            :: (case m.rows of
                    Rows Loading ->
                        [ div [ class "flex flex-col items-center my-11" ] [ Spinner.view ]
                        ]

                    Rows (Loaded { total, rows }) ->
                        [ tableContent config resolver m.state rows
                        , tableFooter config resolver m.state total
                        ]

                    Rows (Failed msg) ->
                        [ errorView msg ]
               )



--
-- Header
--


tableHeader : Config a b msg -> Resolver msg -> State -> Html msg
tableHeader ((Config cfg) as config) resolve state =
    div [ class "mb-4 mt-2 flex gap-2" ]
        [ div [ class "grow" ] <| headerSearch (resolve EnterSearch) (resolve InputSearch) (resolve Neutral)
        , div [ class "flex gap-2" ] cfg.toolbar
        , div [ class "flex gap-2" ] <| Internal.Toolbar.view config resolve state
        ]


headerSearch : Pipe msg -> Pipe msg -> Pipe msg -> List (Html msg)
headerSearch onEnter onIn onInternal =
    [ label [ for "elm-table-tailwind-search", class "sr-only" ] [ text "Search" ]
    , div [ class "relative" ]
        [ div [ class "absolute inset-y-0 right-4 flex items-center pl-3 pointer-events-none" ]
            [ search
            ]
        , input
            [ class "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2"
            , type_ "text"
            , placeholder "Search..."
            , id "elm-table-tailwind-search"
            , onInput
                (\s ->
                    onIn <|
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
                        (onEnter <|
                            \state ->
                                { state
                                    | search = state.search
                                    , page = iff (state.search /= "") 0 state.page
                                }
                        )
                        (onInternal <| \state -> state)
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


tableContent : Config a b msg -> Resolver msg -> State -> List (Row a) -> Html msg
tableContent ((Config cfg) as config) resolve state rows =
    let
        expandColumn =
            ifMaybe (cfg.table.expand /= Nothing) (expand (resolve Expand) (resolve Collapse) lensTable cfg.table.getID)

        subtableColumn =
            case cfg.subtable of
                Just (SubTable get _) ->
                    Just <|
                        subtable (get >> (\x -> List.isEmpty x && not (List.member ShowSubtable cfg.actions)))
                            (resolve ShowSubtable)
                            lensTable
                            cfg.table.getID

                _ ->
                    Nothing

        selectColumn =
            ifMaybe (cfg.selection /= Disable) (selectionParent (resolve SelectRow) config rows)

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
            iff (List.member SortColumn cfg.actions) rows (sort cfg.table.columns state.table rows)

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
            iff (List.member SearchEnter cfg.actions) srows (filter srows)

        -- cut the results for the pagination
        cut =
            \rs ->
                rs
                    |> Array.fromList
                    |> Array.slice (state.page * state.byPage) ((state.page + 1) * state.byPage)
                    |> Array.toList

        prows =
            iff ((not <| List.member ChangePage cfg.actions) && cfg.pagination /= None) (cut frows) frows
    in
    table [ class "table-auto w-full text-sm text-left text-gray-600" ]
        [ tableContentHead lensTable (cfg.selection /= Disable) resolve SortColumn SelectColumn columns state
        , tableContentBody config resolve columns state prows
        ]


tableContentHead :
    Lens State StateTable
    -> Bool
    -> Resolver msg
    -> Action
    -> Action
    -> List (Column a msg)
    -> State
    -> Html msg
tableContentHead lens hasSelection resolve actSelect actSort columns state =
    thead [ class "text-xs text-gray-700 uppercase bg-gray-50" ]
        [ tr [] <|
            List.indexedMap
                (\i ((Column c) as col) ->
                    th [ scope "col", class "px-4 py-3", style "width" c.width ] <|
                        viewHeader lens (resolve (iff (i == 0 && hasSelection) actSelect actSort)) col state
                )
                columns
        ]


tableContentBody : Config a b msg -> Resolver msg -> List (Column a msg) -> State -> List (Row a) -> Html msg
tableContentBody config resolve columns state rows =
    tbody [] <| List.concat (List.map (tableContentBodyRow config resolve columns state) rows)


tableContentBodyRow : Config a b msg -> Resolver msg -> List (Column a msg) -> State -> Row a -> List (Html msg)
tableContentBodyRow ((Config cfg) as config) resolve columns state (Row r) =
    [ tr [ class "bg-white border-b hover:bg-gray-50" ] <|
        List.map
            (\(Column c) ->
                td [ class <| "px-4 py-2 " ++ c.class, style "width" c.width ] <|
                    c.viewCell r state
            )
            columns
    , case ( cfg.table.expand, List.member (cfg.table.getID r) state.table.expanded ) of
        ( Just (Column c), True ) ->
            tr [ class "bg-white border-b hover:bg-gray-50" ]
                [ td [ class "px-4 py-2", colspan (List.length columns) ] <|
                    c.viewCell r state
                ]

        _ ->
            text ""
    , case ( cfg.subtable, List.member (cfg.table.getID r) state.table.subtable ) of
        ( Just (SubTable getValue conf), True ) ->
            tr []
                [ td [ class "px-4 py-2", colspan (List.length columns) ]
                    [ subtableContent config
                        resolve
                        (cfg.table.getID r)
                        conf
                        state
                        (getValue r)
                        (List.member (cfg.table.getID r) state.subtable.loading)
                    ]
                ]

        _ ->
            text ""
    ]


subtableContent :
    Config a b msg
    -> Resolver msg
    -> RowID
    -> ConfTable b msg
    -> State
    -> List b
    -> Bool
    -> Html msg
subtableContent ((Config cfg) as config) resolve parent subConfig state data isLoading =
    let
        expandColumn =
            ifMaybe (subConfig.expand /= Nothing) (expand (resolve Expand) (resolve Collapse) lensTable subConfig.getID)

        rows =
            sort subConfig.columns state.subtable <| List.map Row data

        selectColumn =
            ifMaybe (cfg.selection /= Disable) (selectionChild (resolve SelectColumn) config rows parent)

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
        [ if isLoading then
            div [ class "m-4 flex flex-col items-center" ] [ Spinner.view ]

          else
            table [ class "w-full text-sm text-left text-gray-500" ]
                [ tableContentHead lensSubTable (cfg.selection /= Disable) resolve SortSubColumn SelectSubColumn columns state
                , subtableContentBody subConfig columns state rows
                ]
        ]


subtableContentBody : ConfTable a msg -> List (Column a msg) -> State -> List (Row a) -> Html msg
subtableContentBody cfg columns state rows =
    tbody [] <| List.concat (List.map (subtableContentBodyRow cfg columns state) rows)


subtableContentBodyRow : ConfTable a msg -> List (Column a msg) -> State -> Row a -> List (Html msg)
subtableContentBodyRow cfg columns state (Row r) =
    [ tr [ class "hover:bg-slate-100" ] <|
        List.map
            (\(Column c) ->
                td [ class ("px-4 py-2 " ++ c.class), style "width" c.width ] <| c.viewCell r state
            )
            columns
    , case ( cfg.expand, List.member (cfg.getID r) state.subtable.expanded ) of
        ( Just (Column c), True ) ->
            tr [ class "hover:bg-slate-100" ]
                [ td [ class "px-4 py-2", colspan (List.length columns) ] <| c.viewCell r state
                ]

        _ ->
            text ""
    ]



--
-- Footer
--


tableFooter : Config a b msg -> Resolver msg -> State -> Int -> Html msg
tableFooter (Config cfg) resolve state total =
    case cfg.pagination of
        ByPage _ ->
            tableFooterPagination (resolve ChangePage) state.byPage state.page total

        Progressive { step } ->
            tableFooterProgressive (resolve ShowMore) state.progressive state.byPage step total

        None ->
            text ""



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
