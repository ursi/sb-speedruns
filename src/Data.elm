module Data exposing
    ( PlayerData
    , getPlayerData
    , getPlayersWithRun
    , getTime
    )

import Dict exposing (Dict)


type alias Data =
    Dict String PlayerData


type alias PlayerData =
    { runs :
        { bossOnly : Dict String Int
        , fullRun : Dict String Int
        }
    }


rawData =
    [ ( "test1"
      , { runs =
            { bossOnly =
                [ ( "FF", 75572 )
                , ( "FB", 149906 )
                ]
            , fullRun =
                [ ( "FF", 52555 )
                , ( "FB", 2531 )
                ]
            }
        }
      )
    , ( "test2"
      , { runs =
            { bossOnly =
                [ ( "FF", 35269 )
                , ( "FB", 26060 )
                ]
            , fullRun =
                [ ( "FF", 153438 )
                , ( "FB", 106035 )
                ]
            }
        }
      )
    , ( "test3"
      , { runs =
            { bossOnly =
                [ ( "FF", 49416 )
                , ( "FB", 176925 )
                ]
            , fullRun =
                [ ( "FF", 108910 )
                , ( "FB", 93904 )
                ]
            }
        }
      )
    , ( "test4"
      , { runs =
            { bossOnly =
                [ ( "FF", 90003 )
                , ( "FB", 131548 )
                ]
            , fullRun =
                [ ( "FF", 123525 )
                , ( "FB", 140485 )
                ]
            }
        }
      )
    , ( "test5"
      , { runs =
            { bossOnly =
                [ ( "FF", 154710 )
                , ( "FB", 51313 )
                ]
            , fullRun =
                [ ( "FF", 104847 )
                , ( "FB", 23973 )
                ]
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
                        }
                  }
                )
            )
        |> Dict.fromList


getPlayerData : String -> Maybe PlayerData
getPlayerData player =
    Dict.get player data


getPlayersWithRun : Bool -> String -> List String
getPlayersWithRun bossOnly zone =
    data
        |> Dict.foldl
            (\player playerData runList ->
                playerData
                    |> getRuns bossOnly
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
                    (getRawTime bossOnly zone p1)
                    (getRawTime bossOnly zone p2)
                    |> Maybe.withDefault EQ
            )


getRawTime : Bool -> String -> String -> Maybe Int
getRawTime bossOnly zone player =
    data
        |> Dict.get player
        |> Maybe.map (getRuns bossOnly)
        |> Maybe.andThen (Dict.get zone)


getTime : Bool -> String -> String -> String
getTime bossOnly zone player =
    getRawTime bossOnly zone player
        |> Maybe.map
            (\ms ->
                (if ms >= 60000 then
                    String.fromInt (ms // 60000) ++ ":"

                 else
                    ""
                )
                    ++ String.fromInt (modBy 60000 ms // 1000)
                    ++ "."
                    ++ String.fromInt (modBy 1000 ms)
            )
        |> Maybe.withDefault ""


getRuns : Bool -> PlayerData -> Dict String Int
getRuns bossOnly =
    .runs
        >> (if bossOnly then
                .bossOnly

            else
                .fullRun
           )
