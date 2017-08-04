module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import WebSocket


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


echoServer : String
echoServer =
    "ws://localhost:4000/ws"



-- MODEL


type alias Model =
    { color : String }


init : ( Model, Cmd Msg )
init =
    ( Model "pink", Cmd.none )



-- UPDATE


type Msg
    = ChangeColor String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeColor newColor ->
            ( { model | color = newColor }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen echoServer ChangeColor



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "background-color", model.color )
            , ( "position", "fixed" )
            , ( "top", "0" )
            , ( "bottom", "0" )
            , ( "left", "0" )
            , ( "right", "0" )
            ]
        ]
        []
