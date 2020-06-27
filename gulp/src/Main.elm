module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Css as C exposing (Declaration)
import Css.Global as G
import Data exposing (Category, Run, Shell(..), Type(..), Zone)
import Design as Ds
import Dict exposing (Dict)
import FoldIdentity as F
import Html.Attributes as A
import Html.Events as E
import Html.Styled as H exposing (Html)
import Http
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
    { category : Maybe Category
    , runs : List Run
    , showingRules : Bool
    , key : Key
    }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model
        (urlParser url)
        []
        False
        key
    , Data.getData DataReceived
    )


urlParser : Url -> Maybe Category
urlParser url =
    (UP.parse <|
        UP.query <|
            Q.map3
                (\mtypeStr mzoneStr mshellStr ->
                    Maybe.andThen2
                        (\typeStr zoneStr ->
                            Maybe.map2
                                (\type_ zone ->
                                    Category
                                        type_
                                        zone
                                        (Maybe.andThen Data.shellFromString mshellStr)
                                )
                                (Data.typeFromString typeStr)
                                (Data.zoneFromString zoneStr)
                        )
                        mtypeStr
                        mzoneStr
                )
                (Q.string "type")
                (Q.string "zone")
                (Q.string "shell")
    )
        { url | path = "" }
        |> Maybe.andThen identity



-- UPDATE


type Msg
    = ChangeType Type
    | ChangeZone Zone
    | ChangeShell (Maybe Shell)
    | ChangeShowingRules Bool
    | UrlRequested UrlRequest
    | DataReceived (Result Http.Error (List Run))
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataReceived result ->
            case result of
                Ok runs ->
                    ( { model
                        | category =
                            if model.category == Nothing then
                                Just <| Data.getMostPopular runs

                            else
                                model.category
                        , runs = runs
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        ChangeShowingRules bool ->
            ( { model | showingRules = bool }, Cmd.none )

        ChangeShell shell ->
            maybeUpdate
                (\category ->
                    let
                        newCategory =
                            { category | shell = shell }
                    in
                    ( { model | category = Just newCategory }
                    , newUrl model.key newCategory
                    )
                )
                .category
                model

        ChangeZone zone ->
            maybeUpdate
                (\category ->
                    let
                        newCategory =
                            { category | zone = zone }
                    in
                    ( { model | category = Just newCategory }
                    , newUrl model.key newCategory
                    )
                )
                .category
                model

        ChangeType type_ ->
            maybeUpdate
                (\category ->
                    let
                        newCategory =
                            { category | type_ = type_ }
                    in
                    ( { model | category = Just newCategory }
                    , newUrl model.key newCategory
                    )
                )
                .category
                model

        UrlRequested _ ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


maybeUpdate :
    (a -> ( Model, Cmd Msg ))
    -> (Model -> Maybe a)
    -> Model
    -> ( Model, Cmd Msg )
maybeUpdate f getter model =
    Maybe.map f (getter model)
        |> Maybe.withDefault ( model, Cmd.none )


newUrl : Key -> Category -> Cmd Msg
newUrl key category =
    Nav.pushUrl key <|
        UB.relative []
            ([ UB.string "type" <| Data.typeToString category.type_
             , UB.string "zone" <| Data.zoneToString category.zone
             ]
                ++ (case category.shell of
                        Just shell ->
                            [ UB.string "shell" <| Data.shellToString shell ]

                        Nothing ->
                            []
                   )
            )



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


leaderboardHtml : Model -> Html Msg
leaderboardHtml model =
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
            (case model.category of
                Just category ->
                    Data.getRuns category model.runs
                        |> List.indexedMap
                            (\i run ->
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
                                        [ H.text run.player
                                        , H.imgS
                                            [ rightOfText ]
                                            [ A.src <| Data.shellToPicture run.shell ]
                                            []
                                        ]
                                    , H.td []
                                        [ H.text <| Data.formatTime run.time
                                        , H.a
                                            [ A.href <| run.link
                                            , A.target "_blank"
                                            ]
                                            [ H.imgS
                                                [ rightOfText ]
                                                [ A.src "images/film.svg" ]
                                                []
                                            ]
                                        ]
                                    ]
                            )

                Nothing ->
                    []
            )
        ]


menuHtml : { r | category : Maybe Category } -> Html Msg
menuHtml { category } =
    H.divS
        [ C.display "grid"
        , C.rowGap "20px"
        , C.margin "1em 0 2em 0"
        ]
        []
        [ H.divS
            [ gridStyles
            , C.grid "max-content / auto-flow max-content"
            ]
            []
            [ H.divS [ menuDivStyles (typeEquals FullRun category) ]
                [ E.onClick <| ChangeType FullRun ]
                [ H.text "Full Run" ]
            , H.divS [ menuDivStyles (typeEquals BossOnly category) ]
                [ E.onClick <| ChangeType BossOnly ]
                [ H.text "Boss Only" ]
            , H.divS [ menuDivStyles (typeEquals Stock category) ]
                [ E.onClick <| ChangeType Stock ]
                [ H.text "Stock" ]
            ]
        , H.divS
            [ gridStyles
            , C.grid "repeat(2, max-content) / repeat(9, max-content)"
            ]
            []
            [ zoneHtml 1 category Data.normalZones
            , zoneHtml 2 category Data.eliteZones
            ]
        , H.divS
            [ gridStyles
            , C.grid "max-content / auto-flow max-content"
            ]
            []
            (H.divS [ menuDivStyles (shellEquals Nothing category) ]
                [ E.onClick <| ChangeShell Nothing ]
                [ H.text "All" ]
                :: ([ Wildfire, Duskwing, Ironclad, Fabricator ]
                        |> List.map
                            (\shell ->
                                H.divS [ menuDivStyles (shellEquals (Just shell) category) ]
                                    [ E.onClick <| ChangeShell <| Just shell ]
                                    [ H.text <| Data.shellToString shell ]
                            )
                   )
            )
        ]


typeEquals : Type -> Maybe Category -> Bool
typeEquals type_ =
    Maybe.map (.type_ >> (==) type_)
        >> Maybe.withDefault False


shellEquals : Maybe Shell -> Maybe Category -> Bool
shellEquals mshell =
    Maybe.map (.shell >> (==) mshell)
        >> Maybe.withDefault False


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


zoneHtml : Int -> Maybe Category -> List Zone -> Html Msg
zoneHtml row mcategory zones =
    H.divS [ C.display "contents" ]
        []
        (zones
            |> List.map
                (\zone ->
                    H.divS
                        [ menuDivStyles (zoneEquals zone mcategory)
                        , C.gridRow <| String.fromInt row
                        ]
                        [ E.onClick <| ChangeZone zone ]
                        [ H.text <| Data.zoneToString zone ]
                )
        )


zoneEquals : Zone -> Maybe Category -> Bool
zoneEquals zone =
    Maybe.map (.zone >> (==) zone)
        >> Maybe.withDefault False


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
