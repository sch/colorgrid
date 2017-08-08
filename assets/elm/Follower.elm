module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import ColorSocket


main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { socket : ColorSocket.State
    , color : String
    }


init : String -> ( Model, Cmd Msg )
init endpoint =
    let
        ( socket, command ) =
            ColorSocket.init endpoint
    in
        ( Model socket "black", Cmd.map SocketMessage command )



-- UPDATE


type Msg
    = SocketMessage (ColorSocket.Msg Msg)
    | ChangeColor String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeColor newColor ->
            ( { model | color = newColor }, Cmd.none )

        SocketMessage msg ->
            let
                ( socket, command ) =
                    ColorSocket.update msg model.socket
            in
                ( { model | socket = socket }, Cmd.map SocketMessage command )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    ColorSocket.changes model.socket ChangeColor



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
