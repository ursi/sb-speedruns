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
            , C.background Ds.lightGray
            , C.borderRadius Ds.radius1
            ]
            [ E.onClick <| ChangeShowingRules True ]
            [ H.text "Rules" ]
        , F.bool model.showingRules
            |> F.map idH
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
                            , C.child "h1"
                                [ C.textAlign "center"
                                , C.fontSize "1.5rem"
                                ]
                            , C.child "ul" [ C.descendants [ C.marginTop ".6rem" ] ]
                            ]
                            []
                            [ H.h1 [] [ H.text "Qualifying" ]
                            , H.ul []
                                [ H.li [] [ H.text "The run must be a solo. You cannot receive help from any other players." ]
                                , H.li []
                                    [ H.text "The only allowed mod is a zoom mod, however, you are not allowed to change your zoom level using that mod during your run. "
                                    , H.b [] [ H.text "All other mods are not allowed." ]
                                    , H.text " A static zoom mod is allowed so that players with bigger monitors don't have an advantage."
                                    ]
                                , H.li [] [ H.text "Macros and other scripts are not allowed." ]
                                , H.li [] [ H.text "All of the game mechanics involved in the run must be the same as the current version of the game." ]
                                , H.li [] [ H.text "Video of the whole run is required. Someone else cannot record you, as it would be too easy to cheat." ]
                                , H.li []
                                    [ H.b [] [ H.text "Do not" ]
                                    , H.text " edit any part of the video that will be part of the run. Before and after is okay."
                                    ]
                                , H.li [] [ H.text "Only one entry is allowed per player per category." ]
                                ]
                            , H.h1 [] [ H.text "Timing" ]
                            , H.ul []
                                [ H.li [] [ H.text "Time starts the moment your shell is visible after either entering the boss room or the beginning of the zone, depending on which category you are running." ]
                                , H.li []
                                    [ H.text "Time ends the moment the"
                                    , H.ul []
                                        [ H.li []
                                            [ H.b [] [ H.text "FF/FB:" ]
                                            , H.text " \"Mission Complete\" text is visible."
                                            ]
                                        , H.li []
                                            [ H.b [] [ H.text "Everything Else:" ]
                                            , H.text " the callout is visible."
                                            ]
                                        ]
                                    ]
                                ]
                            , H.h1 [] [ H.text "Stock Category" ]
                            , H.ul []
                                [ H.li [] [ H.text "You must start the run with no gear in your inventory or equipped other than the stock gear." ]
                                , H.li [] [ H.text "You must start the run with no boosts acquired. To ensure this, show your characters stats before the run, or show the shell being created." ]
                                , H.li [] [ H.text "You are allowed to pick up any boosts during the run." ]
                                , H.li []
                                    [ H.text "You are "
                                    , H.b [] [ H.text "not" ]
                                    , H.text " allowed to equip any gear you get in the run."
                                    ]
                                , H.li [] [ H.text "Stock runs are the full level, not just the boss." ]
                                ]
                            ]
                        ]
                )
        , H.divS
            [ C.display "grid"
            , C.justifyItems "center"
            ]
            []
            [ H.divS
                [ C.display "grid"
                , C.rowGap "20px"
                , C.marginTop "1em"
                ]
                []
                [ H.divS
                    [ gridStyles
                    , C.gridTemplateColumns "repeat(3, max-content)"
                    ]
                    []
                    [ H.divS [ menuDivStyles (model.category == BossOnly) ]
                        [ E.onClick <| ChangeCategory BossOnly ]
                        [ H.text "Boss Only" ]
                    , H.divS [ menuDivStyles (model.category == FullRun) ]
                        [ E.onClick <| ChangeCategory FullRun ]
                        [ H.text "Full Run" ]
                    , H.divS [ menuDivStyles (model.category == Stock) ]
                        [ E.onClick <| ChangeCategory Stock ]
                        [ H.text "Stock" ]
                    ]
                , H.divS
                    [ gridStyles
                    , C.grid "repeat(2, max-content) / repeat(9, max-content)"
                    , C.marginBottom "2em"
                    ]
                    []
                    [ zoneHtml 1 model.zone normalZones
                    , zoneHtml 2 model.zone eliteZones
                    ]
                ]
            , H.tableS
                [ C.textAlign "center"
                , C.borderJ [ "1px", "solid", Ds.lightGray ]
                , C.borderSpacing "0 0"
                , C.borderRadius Ds.radius1
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
                    (Data.getPlayersWithRun model.category model.zone
                        |> List.indexedMap
                            (\i player ->
                                Data.getRun model.category model.zone player
                                    |> F.map idH
                                        (\run ->
                                            H.trS
                                                [ C.nthChild 2 1 [ C.children [ C.background Ds.lightGray ] ]
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
