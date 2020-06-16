module Data exposing
    ( Category
    , Run
    , Shell
    , Zone
    , categoryToString
    , getMostPopular
    , shellToString
    , zoneToString
    )

import Dict exposing (Dict)
import Dict.Any as DA
import Http as H
import Json.Decode as D exposing (Decoder)
import List.Extra as List


type alias Run =
    { player : String
    , category : Category
    , zone : Zone
    , shell : Shell
    , time : Int
    , link : String
    }


type Zone
    = FF
    | FB
    | FC
    | VQ
    | UB
    | ST
    | TL
    | GY
    | SC
    | EFF
    | EFB
    | EFC
    | EVQ
    | EUB
    | EST
    | ETL
    | EGY


type Shell
    = Wildfire
    | Duskwing
    | Fabricator
    | Ironclad


type Category
    = BossOnly
    | FullRun
    | Stock


zoneStrings : Dict String Zone
zoneStrings =
    Dict.fromList
        [ ( "FF", FF )
        , ( "FB", FB )
        , ( "FC", FC )
        , ( "VQ", VQ )
        , ( "UB", UB )
        , ( "ST", ST )
        , ( "TL", TL )
        , ( "GY", GY )
        , ( "SC", SC )
        , ( "eFF", EFF )
        , ( "eFB", EFB )
        , ( "eFC", EFC )
        , ( "eVQ", EVQ )
        , ( "eUB", EUB )
        , ( "eST", EST )
        , ( "eTL", ETL )
        , ( "eGY", EGY )
        ]


shellStrings : Dict String Shell
shellStrings =
    Dict.fromList
        [ ( "Wildfire", Wildfire )
        , ( "Duskwing", Duskwing )
        , ( "Fabricator", Fabricator )
        , ( "Ironclad", Ironclad )
        ]


categoryStrings : Dict String Category
categoryStrings =
    Dict.fromList
        [ ( "boss-only", BossOnly )
        , ( "full-run", FullRun )
        , ( "stock", Stock )
        ]


toString : Dict String a -> a -> String
toString dict a =
    dict
        |> Dict.toList
        |> List.find (Tuple.second >> (==) a)
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ""


fromString : Dict String a -> a -> String -> a
fromString dict default str =
    Dict.get str dict
        |> Maybe.withDefault default


categoryToString : Category -> String
categoryToString =
    toString categoryStrings


categoryFromString : String -> Category
categoryFromString =
    fromString categoryStrings BossOnly


zoneToString : Zone -> String
zoneToString =
    toString zoneStrings


zoneFromString : String -> Zone
zoneFromString =
    fromString zoneStrings FF


shellToString : Shell -> String
shellToString =
    toString shellStrings


shellFromString : String -> Shell
shellFromString =
    fromString shellStrings Wildfire


getData : (Result H.Error (List Run) -> msg) -> Cmd msg
getData toMsg =
    H.get
        { url = "http://localhost:5000"
        , expect = H.expectJson toMsg runsDecoder
        }


runsDecoder : Decoder (List Run)
runsDecoder =
    D.list <|
        D.map6 Run
            (D.field "player" D.string)
            (D.field "category" <| D.map categoryFromString D.string)
            (D.field "zone" <| D.map zoneFromString D.string)
            (D.field "shell" <| D.map shellFromString D.string)
            (D.field "time" D.int)
            (D.field "link" D.string)


getMostPopular : List Run -> ( Category, Zone )
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
                    ( ( run.category, run.zone )
                    , count
                    )

                else
                    acc
            )
            ( ( BossOnly, FF ), 0 )
        >> Tuple.first


to2Id : Run -> ( String, String )
to2Id run =
    ( categoryToString run.category, zoneToString run.zone )


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



-- getMostPopular : List String -> ( Category, String )
-- getMostPopular zones =
--     data
--         |> Dict.foldl
--             (\_ playerData accum ->
--                 let
--                     bossOnly =
--                         gmpGet BossOnly playerData
--                     fullRun =
--                         gmpGet FullRun playerData
--                     stock =
--                         gmpGet Stock playerData
--                 in
--                 gmpMerge stock accum
--                     |> gmpMerge fullRun
--                     |> gmpMerge bossOnly
--             )
--             A.empty
--         |> A.toList
--         |> List.sortBy Tuple.second
--         |> List.reverse
--         |> List.head
--         |> Maybe.map Tuple.first
--         |> Maybe.withDefault ( FullRun, "FF" )
-- gmpMerge : RunAccumulator -> RunAccumulator -> RunAccumulator
-- gmpMerge ra1 ra2 =
--     A.merge
--         (\k a result -> A.insert k a result)
--         (\k a b result -> A.insert k (a + b) result)
--         (\k b result -> A.insert k b result)
--         ra1
--         ra2
--         A.empty
-- gmpGet : Category -> PlayerData -> RunAccumulator
-- gmpGet category =
--     getRuns category
--         >> Dict.toList
--         >> List.map
--             (\( zone, _ ) ->
--                 ( ( category, zone ), 1 )
--             )
--         >> A.fromList
-- type alias RunAccumulator =
--     A.Dict ( Category, String ) Int
-- getPlayerData : String -> Maybe PlayerData
-- getPlayerData player =
--     Dict.get player data
-- getPlayersWithRun : Category -> String -> List String
-- getPlayersWithRun category zone =
--     data
--         |> Dict.foldl
--             (\player playerData runList ->
--                 playerData
--                     |> getRuns category
--                     |> Dict.member zone
--                     |> (\bool ->
--                             if bool then
--                                 player :: runList
--                             else
--                                 runList
--                        )
--             )
--             []
--         |> List.sortWith
--             (\p1 p2 ->
--                 Maybe.map2
--                     (\t1 t2 ->
--                         if t1 > t2 then
--                             GT
--                         else if t1 < t2 then
--                             LT
--                         else
--                             EQ
--                     )
--                     (getRawTime category zone p1)
--                     (getRawTime category zone p2)
--                     |> Maybe.withDefault EQ
--             )
-- getRawTime : Category -> String -> String -> Maybe Int
-- getRawTime category zone player =
--     data
--         |> Dict.get player
--         |> Maybe.map (getRuns category)
--         |> Maybe.andThen (Dict.get zone)
--         |> Maybe.map .time
-- formatTime : Int -> String
-- formatTime ms =
--     (if ms >= 60000 then
--         String.fromInt (ms // 60000) ++ ":"
--      else
--         ""
--     )
--         ++ (modBy 60000 ms
--                 // 1000
--                 |> String.fromInt
--                 |> String.padLeft 2 '0'
--            )
--         ++ "."
--         ++ (ms
--                 |> modBy 1000
--                 |> String.fromInt
--                 |> String.padLeft 3 '0'
--            )
-- getRun : Category -> String -> String -> Maybe Run
-- getRun category zone player =
--     data
--         |> Dict.get player
--         |> Maybe.map (getRuns category)
--         |> Maybe.andThen (Dict.get zone)
-- getRuns : Category -> PlayerData -> Dict String Run
-- getRuns category =
--     .runs
--         >> (case category of
--                 BossOnly ->
--                     .bossOnly
--                 FullRun ->
--                     .fullRun
--                 Stock ->
--                     .stock
--            )
-- shellToPicture : Shell -> String
-- shellToPicture shell =
--     "images/"
--         ++ (case shell of
--                 Wildfire ->
--                     "wildfire.png"
--                 Duskwing ->
--                     "duskwing.png"
--                 Ironclad ->
--                     "ironclad.png"
--                 Fabricator ->
--                     "fabricator.png"
--            )
