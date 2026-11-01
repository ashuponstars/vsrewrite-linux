import flixel.text.FlxText;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;

var lyricsShadow:FlxText;
var lyrics:FlxText;
var lyricsFormat:FlxTextFormatMarkerPair;

using StringTools;

function onCreatePost()
{
    lyricsShadow = new FlxText(3, 603, 1280, "");
    lyricsShadow.color = 0xFF000000;

    lyrics = new FlxText(0, 600, 1280, "");
    
    for (i in [lyricsShadow, lyrics]) {
        i.borderSize = 0;
        i.cameras = [game.camOther];
        i.antialiasing = false;
        i.font = Paths.font("sonic2HUD.ttf");
        i.size = 48;
        i.scrollFactor.set(0, 0);
        i.alignment = "center";
        game.add(i);
    }

    lyricsFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF0000), "$");

    if (game.curSong == "Thriller Gen Legacy" || game.curSong == "Trinity Legacy") {
        lyrics.y = 450;
        lyricsShadow.y = 453;
    }

    return;
}

function onEvent(e, v1, v2, sT)
{
    if (e == "formatLyrics") {
        lyrics.applyMarkup(v1.toUpperCase(), [lyricsFormat]);
        lyricsShadow.text = StringTools.replace(v1.toUpperCase(), "$", "");

        if (v1 == "s") {
            lyrics.y = 370;
            lyricsShadow.y = 373;
        }
    }
}

function onEndSong() {
    for (i in [lyrics, lyricsShadow]) i.text = "";
    return;
}

function onDestroy() {}