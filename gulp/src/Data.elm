module Data exposing
    ( Category(..)
    , PlayerData
    , Run
    , categoryFromString
    , categoryToString
    , formatTime
    , getMostPopular
    , getPlayerData
    , getPlayersWithRun
    , getRun
    , shellToPicture
    )

import AssocList as A exposing (Dict)
import Dict exposing (Dict)
import List.Extra as List


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
    , pure : Bool
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
    [ ( "Bebop"
      , { runs =
            { bossOnly =
                [ ( "eFC"
                  , { shell = Duskwing
                    , time = 99834
                    , link = "https://youtu.be/c_AaqgujqLw?t=69"
                    , pure = False
                    }
                  )
                ]
            , fullRun =
                [ ( "eFC"
                  , { shell = Duskwing
                    , time = 170700
                    , link = "https://www.youtube.com/watch?v=c_AaqgujqLw&t="
                    , pure = False
                    }
                  )
                ]
            , stock = []
            }
        }
      )
    , ( "BrazeTH"
      , { runs =
            { bossOnly =
                [ ( "VQ"
                  , { shell = Wildfire
                    , time = 237182
                    , link = "https://youtu.be/ipFSyujBl3Y?t=227"
                    , pure = True
                    }
                  )
                , ( "eFF"
                  , { shell = Wildfire
                    , time = 137771
                    , link = "https://youtu.be/tUADE3i27S0?t=201"
                    , pure = True
                    }
                  )
                , ( "eFB"
                  , { shell = Wildfire
                    , time = 160031
                    , link = "https://youtu.be/BhhSumqQ-y0?t=255"
                    , pure = True
                    }
                  )
                ]
            , fullRun =
                [ ( "VQ"
                  , { shell = Wildfire
                    , time = 440973
                    , link = "https://youtu.be/ipFSyujBl3Y"
                    , pure = True
                    }
                  )
                , ( "eFF"
                  , { shell = Wildfire
                    , time = 334067
                    , link = "https://www.youtube.com/watch?v=tUADE3i27S0"
                    , pure = True
                    }
                  )
                , ( "eFB"
                  , { shell = Wildfire
                    , time = 389563
                    , link = "https://www.youtube.com/watch?v=BhhSumqQ-y0"
                    , pure = True
                    }
                  )
                ]
            , stock =
                [ ( "FF"
                  , { shell = Wildfire
                    , time = 432099
                    , link = "https://www.youtube.com/watch?v=dl6pvB-90O8"
                    , pure = True
                    }
                  )
                , ( "FB"
                  , { shell = Duskwing
                    , time = 427494
                    , link = "https://youtu.be/yh_KZUJ04AQ"
                    , pure = True
                    }
                  )
                ]
            }
        }
      )
    , ( "Deus"
      , { runs =
            { bossOnly =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 91267
                    , link = "https://youtu.be/Tm1slZxFGPk?t=79"
                    , pure = False
                    }
                  )
                , ( "eFF"
                  , { shell = Duskwing
                    , time = 137300
                    , link = "https://youtu.be/J6H4C_1hKDU?t=80"
                    , pure = False
                    }
                  )
                ]
            , fullRun =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 165967
                    , link = "https://youtu.be/Tm1slZxFGPk"
                    , pure = False
                    }
                  )
                , ( "eFF"
                  , { shell = Duskwing
                    , time = 214550
                    , link = "https://youtu.be/J6H4C_1hKDU"
                    , pure = False
                    }
                  )
                ]
            , stock =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 236966
                    , link = "https://youtu.be/k16Oam2KLtg"
                    , pure = True
                    }
                  )
                , ( "FB"
                  , { shell = Duskwing
                    , time = 376233
                    , link = "https://www.youtube.com/watch?v=Nseq4diUMek"
                    , pure = True
                    }
                  )
                ]
            }
        }
      )
    , ( "Europe"
      , { runs =
            { bossOnly =
                [ ( "eFC"
                  , { shell = Wildfire
                    , time = 119215
                    , link = "https://youtu.be/di6WuDr_-G8?t=111"
                    , pure = True
                    }
                  )
                , ( "eTL"
                  , { shell = Wildfire
                    , time = 252000
                    , link = "https://www.youtube.com/watch?v=xKzqsdG699c"
                    , pure = False
                    }
                  )
                ]
            , fullRun =
                [ ( "eFC"
                  , { shell = Wildfire
                    , time = 229493
                    , link = "https://www.youtube.com/watch?v=di6WuDr_-G8"
                    , pure = True
                    }
                  )
                , ( "eTL"
                  , { shell = Wildfire
                    , time = 618233
                    , link = "https://www.youtube.com/watch?v=ThJKHsnqG9Q"
                    , pure = False
                    }
                  )
                ]
            , stock =
                []
            }
        }
      )
    , ( "Forcex26"
      , { runs =
            { bossOnly =
                [ ( "FF"
                  , { shell = Ironclad
                    , time = 95567
                    , link = "https://www.youtube.com/watch?v=lxHI3KEfw7Y"
                    , pure = False
                    }
                  )
                ]
            , fullRun = []
            , stock =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 343234
                    , link = "https://youtu.be/4ZWnzgtvXf4"
                    , pure = False
                    }
                  )
                ]
            }
        }
      )
    , ( "Givsaro"
      , { runs =
            { bossOnly =
                [ ( "FF"
                  , { shell = Wildfire
                    , time = 91567
                    , link = "https://youtu.be/UyDW8C8FSGo?t=123"
                    , pure = True
                    }
                  )
                , ( "VQ"
                  , { shell = Wildfire
                    , time = 213000
                    , link = "https://youtu.be/hP5wcq8uH2E?t=163"
                    , pure = True
                    }
                  )
                , ( "ST"
                  , { shell = Wildfire
                    , time = 220167
                    , link = "https://youtu.be/wDzyp_GOwjQ?t=113"
                    , pure = True
                    }
                  )
                , ( "TL"
                  , { shell = Wildfire
                    , time = 246400
                    , link = "https://www.youtube.com/watch?v=2EjFLAYUKwI"
                    , pure = True
                    }
                  )
                , ( "eFF"
                  , { shell = Wildfire
                    , time = 143033
                    , link = "https://youtu.be/jR_3z8vluDY?t=125"
                    , pure = True
                    }
                  )
                , ( "eFC"
                  , { shell = Ironclad
                    , time = 137334
                    , link = "https://youtu.be/9H4WZ136iRs?t=185"
                    , pure = True
                    }
                  )
                , ( "eVQ"
                  , { shell = Wildfire
                    , time = 250967
                    , link = "https://youtu.be/9GicHYnod-4?t=224"
                    , pure = True
                    }
                  )
                ]
            , fullRun =
                [ ( "FF"
                  , { shell = Wildfire
                    , time = 189533
                    , link = "https://www.youtube.com/watch?v=ixNi9a00Xso"
                    , pure = True
                    }
                  )
                , ( "VQ"
                  , { shell = Wildfire
                    , time = 373200
                    , link = "https://www.youtube.com/watch?v=hP5wcq8uH2E"
                    , pure = True
                    }
                  )
                , ( "ST"
                  , { shell = Wildfire
                    , time = 331867
                    , link = "https://www.youtube.com/watch?v=wDzyp_GOwjQ"
                    , pure = True
                    }
                  )
                , ( "TL"
                  , { shell = Wildfire
                    , time = 544934
                    , link = "https://www.youtube.com/watch?v=JQCpkdWYB3U"
                    , pure = True
                    }
                  )
                , ( "eFF"
                  , { shell = Wildfire
                    , time = 265000
                    , link = "https://www.youtube.com/watch?v=jR_3z8vluDY"
                    , pure = True
                    }
                  )
                , ( "eFC"
                  , { shell = Ironclad
                    , time = 318467
                    , link = "https://www.youtube.com/watch?v=9H4WZ136iRs"
                    , pure = True
                    }
                  )
                , ( "eVQ"
                  , { shell = Wildfire
                    , time = 473433
                    , link = "https://www.youtube.com/watch?v=9GicHYnod-4"
                    , pure = True
                    }
                  )
                ]
            , stock =
                []
            }
        }
      )
    , ( "grand_sushi"
      , { runs =
            { bossOnly = []
            , fullRun = []
            , stock =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 217467
                    , link = "https://www.youtube.com/watch?v=uQj-YLX-kr8"
                    , pure = True
                    }
                  )
                ]
            }
        }
      )
    , ( "Gritian"
      , { runs =
            { bossOnly =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 91500
                    , link = "https://youtu.be/_r_nvV22tek?t=82"
                    , pure = True
                    }
                  )
                , ( "FB"
                  , { shell = Duskwing
                    , time = 104367
                    , link = "https://youtu.be/2MREFUbcxy4?t=117"
                    , pure = True
                    }
                  )
                , ( "FC"
                  , { shell = Duskwing
                    , time = 93067
                    , link = "https://youtu.be/1eCVfwvvU0s?t=82"
                    , pure = True
                    }
                  )
                , ( "VQ"
                  , { shell = Duskwing
                    , time = 193400
                    , link = "https://youtu.be/0ueTAiUZ9Yo?t=120"
                    , pure = True
                    }
                  )
                ]
            , fullRun =
                [ ( "FF"
                  , { shell = Duskwing
                    , time = 168700
                    , link = "https://www.youtube.com/watch?v=_r_nvV22tek"
                    , pure = True
                    }
                  )
                , ( "FB"
                  , { shell = Duskwing
                    , time = 216367
                    , link = "https://www.youtube.com/watch?v=2MREFUbcxy4"
                    , pure = True
                    }
                  )
                , ( "FC"
                  , { shell = Duskwing
                    , time = 170866
                    , link = "https://www.youtube.com/watch?v=1eCVfwvvU0s"
                    , pure = True
                    }
                  )
                , ( "VQ"
                  , { shell = Duskwing
                    , time = 309800
                    , link = "https://www.youtube.com/watch?v=0ueTAiUZ9Yo"
                    , pure = True
                    }
                  )
                ]
            , stock =
                []
            }
        }
      )
    , ( "JonDaTurtle"
      , { runs =
            { bossOnly =
                [ ( "TL"
                  , { shell = Wildfire
                    , time = 248582
                    , link = "https://youtu.be/EtINKR79MEY?t=306"
                    , pure = False
                    }
                  )
                , ( "GY"
                  , { shell = Wildfire
                    , time = 135936
                    , link = "https://youtu.be/wnWWPvIkdO0?t=250"
                    , pure = False
                    }
                  )
                , ( "eFC"
                  , { shell = Wildfire
                    , time = 105138
                    , link = "https://youtu.be/j1ykRjXAb8w?t=147"
                    , pure = False
                    }
                  )
                , ( "eTL"
                  , { shell = Wildfire
                    , time = 248248
                    , link = "https://youtu.be/23rd_XlTDtQ?t=326"
                    , pure = False
                    }
                  )
                ]
            , fullRun =
                [ ( "TL"
                  , { shell = Duskwing
                    , time = 496630
                    , link = "https://www.youtube.com/watch?v=yI8T-3F0ldA"
                    , pure = False
                    }
                  )
                , ( "GY"
                  , { shell = Wildfire
                    , time = 375642
                    , link = "https://www.youtube.com/watch?v=wnWWPvIkdO0&"
                    , pure = False
                    }
                  )
                , ( "eFC"
                  , { shell = Wildfire
                    , time = 227527
                    , link = "https://www.youtube.com/watch?v=j1ykRjXAb8w"
                    , pure = False
                    }
                  )
                ]
            , stock = []
            }
        }
      )
    , ( "magma"
      , { runs =
            { bossOnly = []
            , fullRun =
                [ ( "eFF"
                  , { shell = Duskwing
                    , time = 223880
                    , link = "https://youtu.be/XNjF9E-M9dQ?t=792"
                    , pure = False
                    }
                  )
                , ( "eUB"
                  , { shell = Duskwing
                    , time = 639730
                    , link = "https://youtu.be/XNjF9E-M9dQ?t=74"
                    , pure = False
                    }
                  )
                ]
            , stock = []
            }
        }
      )
    , ( "OySs"
      , { runs =
            { bossOnly =
                [ ( "eTL"
                  , { shell = Duskwing
                    , time = 453767
                    , link = "https://youtu.be/oftjkcNXD2A?t=292"
                    , pure = False
                    }
                  )
                ]
            , fullRun = []
            , stock = []
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
                    , pure = True
                    }
                  )
                , ( "TL"
                  , { shell = Wildfire
                    , time = 253533
                    , link = "https://youtu.be/Lj0fTpY5f9A?t=338"
                    , pure = False
                    }
                  )
                , ( "eFF"
                  , { shell = Wildfire
                    , time = 138900
                    , link = "https://youtu.be/YbNVKPkExnA?t=114"
                    , pure = True
                    }
                  )
                ]
            , fullRun =
                [ ( "UB"
                  , { shell = Wildfire
                    , time = 448834
                    , link = "https://www.youtube.com/watch?v=AcMofYmKzwU"
                    , pure = True
                    }
                  )
                , ( "TL"
                  , { shell = Wildfire
                    , time = 590733
                    , link = "https://www.youtube.com/watch?v=Lj0fTpY5f9A"
                    , pure = False
                    }
                  )
                , ( "eFF"
                  , { shell = Wildfire
                    , time = 249633
                    , link = "https://www.youtube.com/watch?v=YbNVKPkExnA"
                    , pure = True
                    }
                  )
                ]
            , stock = []
            }
        }
      )
    , ( "Stormzy101"
      , { runs =
            { bossOnly =
                [ ( "eFC"
                  , { shell = Wildfire
                    , time = 97667
                    , link = "https://youtu.be/A5SKr1iSxYs?t=120"
                    , pure = True
                    }
                  )
                , ( "eTL"
                  , { shell = Wildfire
                    , time = 249467
                    , link = "https://www.youtube.com/watch?v=v0cJPBzI_7A"
                    , pure = False
                    }
                  )
                ]
            , fullRun =
                [ ( "eFC"
                  , { shell = Wildfire
                    , time = 211233
                    , link = "https://www.youtube.com/watch?v=A5SKr1iSxYs"
                    , pure = True
                    }
                  )
                , ( "eTL"
                  , { shell = Wildfire
                    , time = 558267
                    , link = "https://www.youtube.com/watch?v=uP_7ZX4wceg"
                    , pure = False
                    }
                  )
                ]
            , stock =
                []
            }
        }
      )
    , ( "Zakum"
      , { runs =
            { bossOnly =
                [ ( "eFF"
                  , { shell = Duskwing
                    , time = 136558
                    , link = "https://youtu.be/JXZczcEwBGk?t=87"
                    , pure = True
                    }
                  )
                , ( "eFC"
                  , { shell = Wildfire
                    , time = 132900
                    , link = "https://youtu.be/Pim1bRK9AJg?t=129"
                    , pure = True
                    }
                  )
                , ( "eUB"
                  , { shell = Wildfire
                    , time = 331607
                    , link = "https://youtu.be/IAbEwPzft1k?t=324"
                    , pure = True
                    }
                  )
                ]
            , fullRun =
                [ ( "eFF"
                  , { shell = Duskwing
                    , time = 219877
                    , link = "https://www.youtube.com/watch?v=JXZczcEwBGk"
                    , pure = True
                    }
                  )
                , ( "eFC"
                  , { shell = Wildfire
                    , time = 258400
                    , link = "https://www.youtube.com/watch?v=Pim1bRK9AJg"
                    , pure = True
                    }
                  )
                , ( "eUB"
                  , { shell = Wildfire
                    , time = 652824
                    , link = "https://www.youtube.com/watch?v=IAbEwPzft1k"
                    , pure = True
                    }
                  )
                ]
            , stock =
                []
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
                gmpMerge stock accum
                    |> gmpMerge fullRun
                    |> gmpMerge bossOnly
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


categoryStrings : Dict String Category
categoryStrings =
    Dict.fromList
        [ ( "boss-only", BossOnly )
        , ( "full-run", FullRun )
        , ( "stock", Stock )
        ]


categoryFromString : String -> Maybe Category
categoryFromString =
    Dict.get >> (|>) categoryStrings


categoryToString : Category -> String
categoryToString category =
    categoryStrings
        |> Dict.toList
        |> List.find (Tuple.second >> (==) category)
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ""
