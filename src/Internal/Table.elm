module Internal.Table exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Pagination as Pagination
import Internal.Selection exposing (..)
import Internal.State exposing (..)
import Internal.Tailwind.Table
import Internal.Toolbar
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)
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
    Internal.Tailwind.Table.frame <|
        header config resolver m.state
            :: (case m.rows of
                    Rows Loading ->
                        [ Internal.Tailwind.Table.loading ]

                    Rows (Loaded { total, rows }) ->
                        [ content config resolver m.state rows
                        , footer config resolver m.state total
                        ]

                    Rows (Failed msg) ->
                        [ Internal.Tailwind.Table.errorView msg ]
               )



--
-- Header
--


header : Config a b msg -> Resolver msg -> State -> Html msg
header ((Config cfg) as config) resolve state =
    Internal.Tailwind.Table.header
        { search = search (resolve EnterSearch) (resolve InputSearch) (resolve Neutral)
        , custom = cfg.toolbar
        , internal = Internal.Toolbar.view config resolve state
        }


search : Pipe msg -> Pipe msg -> Pipe msg -> List (Html msg)
search onEnter onIn onInternal =
    Internal.Tailwind.Table.search
        { input =
            \s ->
                onIn <|
                    \state ->
                        { state
                            | search = s
                            , btPagination = False
                            , btColumns = False
                            , btSubColumns = False
                        }
        , keyDown =
            \i ->
                iff (i == 13)
                    (onEnter <|
                        \state ->
                            { state
                                | search = state.search
                                , page = iff (state.search /= "") 0 state.page
                            }
                    )
                    (onInternal <| \state -> state)
        }



--
-- Content
--


content : Config a b msg -> Resolver msg -> State -> List (Row a) -> Html msg
content ((Config cfg) as config) resolve state rows =
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
    Internal.Tailwind.Table.content
        [ contentHead lensTable (cfg.selection /= Disable) resolve SortColumn SelectColumn columns state
        , contentBody config resolve columns state prows
        ]


contentHead :
    Lens State StateTable
    -> Bool
    -> Resolver msg
    -> Action
    -> Action
    -> List (Column a msg)
    -> State
    -> Html msg
contentHead lens hasSelection resolve actSelect actSort columns state =
    Internal.Tailwind.Table.head <|
        List.indexedMap
            (\i ((Column c) as col) ->
                Internal.Tailwind.Table.headItem c.width <|
                    viewHeader lens (resolve (iff (i == 0 && hasSelection) actSelect actSort)) col state
            )
            columns


contentBody : Config a b msg -> Resolver msg -> List (Column a msg) -> State -> List (Row a) -> Html msg
contentBody config resolve columns state rows =
    Internal.Tailwind.Table.body <| List.concat (List.map (contentBodyRow config resolve columns state) rows)


contentBodyRow : Config a b msg -> Resolver msg -> List (Column a msg) -> State -> Row a -> List (Html msg)
contentBodyRow ((Config cfg) as config) resolve columns state (Row r) =
    Internal.Tailwind.Table.bodyContent
        { cells = List.map (\(Column c) -> Internal.Tailwind.Table.cell c.class c.width (c.viewCell r state)) columns
        , expand =
            case ( cfg.table.expand, List.member (cfg.table.getID r) state.table.expanded ) of
                ( Just (Column c), True ) ->
                    Internal.Tailwind.Table.expandRow (List.length columns) (c.viewCell r state)

                _ ->
                    text ""
        , subtable =
            case ( cfg.subtable, List.member (cfg.table.getID r) state.table.subtable ) of
                ( Just (SubTable getValue conf), True ) ->
                    Internal.Tailwind.Table.subtableRow (List.length columns) <|
                        subtableContent config
                            resolve
                            (cfg.table.getID r)
                            conf
                            state
                            (getValue r)
                            (List.member (cfg.table.getID r) state.subtable.loading)

                _ ->
                    text ""
        }


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
    Internal.Tailwind.Table.subtable <|
        if isLoading then
            Internal.Tailwind.Table.subtableLoading

        else
            Internal.Tailwind.Table.subtableContent
                [ contentHead lensSubTable (cfg.selection /= Disable) resolve SortSubColumn SelectSubColumn columns state
                , subtableContentBody subConfig columns state rows
                ]


subtableContentBody : ConfTable a msg -> List (Column a msg) -> State -> List (Row a) -> Html msg
subtableContentBody cfg columns state rows =
    Internal.Tailwind.Table.body <| List.concat (List.map (subtableContentBodyRow cfg columns state) rows)


subtableContentBodyRow : ConfTable a msg -> List (Column a msg) -> State -> Row a -> List (Html msg)
subtableContentBodyRow cfg columns state (Row r) =
    Internal.Tailwind.Table.subtableBodyContent
        { cells = List.map (\(Column c) -> Internal.Tailwind.Table.cell c.class c.width (c.viewCell r state)) columns
        , expand =
            case ( cfg.expand, List.member (cfg.getID r) state.subtable.expanded ) of
                ( Just (Column c), True ) ->
                    Internal.Tailwind.Table.expandRow (List.length columns) (c.viewCell r state)

                _ ->
                    text ""
        }



--
-- Footer
--


footer : Config a b msg -> Resolver msg -> State -> Int -> Html msg
footer (Config cfg) resolve state total =
    case cfg.pagination of
        ByPage _ ->
            Pagination.pagination (resolve ChangePage) state.byPage state.page total

        Progressive { step } ->
            Pagination.progressive (resolve ShowMore) state.progressive state.byPage step total

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
