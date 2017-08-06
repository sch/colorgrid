module Main exposing (..)

import Color exposing (Color)
import Color.Convert exposing (colorToHex, colorToCssHsl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Json
import Mouse
import Task
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Push as Sender
import Phoenix.Channel as Channel
import Window


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


endpoint =
    "ws://evening-atoll-82768.herokuapp.com/socket/websocket"



-- MODEL


type alias Model =
    { socket : Socket Msg
    , window : Window.Size
    , hue : Float
    , saturation : Float
    , lightness : Float
    , affecting : YAxis
    , connectedUsers : Maybe Int
    }


type YAxis
    = Saturation
    | Lightness


init : ( Model, Cmd Msg )
init =
    let
        model =
            { socket = Socket.init endpoint
            , window = { width = 0, height = 0 }
            , hue = 0
            , saturation = 0.5
            , lightness = 0.5
            , affecting = Saturation
            , connectedUsers = Nothing
            }

        channel =
            Channel.init "broadcast"

        ( socket, command ) =
            Socket.join channel model.socket

        connectCommand =
            Cmd.map (always Connect) command

        getWindowSize =
            Task.perform Resize Window.size
    in
        ( { model | socket = socket }, Cmd.batch [ getWindowSize, connectCommand ] )


toColor : Model -> Color
toColor { hue, saturation, lightness } =
    Color.hsl hue saturation lightness



-- UPDATE


type Msg
    = Resize Window.Size
    | MouseMove Mouse.Position
    | ToggleBetweenSaturationAndLightness
    | ServerMessage (Socket.Msg Msg)
    | Connect


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            ( { model | window = size }, Cmd.none )

        MouseMove position ->
            let
                hue =
                    (toFloat position.x / toFloat model.window.width) * 2 * pi

                saturation =
                    if model.affecting == Saturation then
                        1 - (toFloat position.y / toFloat model.window.height)
                    else
                        model.saturation

                lightness =
                    if model.affecting == Lightness then
                        1 - (toFloat position.y / toFloat model.window.height)
                    else
                        model.lightness

                newModel =
                    { model
                        | hue = hue
                        , lightness = lightness
                        , saturation = saturation
                    }

                message =
                    Sender.init "color:new" "broadcast"
                        |> Sender.withPayload (colorPayload newModel)

                ( socket, command ) =
                    Socket.push message model.socket
            in
                ( { newModel | socket = socket }, Cmd.map ServerMessage command )

        ToggleBetweenSaturationAndLightness ->
            case model.affecting of
                Saturation ->
                    ( { model | affecting = Lightness }, Cmd.none )

                Lightness ->
                    ( { model | affecting = Saturation }, Cmd.none )

        ServerMessage message ->
            let
                ( socket, command ) =
                    Socket.update message model.socket
            in
                ( { model | socket = socket }, Cmd.map ServerMessage command )

        Connect ->
            ( model, Cmd.none )


colorPayload : Model -> Json.Value
colorPayload model =
    Json.object [ ( "color", Json.string <| colorToCssHsl <| toColor model ) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes Resize
        , Mouse.moves MouseMove
        , Mouse.clicks (always ToggleBetweenSaturationAndLightness)
        , Socket.listen model.socket ServerMessage
        ]



-- VIEW


systemFonts =
    String.join ", "
        [ "-apple-system"
        , "BlinkMacSystemFont"
        , quote "Segoe UI"
        , "Roboto"
        , "Helvetica"
        , "Arial"
        , "sans-serif"
        , quote "Apple Color Emoji"
        , quote "Segoe UI Emoji"
        , quote "Segoe UI Symbol"
        ]


systemMonospacedFonts =
    String.join ", "
        [ "SFMono-Regular"
        , quote "SF Mono"
        , quote "Monaco"
        , quote "Inconsolata"
        , quote "Fira Mono"
        , quote "Droid Sans Mono"
        , quote "Source Code Pro"
        , "monospace"
        ]


quote : String -> String
quote str =
    "\"" ++ str ++ "\""


view : Model -> Html Msg
view model =
    let
        styles = 
            [ ( "background-color", colorToHex <| toColor model )
            , ( "position", "absolute" )
            , ( "top", "0" )
            , ( "bottom", "0" )
            , ( "left", "0" )
            , ( "right", "0" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            , ( "font-family", systemFonts )
            ]
        children = case model.connectedUsers of
            Just count ->
                [ viewConnections count, viewHsl model ]
            Nothing ->
                [ viewHsl model ]
    in
    div [ style styles ] children


viewHsl : Model -> Html Msg
viewHsl model =
    div
        [ style
            [ ( "background-color", "rgba(255, 255, 255, 0.2)" )
            , ( "font-size", "200%" )
            , ( "color", "#333" )
            , ( "padding", "20px 30px" )
            , ( "border-radius", "3px" )
            ]
        ]
        [ text <| colorToCssHsl <| toColor model ]


viewConnections : Int -> Html Msg
viewConnections connectedUsers =
    let
        message =
            case connectedUsers of
                1 ->
                    "1 user is connected"

                _ ->
                    toString connectedUsers ++ " users are connected"
    in
        div
            [ style
                [ ( "background-color", "black" )
                , ( "color", "white" )
                , ( "font-family", systemMonospacedFonts )
                , ( "position", "absolute" )
                , ( "padding", "10px" )
                , ( "top", "0" )
                , ( "left", "0" )
                , ( "right", "0" )
                , ( "display", "flex" )
                ]
            ]
            [ text message ]
