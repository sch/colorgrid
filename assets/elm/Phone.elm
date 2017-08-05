module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


endpoint : String
endpoint =
    "ws://evening-atoll-82768.herokuapp.com/socket/websocket"



-- MODEL


type alias Model =
    { socket : Socket Msg
    , color : String
    }


init : ( Model, Cmd Msg )
init =
    let
        socket =
            Socket.init endpoint
                |> Socket.withDebug
                |> Socket.on "color" "broadcast" ColorMessage

        model =
            Model socket "black"

        ( socket_, command ) =
            Socket.join (Channel.init "broadcast") model.socket
    in
        ( { model | socket = socket_ }, Cmd.map (always Subscribe) command )



-- UPDATE


type Msg
    = ServerMessage (Socket.Msg Msg)
    | ChangeColor String
    | Subscribe
    | ColorMessage Json.Value


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

        Subscribe ->
            ( model, Cmd.none )

        ColorMessage message ->
            let
                color =
                    Json.decodeValue (Json.field "color" Json.string) message
                    |> Result.withDefault model.color
            in
                ( { model | color = color }, Cmd.none )



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
