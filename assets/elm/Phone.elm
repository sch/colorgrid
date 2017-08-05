module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Phoenix.Socket as Socket exposing (Socket)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


endpoint : String
endpoint =
    "ws://localhost:4000/socket/websocket"



-- MODEL


type alias Model =
    { socket : Socket Msg
    , color : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Socket.init endpoint) "black", Cmd.none )



-- UPDATE


type Msg
    = ServerMessage (Socket.Msg Msg)
    | ChangeColor String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeColor newColor ->
            ( { model | color = newColor }, Cmd.none )

        ServerMessage msg ->
            let
                ( socket, command ) =
                    Socket.update msg model.socket
            in
                ( { model | socket = socket }, Cmd.map ServerMessage command )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Socket.listen model.socket ServerMessage



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
