module Main exposing (..)

import Color exposing (Color)
import Color.Convert exposing (colorToHex, colorToCssHsl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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


endpoint : String
endpoint =
    "ws://localhost:4000/ws"



-- MODEL


type alias Model =
    { window : Window.Size
    , hue : Float
    , saturation : Float
    , lightness : Float
    , affecting : YAxis
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
            }
    in
        ( model, Task.perform Resize Window.size )



-- UPDATE


type Msg
    = Resize Window.Size
    | MouseMove Mouse.Position
    | ToggleBetweenSaturationAndLightness


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            ( { model | window = size }, Cmd.none )

        MouseMove position ->
            let
                hue =
                    (toFloat position.x / toFloat model.window.width) * 2 * pi
            in
                case model.affecting of
                    Saturation ->
                        let
                            saturation =
                                1 - (toFloat position.y / toFloat model.window.height)
                        in
                            ( { model | hue = hue, saturation = saturation }, Cmd.none )

                    Lightness ->
                        let
                            lightness =
                                1 - (toFloat position.y / toFloat model.window.height)
                        in
                            ( { model | hue = hue, lightness = lightness }, Cmd.none )

        ToggleBetweenSaturationAndLightness ->
            case model.affecting of
                Saturation ->
                    ( { model | affecting = Lightness }, Cmd.none )

                Lightness ->
                    ( { model | affecting = Saturation }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes Resize
        , Mouse.moves MouseMove
        , Mouse.clicks (always ToggleBetweenSaturationAndLightness)
        ]



-- VIEW


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
            ]
        ]
        [ viewHsl model ]


viewHsl : Model -> Html Msg
viewHsl model =
    div
        [ style
            [ ( "background-color", "rgba(255, 255, 255, 0.1)" )
            , ( "color", "#333" )
            , ( "padding", "20px 30px" )
            , ( "border-radius", "3px" )
            ]
        ]
        [ text <| colorToCssHsl <| toColor model ]


toColor : Model -> Color
toColor { hue, saturation, lightness } =
    Color.hsl hue saturation lightness
