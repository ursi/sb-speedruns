module Data exposing
    ( Category
    , Run
    , Shell
    , Type(..)
    , Zone
    , eliteZoneStrings
    , eliteZones
    , formatTime
    , getData
    , getMostPopular
    , getRuns
    , normalZoneStrings
    , normalZones
    , shellToPicture
    , shellToString
    , typeFromString
    , typeToString
    , zoneFromString
    , zoneStrings
    , zoneToString
    )

import Dict exposing (Dict)
import Dict.Any as DA
import Http as H
import Json.Decode as D exposing (Decoder)
import List.Extra as List


type alias Run =
    { player : String
    , type_ : Type
    , zone : Zone
    , shell : Shell
    , time : Int
    , link : String
    }


type alias Category =
    { type_ : Type
    , zone : Zone
    , shell : Maybe Shell
    }


type Either a b
    = Left a
    | Right b


type BaseZone
    = FF
    | FB
    | FC
    | VQ
    | UB
    | ST
    | TL
    | GY


type SC
    = SC


type Zone
    = Normal (Either BaseZone SC)
    | Elite BaseZone


type Shell
    = Wildfire
    | Duskwing
    | Fabricator
    | Ironclad


type Type
    = BossOnly
    | FullRun
    | Stock


typeStrings : Dict String Type
typeStrings =
    Dict.fromList
        [ ( "boss-only", BossOnly )
        , ( "full-run", FullRun )
        , ( "stock", Stock )
        ]



-- This exists to preserve order


zoneDictList : List ( String, Zone )
zoneDictList =
    [ ( "FF", Normal (Left FF) )
    , ( "FB", Normal (Left FB) )
    , ( "FC", Normal (Left FC) )
    , ( "VQ", Normal (Left VQ) )
    , ( "UB", Normal (Left UB) )
    , ( "ST", Normal (Left ST) )
    , ( "TL", Normal (Left TL) )
    , ( "GY", Normal (Left GY) )
    , ( "SC", Normal (Right SC) )
    , ( "eFF", Elite FF )
    , ( "eFB", Elite FB )
    , ( "eFC", Elite FC )
    , ( "eVQ", Elite VQ )
    , ( "eUB", Elite UB )
    , ( "eST", Elite ST )
    , ( "eTL", Elite TL )
    , ( "eGY", Elite GY )
    ]


zoneDict : Dict String Zone
zoneDict =
    Dict.fromList zoneDictList


zoneStrings : List String
zoneStrings =
    List.map Tuple.first zoneDictList


normalZones : List Zone
normalZones =
    zoneDictList
        |> List.filterMap
            (\( _, zone ) ->
                case zone of
                    Normal _ ->
                        Just zone

                    _ ->
                        Nothing
            )


normalZoneStrings : List String
normalZoneStrings =
    List.map zoneToString normalZones


eliteZones : List Zone
eliteZones =
    zoneDictList
        |> List.filterMap
            (\( _, zone ) ->
                case zone of
                    Elite _ ->
                        Just zone

                    _ ->
                        Nothing
            )


eliteZoneStrings : List String
eliteZoneStrings =
    List.map zoneToString eliteZones


shellStrings : Dict String Shell
shellStrings =
    Dict.fromList
        [ ( "Wildfire", Wildfire )
        , ( "Duskwing", Duskwing )
        , ( "Fabricator", Fabricator )
        , ( "Ironclad", Ironclad )
        ]


toString : Dict String a -> a -> String
toString dict a =
    dict
        |> Dict.toList
        |> List.find (Tuple.second >> (==) a)
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ""


fromString : Dict String a -> String -> Maybe a
fromString dict str =
    Dict.get str dict


typeToString : Type -> String
typeToString =
    toString typeStrings


typeFromString : String -> Maybe Type
typeFromString =
    fromString typeStrings


zoneToString : Zone -> String
zoneToString =
    toString zoneDict


zoneFromString : String -> Maybe Zone
zoneFromString =
    fromString zoneDict


shellToString : Shell -> String
shellToString =
    toString shellStrings


shellFromString : String -> Maybe Shell
shellFromString =
    fromString shellStrings


getData : (Result H.Error (List Run) -> msg) -> Cmd msg
getData toMsg =
    H.get
        { url = "https://sbsrdb.herokuapp.com/"
        , expect = H.expectJson toMsg runsDecoder
        }


runsDecoder : Decoder (List Run)
runsDecoder =
    D.map (List.filterMap identity) <|
        D.list <|
            D.map6
                (\player type_ zone shell time link ->
                    Maybe.map3
                        (\t z s -> Run player t z s time link)
                        type_
                        zone
                        shell
                )
                (D.field "player" D.string)
                (D.field "type" <| D.map typeFromString D.string)
                (D.field "zone" <| D.map zoneFromString D.string)
                (D.field "shell" <| D.map shellFromString D.string)
                (D.field "time" D.int)
                (D.field "link" D.string)


getMostPopular : List Run -> Category
getMostPopular =
    onlyFastestShell
        >> List.foldl
            (\run acc ->
                if DA.member run acc then
                    DA.get run acc
                        |> Maybe.map
                            (\n ->
                                DA.insert run (n + 1) acc
                            )
                        |> Maybe.withDefault acc

                else
                    DA.insert run 1 acc
            )
            (DA.empty to2Id)
        >> DA.toList
        >> List.foldl
            (\( run, count ) acc ->
                let
                    ( current, currentCount ) =
                        acc
                in
                if count > currentCount then
                    ( Category run.type_ run.zone Nothing
                    , count
                    )

                else
                    acc
            )
            ( Category BossOnly (Normal (Left FF)) Nothing, 0 )
        >> Tuple.first


to2Id : Run -> ( String, String )
to2Id run =
    ( typeToString run.type_, zoneToString run.zone )


to3Id : Run -> ( String, ( String, String ) )
to3Id run =
    ( run.player, to2Id run )


onlyFastestShell : List Run -> List Run
onlyFastestShell =
    List.foldl
        (\run acc ->
            case DA.get run acc of
                Just { time } ->
                    if run.time < time then
                        DA.insert run run acc

                    else
                        acc

                Nothing ->
                    DA.insert run run acc
        )
        (DA.empty to3Id)
        >> DA.toList
        >> List.map Tuple.second


getRuns : Category -> List Run -> List Run
getRuns { type_, zone, shell } =
    (if shell == Nothing then
        onlyFastestShell

     else
        identity
    )
        >> List.filter
            (\run ->
                run.type_
                    == type_
                    && (run.zone == zone)
                    && (if shell == Nothing then
                            True

                        else
                            shell == Just run.shell
                       )
            )
        >> List.sortBy .time


formatTime : Int -> String
formatTime ms =
    (if ms >= 60000 then
        String.fromInt (ms // 60000) ++ ":"

     else
        ""
    )
        ++ (modBy 60000 ms
                // 1000
                |> String.fromInt
                |> String.padLeft 2 '0'
           )
        ++ "."
        ++ (ms
                |> modBy 1000
                |> String.fromInt
                |> String.padLeft 3 '0'
           )


shellToPicture : Shell -> String
shellToPicture shell =
    "images/"
        ++ (case shell of
                Wildfire ->
                    "wildfire.png"

                Duskwing ->
                    "duskwing.png"

                Ironclad ->
                    "ironclad.png"

                Fabricator ->
                    "fabricator.png"
           )
