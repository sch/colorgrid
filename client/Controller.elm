module Main exposing (..)

import Color exposing (Color)
import Color.Convert exposing (colorToHex, colorToCssHsl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Mouse
import Task
import WebSocket
import Window


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


endpoint =
    "ws://localhost:4000/ws"



-- MODEL


type alias Model =
    { window : Window.Size
    , hue : Float
    , saturation : Float
    , lightness : Float
    , affecting : YAxis
    , connectedUsers : Int
    , lastResponse : String
    }


type YAxis
    = Saturation
    | Lightness


init : ( Model, Cmd Msg )
init =
    let
        model =
            { window = { width = 0, height = 0 }
            , hue = 0
            , saturation = 0.5
            , lightness = 0.5
            , affecting = Saturation
            , connectedUsers = 0
            , lastResponse = ""
            }
    in
        ( model, Task.perform Resize Window.size )


toColor : Model -> Color
toColor { hue, saturation, lightness } =
    Color.hsl hue saturation lightness



-- UPDATE


type Msg
    = Resize Window.Size
    | MouseMove Mouse.Position
    | ToggleBetweenSaturationAndLightness
    | ServerMessage String


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

                command =
                    WebSocket.send endpoint (colorMessage newModel)
            in
                ( newModel, command )

        ToggleBetweenSaturationAndLightness ->
            case model.affecting of
                Saturation ->
                    ( { model | affecting = Lightness }, Cmd.none )

                Lightness ->
                    ( { model | affecting = Saturation }, Cmd.none )

        ServerMessage string ->
            ( { model | lastResponse = string }, Cmd.none )


colorMessage model =
    "color:" ++ (colorToCssHsl <| toColor model)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes Resize
        , Mouse.moves MouseMove
        , Mouse.clicks (always ToggleBetweenSaturationAndLightness)
        , WebSocket.listen endpoint ServerMessage
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
    div
        [ style
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
        ]
        [ viewConnections model, viewHsl model ]


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


viewConnections : Model -> Html Msg
viewConnections { connectedUsers, lastResponse } =
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
            [ span [ style [ ( "flex", "1" ) ] ] [ text message ]
            , text lastResponse
            ]
