module Main exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import OneDark exposing (..)



--- DATA


type alias Post =
    { title : String
    , link : String
    }


posts : List Post
posts =
    [ { title = "First"
      , link = "./first"
      }
    , { title = "Second"
      , link = "./second"
      }
    ]


main =
    Element.layout
        [ Background.color OneDark.black
        , Font.color OneDark.white
        , Font.regular
        , Font.size 32
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=Droid+Sans+Mono"
                , name = "Droid Sans Mono"
                }
            , Font.sansSerif
            ]
        ]
    <|
        Element.table
            [ Element.centerX
            , Element.centerY
            , Element.spacing 5
            , Element.padding 10
            ]
            { data = posts
            , columns =
                [ { header = Element.text "TITLE"
                  , width = px 200
                  , view =
                        \post ->
                            Element.text post.title
                  }
                ]
            }
