module Route exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = Top


parse : Url -> Maybe Route
parse url =
    let
        parser =
            oneOf
                [ map Top top ]
    in
    Url.Parser.parse parser url
