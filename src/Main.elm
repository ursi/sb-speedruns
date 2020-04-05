module Main exposing (..)

import Browser exposing (Document)
import Css as C exposing (Declaration)
import Css.Global as G
import Data
import Design as Ds
import Dict exposing (Dict)
import Html.Events as E
import Html.Styled as H exposing (Html)


todo =
    Debug.todo ""


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { bossOnly : Bool
    , zone : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model True "FF", Cmd.none )


type MenuOption
    = BossOnly Bool


normalZones : List String
normalZones =
    [ "FF", "FB", "FC", "VQ", "UB", "ST", "TL", "GY", "SC" ]


eliteZones : List String
eliteZones =
    [ "eFF", "eFB", "eFC", "eVQ", "eUB", "eST", "eTL", "eGY" ]



-- UPDATE


type Msg
    = ChangeBossOnly Bool
    | ChangeZone String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        ChangeBossOnly bool ->
            ( { model | bossOnly = bool }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = ""
    , body =
        [ H.divS
            [ C.display "grid"
            , C.rowGap "20px"
            , C.marginTop "1em"
            ]
            []
            [ H.divS
                [ gridStyles
                , C.gridTemplateColumns "repeat(2, max-content)"
                ]
                []
                [ H.divS [ menuDivStyles model.bossOnly ]
                    [ E.onClick <| ChangeBossOnly True ]
                    [ H.text "Boss Only" ]
                , H.divS [ menuDivStyles (not model.bossOnly) ]
                    [ E.onClick <| ChangeBossOnly False ]
                    [ H.text "Full Run" ]
                ]
            , H.divS
                [ gridStyles
                , C.grid "repeat(2, max-content) / repeat(9, max-content)"
                ]
                []
                [ zoneHtml 1 model.zone normalZones
                , zoneHtml 2 model.zone eliteZones
                ]
            ]
        , H.tableS
            [ C.marginTop "2em"
            , C.textAlign "center"
            , C.borderJ [ "1px", "solid", Ds.lightGray ]
            , C.borderSpacing "0 0"
            , C.borderRadius Ds.tableRadius
            , C.mapSelector (\c -> c ++ " tr") [ C.height "2em" ]
            ]
            []
            [ H.thead []
                [ H.tr []
                    [ H.thS [ C.paddingLeft "1em" ] [] [ H.text "Rank" ]
                    , H.thS [ C.width "20vw" ] [] [ H.text "Name" ]
                    , H.thS [ C.width "7em" ] [] [ H.text "Time" ]
                    ]
                ]
            , H.tbody []
                (Data.getPlayersWithRun model.bossOnly model.zone
                    |> List.indexedMap
                        (\i player ->
                            H.trS
                                [ C.nthChild 2 1 [ C.background Ds.lightGray ]
                                , C.lastChild
                                    [ C.mapSelector (\c -> c ++ " > :first-child")
                                        [ C.borderBottomLeftRadius Ds.tableRadius ]
                                    , C.mapSelector (\c -> c ++ " > :last-child")
                                        [ C.borderBottomRightRadius Ds.tableRadius ]
                                    ]
                                ]
                                []
                                [ H.td [] [ H.text <| String.fromInt <| i + 1 ]
                                , H.td [] [ H.text player ]
                                , H.td [] [ H.text <| Data.getTime model.bossOnly model.zone player ]
                                ]
                        )
                )
            ]
        ]
            |> H.withStyles
                [ G.body
                    [ C.margin "0"
                    , C.display "grid"
                    , C.justifyItems "center"
                    , C.font "1.5rem sans-serif"
                    ]
                , G.td [ C.padding "0" ]
                ]
    }


zoneHtml : Int -> String -> List String -> Html Msg
zoneHtml row selectedZone zones =
    H.divS [ C.display "contents" ]
        []
        (zones
            |> List.map
                (\zone ->
                    H.divS
                        [ menuDivStyles (zone == selectedZone)
                        , C.gridRow <| String.fromInt row
                        ]
                        [ E.onClick <| ChangeZone zone ]
                        [ H.text zone ]
                )
        )


menuDivStyles : Bool -> Declaration
menuDivStyles selected =
    C.batch
        [ C.batch <|
            if selected then
                [ C.color "white"
                , C.background "#5b9ad0"
                ]

            else
                [ C.color "inherit"
                , C.background Ds.lightGray
                , C.hover [ C.background "#ffc1c1" ]
                ]
        , C.padding "5px"
        , C.textAlign "center"
        , C.borderRadius ".2em"
        , C.cursor "pointer"
        , C.userSelect "none"
        ]


gridStyles : Declaration
gridStyles =
    C.batch
        [ C.display "grid"
        , C.gap "10px 10px"
        ]

