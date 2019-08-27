module Page.Top exposing (Model, Msg, init, update, view)

import Color.OneDark as OneDark
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- MODEL


type alias Model =
    {}


init : Model
init =
    {}



-- UPDATE


type Msg
    = Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Element Msg
view model =
    Element.column
        [ centerX
        , centerY
        ]
        [ iconLink, idText, navBar ]


idText : Element Msg
idText =
    Element.el
        [ centerX
        , padding 10
        ]
        (Element.text "@cappyzawa")


navBar : Element Msg
navBar =
    Element.row
        [ centerX ]
        [ twitterLink, githubLink, mediumLink ]



-- imageLinks


iconLink : Element Msg
iconLink =
    Element.link
        [ centerX, Element.clip, Border.rounded 30, Border.color OneDark.blue, Border.width 1 ]
        { url = "/"
        , label =
            Element.image
                []
                { src = "https://avatars3.githubusercontent.com/u/12455284?s=460&v=4"
                , description = "icon"
                }
        }


navImageLink : String -> String -> String -> Element Msg
navImageLink linkUrl imageUrl imageDesc =
    Element.link
        []
        { url = linkUrl
        , label =
            Element.image
                [ Element.paddingXY 8 0
                , Element.mouseOver
                    [ Border.glow OneDark.blue 3.0 ]
                , Border.rounded 15
                , clip
                ]
                { src = imageUrl
                , description = imageDesc
                }
        }


twitterLink : Element Msg
twitterLink =
    navImageLink "https://twitter.com/cappyzawa"
        "https://raw.githubusercontent.com/cappyzawa/me/master/assets/twitter-circle.png"
        "twitter"


githubLink : Element Msg
githubLink =
    navImageLink "https://github.com/cappyzawa"
        "https://raw.githubusercontent.com/cappyzawa/me/master/assets/github-circle.png"
        "github"


mediumLink : Element Msg
mediumLink =
    navImageLink "https://medium.com/@cappyzawa"
        "https://raw.githubusercontent.com/cappyzawa/me/master/assets/medium.png"
        "medium"
