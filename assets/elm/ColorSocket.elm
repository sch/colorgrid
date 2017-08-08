module ColorSocket exposing (State, Msg, init, changes, update)

{-| This module wraps a Phoenix channel, exposing only the methods needed to
send and receive changes in color.

@docs init, update, changes

-}

import Json.Encode as Json
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Push as Sender
import Phoenix.Channel as Channel


-- CONFIG


channelName =
    "broadcast"



-- MODEL


type alias State =
    { socket : Socket Msg
    , connectedUsers : Maybe Int
    }


init : String -> ( State, Cmd Msg )
init endpoint =
    let
        model =
            { socket = Socket.init endpoint
            , connectedUsers = Nothing
            }

        channel =
            Channel.init channelName

        ( socket, command ) =
            Socket.join channel model.socket

        connectCommand =
            Cmd.map (always Connect) command
    in
        ( { model | socket = socket }, connectCommand )



-- UPDATE


type Msg
    = ServerMessage (Socket.Msg Msg)
    | Connect


update : Msg -> State -> ( State, Cmd Msg )
update msg model =
    case msg of
        ServerMessage message ->
            let
                ( socket, command ) =
                    Socket.update message model.socket
            in
                ( { model | socket = socket }, Cmd.map ServerMessage command )

        Connect ->
            ( model, Cmd.none )



-- colorPayload : State -> Json.Value
-- colorPayload model =
--     Json.object [ ( "color", Json.string <| colorToCssHsl <| toColor model ) ]
-- SUBSCRIPTIONS


{-| Return the changes in color coming from the socket.
-}



-- changes : State -> (Socket msg -> msg) -> Sub msg


changes model tagger =
    Socket.listen model.socket ServerMessage
