module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Css as C exposing (Declaration)
import Css.Global as G
import Data exposing (Category(..))
import Design as Ds
import Dict exposing (Dict)
import FoldIdentity as F
import Html.Attributes as A
import Html.Events as E
import Html.Styled as H exposing (Html)
import Markdown
import Maybe.Extra as Maybe
import Url exposing (Url)
import Url.Builder as UB
import Url.Parser as UP exposing ((</>), (<?>))
import Url.Parser.Query as Q


todo =
    Debug.todo ""


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = UrlRequested
        , onUrlChange = \_ -> NoOp
        }



-- MODEL


type alias Model =
    { category : Category
    , zone : String
    , showingRules : Bool
    , key : Key
    }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( category, zone ) =
            case urlParser url of
                Just ( c, z ) ->
                    ( c, z )

                Nothing ->
                    Data.getMostPopular <| normalZones ++ eliteZones
    in
    ( Model category zone False key
    , Cmd.none
    )


urlParser : Url -> Maybe ( Category, String )
urlParser url =
    (UP.parse <|
        UP.query <|
            Q.map2
                (Maybe.andThen2 <|
                    \categoryStr zone ->
                        Data.categoryFromString categoryStr
                            |> Maybe.andThen
                                (\category ->
                                    if List.member zone (normalZones ++ eliteZones) then
                                        Just ( category, zone )

                                    else
                                        Nothing
                                )
                )
                (Q.string "category")
                (Q.string "zone")
    )
        { url | path = "" }
        |> Maybe.andThen identity


normalZones : List String
normalZones =
    [ "FF", "FB", "FC", "VQ", "UB", "ST", "TL", "GY", "SC" ]


eliteZones : List String
eliteZones =
    [ "eFF", "eFB", "eFC", "eVQ", "eUB", "eST", "eTL", "eGY" ]



-- UPDATE


type Msg
    = ChangeCategory Category
    | ChangeZone String
    | ChangeShowingRules Bool
    | UrlRequested UrlRequest
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeShowingRules bool ->
            ( { model | showingRules = bool }, Cmd.none )

        ChangeZone zone ->
            ( { model | zone = zone }
            , newUrl model.key model.category zone
            )

        ChangeCategory category ->
            ( { model | category = category }
            , newUrl model.key category model.zone
            )

        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal _ ->
                    ( model, Cmd.none )

                Browser.External url ->
                    ( model, Nav.load url )

        NoOp ->
            ( model, Cmd.none )


newUrl : Key -> Category -> String -> Cmd Msg
newUrl key category zone =
    Nav.pushUrl key <|
        UB.relative []
            [ UB.string "category" <| Data.categoryToString category
            , UB.string "zone" zone
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "StarBreak Speedruns"
    , body =
        [ H.divS
            [ C.position "absolute"
            , C.top "0"
            , C.right "0"
            , C.margin ".5em"
            , C.padding ".5em"
            , C.fontSize "1.2rem"
            , C.background Ds.gray1
            , C.borderRadius Ds.radius1
            ]
            [ E.onClick <| ChangeShowingRules True ]
            [ H.text "Rules" ]
        , rulesHtml model.showingRules
        , H.divS
            [ C.display "grid"
            , C.justifyItems "center"
            ]
            []
            [ H.divS
                [ C.display "grid"
                , C.justifyItems "center"
                , C.gridTemplateColumns "max-content"
                ]
                []
                [ menuHtml model
                , leaderboardHtml model
                ]
            ]
        ]
            |> H.withStyles
                [ G.body
                    [ C.margin "0"
                    , C.font "1.5rem sans-serif"
                    ]
                , G.td [ C.padding "0" ]
                ]
    }


leaderboardHtml : { r | category : Category, zone : String } -> Html Msg
leaderboardHtml { category, zone } =
    H.tableS
        [ C.width "100%"
        , C.textAlign "center"
        , C.borderJ [ "1px", "solid", Ds.gray1 ]
        , C.borderSpacing "0 0"
        , C.borderRadius Ds.radius1
        , C.mapSelector (\c -> c ++ " tr") [ C.height "2em" ]
        ]
        []
        [ H.thead []
            [ H.tr []
                [ H.th [] [ H.text "Rank" ]
                , H.th [] [ H.text "Name" ]
                , H.th [] [ H.text "Time" ]
                ]
            ]
        , H.tbody []
            (Data.getPlayersWithRun category zone
                |> List.indexedMap
                    (\i player ->
                        Data.getRun category zone player
                            |> F.map idH
                                (\run ->
                                    H.trS
                                        [ C.nthChild 2 1 [ C.children [ C.background Ds.gray1 ] ]
                                        , C.lastChild
                                            [ C.children
                                                [ C.firstChild [ C.borderBottomLeftRadius Ds.radius1 ]
                                                , C.lastChild [ C.borderBottomRightRadius Ds.radius1 ]
                                                ]
                                            ]
                                        ]
                                        []
                                        [ H.td [] [ H.text <| String.fromInt <| i + 1 ]
                                        , H.td []
                                            [ H.text player
                                            , H.imgS
                                                [ rightOfText ]
                                                [ A.src <| Data.shellToPicture run.shell ]
                                                []
                                            ]
                                        , H.td []
                                            [ H.text <| Data.formatTime run.time
                                            , H.a [ A.href <| run.link ]
                                                [ H.imgS
                                                    [ rightOfText ]
                                                    [ A.src "images/film.svg" ]
                                                    []
                                                ]
                                            ]
                                        ]
                                )
                    )
            )
        ]


menuHtml : { r | category : Category, zone : String } -> Html Msg
menuHtml { category, zone } =
    H.divS
        [ C.display "grid"
        , C.rowGap "20px"
        , C.marginTop "1em"
        ]
        []
        [ H.divS
            [ gridStyles
            , C.grid "max-content / auto-flow max-content"
            ]
            []
            [ H.divS [ menuDivStyles (category == FullRun) ]
                [ E.onClick <| ChangeCategory FullRun ]
                [ H.text "Full Run" ]
            , H.divS [ menuDivStyles (category == BossOnly) ]
                [ E.onClick <| ChangeCategory BossOnly ]
                [ H.text "Boss Only" ]
            , H.divS [ menuDivStyles (category == Stock) ]
                [ E.onClick <| ChangeCategory Stock ]
                [ H.text "Stock" ]
            ]
        , H.divS
            [ gridStyles
            , C.grid "repeat(2, max-content) / repeat(9, max-content)"
            , C.marginBottom "2em"
            ]
            []
            [ zoneHtml 1 zone normalZones
            , zoneHtml 2 zone eliteZones
            ]
        ]


rulesHtml : Bool -> Html Msg
rulesHtml =
    F.bool
        >> F.map idH
            (\_ ->
                H.divS
                    [ C.width "100%"
                    , C.height "100%"
                    , C.position "fixed"
                    , C.display "grid"
                    , C.justifyItems "center"
                    , C.alignItems "center"
                    , C.background "#0008"
                    , C.zIndex "1"
                    ]
                    [ E.onClick <| ChangeShowingRules False ]
                    [ H.divS
                        [ C.background "white"
                        , C.width "430px"
                        , C.fontSize "1rem"
                        , C.borderRadius "1em"
                        , C.padding "1em"
                        , C.maxHeight "100%"
                        , C.overflow "auto"
                        , C.child "div"
                            [ C.child "h1"
                                [ C.textAlign "center"
                                , C.fontSize "1.5rem"
                                ]
                            , C.child "ul" [ C.descendants [ C.marginTop ".6rem" ] ]
                            ]
                        ]
                        []
                        [ H.fromHtml <|
                            Markdown.toHtml []
                                """
# Qualifying

- The run must be a solo. You cannot receive help from any other players.
- All of the game mechanics involved in the run must be the same as the current version of the game.
- Video of the whole run is required. Someone else cannot record you, as it would be too easy to cheat.
- **Do not** edit the video in any way that effects the time, e.g., no changing the speed or cutting.
- Only one entry is allowed per player per category.

# Timing

- Time starts the moment your shell is visible after either entering the boss room or the beginning of the zone, depending on which category you are running.
- Time stops the moment the green text appears telling you the zone has been completed.

# Stock Category

- You must start the run with no gear in your inventory or equipped other than the stock gear.
- You must start the run with no boosts acquired. To ensure this, show your characters stats before the run, or show the shell being created.
- You are allowed to pick up any boosts during the run.
- You are **not** allowed to equip any gear you get in the run.
- Stock runs are the full level, not just the boss.
"""
                        ]
                    ]
            )


rightOfText : Declaration
rightOfText =
    C.batch
        [ C.height "1em"
        , C.transform "translateY(.14em)"
        , C.marginLeft ".3em"
        ]


idH : Html Msg
idH =
    H.text ""


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
                , C.background Ds.gray1
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
