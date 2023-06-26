module Internal.Toolbar exposing (view)

import Html exposing (..)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Icon.Grid as Grid
import Internal.Icon.GridSmall as GridSmall
import Internal.Icon.Layout as Layout
import Internal.State exposing (..)
import Internal.Tailwind.Toolbar
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)
import Table.Types exposing (Action(..))


view : Config a b msg -> Resolver msg -> State -> List (Html msg)
view (Config cfg) resolve state =
    [ case cfg.pagination of
        ByPage { capabilities } ->
            toolbarMenuPagination (resolve OpenMenuPagination) (resolve ChangeByPage) state capabilities

        _ ->
            text ""
    , toolbarMenuColumns cfg.table.columns (resolve OpenMenuColumns) (resolve ChangeColumnVisibility) state
    , case cfg.subtable of
        Just (SubTable _ conf) ->
            toolbarMenuSubColumns conf.columns (resolve OpenMenuSubColumns) (resolve ChangeSubColumnVisibility) state

        Nothing ->
            text ""
    ]


toolbarMenuPagination : Pipe msg -> Pipe msg -> State -> List Int -> Html msg
toolbarMenuPagination onOpenMenuPagination onChangeByPage state capabilities =
    Internal.Tailwind.Toolbar.dropdown
        { btn = Layout.view
        , tooltip = "Pagination"
        , click =
            onOpenMenuPagination <|
                \s ->
                    { s
                        | btPagination = not s.btPagination
                        , btColumns = False
                        , btSubColumns = False
                    }
        , isActive = state.btPagination
        , items =
            List.map
                (\i ->
                    Internal.Tailwind.Toolbar.paginationMenuItem (i == state.byPage)
                        (onChangeByPage <| \s -> { s | byPage = i, page = iff (i /= s.byPage) 0 s.page })
                        i
                )
                capabilities
        }


toolbarMenuColumns : List (Column a msg) -> Pipe msg -> Pipe msg -> State -> Html msg
toolbarMenuColumns columns onOpenMenuColumns onChangeColumnVisibility state =
    Internal.Tailwind.Toolbar.dropdown
        { btn = Grid.view
        , tooltip = "Columns"
        , click =
            onOpenMenuColumns <|
                \s ->
                    { s
                        | btColumns = not s.btColumns
                        , btPagination = False
                        , btSubColumns = False
                    }
        , isActive = state.btColumns
        , items =
            List.filterMap (dropdownItem onChangeColumnVisibility state lensTable) <|
                List.map (\(Column c) -> ( c.name, c.hiddable )) columns
        }


toolbarMenuSubColumns : List (Column a msg) -> Pipe msg -> Pipe msg -> State -> Html msg
toolbarMenuSubColumns columns onOpenMenuSubColumns onChangeSubColumnVisibility state =
    Internal.Tailwind.Toolbar.dropdown
        { btn = GridSmall.view
        , tooltip = "Columns of subtable"
        , click =
            onOpenMenuSubColumns <|
                \s ->
                    { s
                        | btSubColumns = not s.btSubColumns
                        , btColumns = False
                        , btPagination = False
                    }
        , isActive = state.btSubColumns
        , items =
            List.filterMap (dropdownItem onChangeSubColumnVisibility state lensSubTable) <|
                List.map (\(Column c) -> ( c.name, c.hiddable )) columns
        }


dropdownItem : Pipe msg -> State -> Lens State StateTable -> ( String, Bool ) -> Maybe (Html msg)
dropdownItem pipeInt state lens ( name, hiddable ) =
    let
        stateTable =
            lens.get state

        chk =
            List.any ((==) name) stateTable.visible

        visible =
            iff chk
                (List.filter ((/=) name) stateTable.visible)
                (name :: stateTable.visible)

        msg =
            pipeInt <| \s -> lens.set { stateTable | visible = visible } s
    in
    iff hiddable
        (Just <| Internal.Tailwind.Toolbar.dropdownItem name msg (\_ -> msg) chk)
        Nothing
