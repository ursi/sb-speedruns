module Data exposing
    ( Category(..)
    , PlayerData
    , Run
    , formatTime
    , getMostPopular
    , getPlayerData
    , getPlayersWithRun
    , getRun
    , shellToPicture
    )

import AssocList as A exposing (Dict)
import Dict exposing (Dict)


type alias Data =
    Dict String PlayerData


type alias PlayerData =
    { runs :
        { bossOnly : Dict String Run
        , fullRun : Dict String Run
        , stock : Dict String Run
        }
    }


type alias Run =
    { shell : Shell
    , time : Int
    , link : String
    }


type Shell
    = Wildfire
    | Duskwing
    | Fabricator
    | Ironclad


type Category
    = BossOnly
    | FullRun
    | Stock


rawData =
    [ ( "BrazeTH"
      , { runs =
            { bossOnly =
                [ ( "eFB"
                  , { shell = Wildfire
                    , time = 160031
                    , link = "https://youtu.be/BhhSumqQ-y0?t=255"
                    }
                  )
                ]
            , fullRun =
                [ ( "eFB"
                  , { shell = Wildfire
                    , time = 389563
                    , link = "https://www.youtube.com/watch?v=BhhSumqQ-y0"
                    }
                  )
                ]
            , stock =
                [ ( "FF"
                  , { shell = Wildfire
                    , time = 432099
                    , link = "https://www.youtube.com/watch?v=dl6pvB-90O8"
                    }
                  )
                , ( "FB"
                  , { shell = Duskwing
                    , time = 427494
                    , link = "https://youtu.be/yh_KZUJ04AQ"
                    }
                  )
                ]
            }
        }
      )
    , ( "Deus"
      , { runs =
            { bossOnly = []
            , fullRun = []
            , stock =
                [ ( "FB"
                  , { shell = Duskwing
                    , time = 376233
                    , link = "https://www.youtube.com/watch?v=Nseq4diUMek"
                    }
                  )
                ]
            }
        }
      )
    , ( "Grand Sushi"
      , { runs =
            { bossOnly = []
            , fullRun = []
            , stock =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 266234
                    , link = "https://www.youtube.com/watch?v=FPqijZooOu8&"
                    }
                  )
                ]
            }
        }
      )
    , ( "Shade"
      , { runs =
            { bossOnly =
                [ ( "UB"
                  , { shell = Wildfire
                    , time = 264800
                    , link = "https://youtu.be/AcMofYmKzwU?t=199"
                    }
                  )
                ]
            , fullRun =
                [ ( "UB"
                  , { shell = Wildfire
                    , time = 448834
                    , link = "https://www.youtube.com/watch?v=AcMofYmKzwU"
                    }
                  )
                ]
            , stock = []
            }
        }
      )
    ]


data : Data
data =
    rawData
        |> List.map
            (\( name, { runs } ) ->
                ( name
                , { runs =
                        { bossOnly = Dict.fromList runs.bossOnly
                        , fullRun = Dict.fromList runs.fullRun
                        , stock = Dict.fromList runs.stock
                        }
                  }
                )
            )
        |> Dict.fromList


getPlayerData : String -> Maybe PlayerData
getPlayerData player =
    Dict.get player data


getPlayersWithRun : Category -> String -> List String
getPlayersWithRun category zone =
    data
        |> Dict.foldl
            (\player playerData runList ->
                playerData
                    |> getRuns category
                    |> Dict.member zone
                    |> (\bool ->
                            if bool then
                                player :: runList

                            else
                                runList
                       )
            )
            []
        |> List.sortWith
            (\p1 p2 ->
                Maybe.map2
                    (\t1 t2 ->
                        if t1 > t2 then
                            GT

                        else if t1 < t2 then
                            LT

                        else
                            EQ
                    )
                    (getRawTime category zone p1)
                    (getRawTime category zone p2)
                    |> Maybe.withDefault EQ
            )


getRawTime : Category -> String -> String -> Maybe Int
getRawTime category zone player =
    data
        |> Dict.get player
        |> Maybe.map (getRuns category)
        |> Maybe.andThen (Dict.get zone)
        |> Maybe.map .time


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


getRun : Category -> String -> String -> Maybe Run
getRun category zone player =
    data
        |> Dict.get player
        |> Maybe.map (getRuns category)
        |> Maybe.andThen (Dict.get zone)


getRuns : Category -> PlayerData -> Dict String Run
getRuns category =
    .runs
        >> (case category of
                BossOnly ->
                    .bossOnly

                FullRun ->
                    .fullRun

                Stock ->
                    .stock
           )


getMostPopular : List String -> ( Category, String )
getMostPopular zones =
    data
        |> Dict.foldl
            (\_ playerData accum ->
                let
                    bossOnly =
                        gmpGet BossOnly playerData

                    fullRun =
                        gmpGet FullRun playerData

                    stock =
                        gmpGet Stock playerData
                in
                gmpMerge bossOnly accum
                    |> gmpMerge fullRun
                    |> gmpMerge stock
            )
            A.empty
        |> A.toList
        |> List.sortBy Tuple.second
        |> List.reverse
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ( FullRun, "FF" )


gmpMerge : RunAccumulator -> RunAccumulator -> RunAccumulator
gmpMerge ra1 ra2 =
    A.merge
        (\k a result -> A.insert k a result)
        (\k a b result -> A.insert k (a + b) result)
        (\k b result -> A.insert k b result)
        ra1
        ra2
        A.empty


gmpGet : Category -> PlayerData -> RunAccumulator
gmpGet category =
    getRuns category
        >> Dict.toList
        >> List.map
            (\( zone, _ ) ->
                ( ( category, zone ), 1 )
            )
        >> A.fromList


type alias RunAccumulator =
    A.Dict ( Category, String ) Int


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
