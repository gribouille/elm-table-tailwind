module Internal.Toolbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)


view : Config a b msg -> Pipe msg -> Pipe msg -> State -> List (Html msg)
view (Config cfg) pipeExt pipeInt state =
    [ case cfg.pagination of
        ByPage { capabilities } ->
            toolbarMenuPagination pipeExt pipeInt state capabilities

        _ ->
            text ""
    , toolbarMenuColumns cfg.table.columns pipeInt state
    , case cfg.subtable of
        Just (SubTable _ conf) ->
            toolbarMenuSubColumns conf.columns pipeInt state

        Nothing ->
            text ""
    ]


toolbarMenuPagination : Pipe msg -> Pipe msg -> State -> List Int -> Html msg
toolbarMenuPagination pipeExt pipeInt state capabilities =
    toolbarMenuDropdown
        "gg-stories"
        "Pagination"
        (pipeInt <|
            \s ->
                { s
                    | btPagination = not s.btPagination
                    , btColumns = False
                    , btSubColumns = False
                }
        )
        state.btPagination
        (List.map
            (\i ->
                li
                    []
                    [ a
                        [ class "block py-2 px-4 hover:bg-gray-100 hover:cursor-pointer"
                        , onClick (pipeExt <| \s -> { s | byPage = i, page = iff (i /= s.byPage) 0 s.page })
                        ]
                        [ text (String.fromInt i)
                        , iff (i == state.byPage)
                            (span [ class "text-green-700 font-bold float-right" ] [ text "✓" ])
                            (text "")
                        ]
                    ]
            )
            capabilities
        )


toolbarMenuColumns : List (Column a msg) -> Pipe msg -> State -> Html msg
toolbarMenuColumns columns pipeInt state =
    toolbarMenuDropdown
        "gg-menu-grid-r"
        "Columns"
        (pipeInt <|
            \s ->
                { s
                    | btColumns = not s.btColumns
                    , btPagination = False
                    , btSubColumns = False
                }
        )
        state.btColumns
        (List.filterMap (dropdownItem pipeInt state lensTable) <|
            List.map (\(Column c) -> ( c.name, c.hiddable )) columns
        )


toolbarMenuSubColumns : List (Column a msg) -> Pipe msg -> State -> Html msg
toolbarMenuSubColumns columns pipeInt state =
    toolbarMenuDropdown
        "gg-layout-grid-small"
        "Columns of subtable"
        (pipeInt <|
            \s ->
                { s
                    | btSubColumns = not s.btSubColumns
                    , btColumns = False
                    , btPagination = False
                }
        )
        state.btSubColumns
        (List.filterMap (dropdownItem pipeInt state lensSubTable) <|
            List.map (\(Column c) -> ( c.name, c.hiddable )) columns
        )


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
        (Just
            (li []
                [ a
                    [ class "block py-2 px-4 hover:bg-gray-100 hover:cursor-pointer"
                    , onClick msg
                    ]
                    [ text name
                    , input
                        [ class "is-checkradio float-right"
                        , type_ "checkbox"
                        , checked chk
                        , onCheck (\_ -> msg)
                        ]
                        []
                    ]
                ]
            )
        )
        Nothing


toolbarMenuDropdown : String -> String -> msg -> Bool -> List (Html msg) -> Html msg
toolbarMenuDropdown btn tt msg active items =
    div [ class "relative", id "dropdown" ]
        [ button
            [ type_ "button"
            , onClick msg
            , attribute "tooltip" tt
            , attribute "data-tippy-content" tt
            , attribute "data-tippy-placement" "bottom"
            , class "text-gray-900 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 text-center inline-flex items-center h-[38px] w-[46px]"
            ]
            [ i [ class btn ] [] ]
        , div
            [ class <| "z-10 w-44 bg-white rounded divide-y divide-gray-100 shadow origin-top-right absolute right-0" ++ iff active "" " hidden"
            ]
            [ ul [ class "py-1 text-sm text-gray-700" ] items ]
        ]
