module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Color.OneDark as OneDark
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Top
import Route exposing (Route)
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = NotFound
    | TopPage Page.Top.Model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "cappyzawa blog"
    , body =
        [ mainMsg model ]
    }


mainMsg : Model -> Html Msg
mainMsg model =
    Element.layout
        [ Background.color OneDark.black
        , Font.color OneDark.white
        , Font.regular
        , Font.size 24
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=Droid+Sans+Mono"
                , name = "Droid Sans Mono"
                }
            , Font.sansSerif
            ]
        ]
    <|
        case model.page of
            NotFound ->
                viewNotFound

            TopPage topPageModel ->
                Page.Top.view topPageModel
                    |> Element.map TopMsg


viewNotFound : Element Msg
viewNotFound =
    Element.link
        [ centerX
        , centerY
        , Font.size 60
        , Region.heading 1
        , Element.mouseOver
            [ Font.color OneDark.blue
            , Font.size 100
            ]
        ]
        { url = "/"
        , label = Element.text "404 NotFound"
        }



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    Model key (TopPage Page.Top.init)
        |> goTo (Route.parse url)



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | TopMsg Page.Top.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            goTo (Route.parse url) model

        TopMsg topMsg ->
            case model.page of
                TopPage topModel ->
                    let
                        ( newTopModel, topCmd ) =
                            Page.Top.update topMsg topModel
                    in
                    ( { model | page = TopPage newTopModel }
                    , Cmd.map TopMsg topCmd
                    )

                _ ->
                    ( model, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            ( { model | page = TopPage Page.Top.init }
            , Cmd.none
            )
