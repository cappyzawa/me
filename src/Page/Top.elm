module Page.Top exposing (Model, Msg, init, update, view)

import Element exposing (..)
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
        [ Element.link
            []
            { url = "/"
            , label =
                Element.image
                    []
                    { src = "https://avatars3.githubusercontent.com/u/12455284?s=460&v=4"
                    , description = "icon"
                    }
            }
        ]
