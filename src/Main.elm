module Main exposing (..)

import Browser
import Color.OneDark as OneDark
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)



--- DATA


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


type alias Model =
    {}


init : Model
init =
    {}


type Msg
    = None


update : Msg -> Model -> Model
update msg model =
    {}


view : Model -> Html Msg
view model =
    Element.layout
        layoutOption
    <|
        Element.row
            [ width fill
            , height fill
            ]
            [ project, viewer ]


darkBlack : Element.Color
darkBlack =
    rgb255 14 21 26


layoutOption : List (Attribute Msg)
layoutOption =
    [ Background.color darkBlack
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


project : Element Msg
project =
    Element.column
        [ width (fillPortion 20)
        , spacing 36
        , padding 10
        , Border.color (Element.rgb255 0 0 0)
        , explain Debug.todo
        ]
        [ projectHeader
        , el
            [ Font.size 14
            , centerX
            ]
            (Element.text "content")
        ]


projectHeader : Element Msg
projectHeader =
    el
        [ Font.size 16
        , Region.heading 1
        , height (px 35)
        , centerX
        ]
        (Element.text "Project")


viewerHeader : Element Msg
viewerHeader =
    el
        [ Font.size 16
        , Region.heading 1
        , height (px 35)
        ]
        (Element.text "CAPPYZAWA")


viewer : Element Msg
viewer =
    Element.column
        [ width (fillPortion 80)
        , spacing 36
        , padding 10
        , Background.color OneDark.black
        , explain Debug.todo
        ]
        [ viewerHeader
        , el
            [ Font.size 14
            ]
            (Element.text "content")
        ]
