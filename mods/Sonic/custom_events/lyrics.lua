function onCreatePost()
    makeLuaText('lyricsShadow', '', 1280, 0+3, 600+3)
	setProperty('lyricsShadow.borderSize', 0)
	setObjectCamera('lyricsShadow', 'other')
	setProperty('lyricsShadow.antialiasing', false)
	setTextFont('lyricsShadow', 'sonic2HUD.ttf')
	setTextSize('lyricsShadow', 6*8)
	setScrollFactor('lyricsShadow', 0, 0)
	setTextAlignment('lyricsShadow','center')
    setTextColor("lyricsShadow", "000000")
	addLuaText('lyricsShadow')

	makeLuaText('lyrics', '', 1280, 0, 600)
	setProperty('lyrics.borderSize', 0)
	setObjectCamera('lyrics', 'other')
	setProperty('lyrics.antialiasing', false)
	setTextFont('lyrics', 'sonic2HUD.ttf')
	setTextSize('lyrics', 6*8)
	setScrollFactor('lyrics', 0, 0)
	setTextAlignment('lyrics','center')
	addLuaText('lyrics')

    if downscroll then
        setProperty("lyrics.y", 90)
        setProperty("lyricsShadow.y", 90+3)
    end

    if songName == 'Trinity Legacy' or songName == 'Thriller Gen Legacy' then
        setProperty('lyrics.y', 450)
        setProperty('lyricsShadow.y', 450+3)
    end

    if songName == 'Trinity' then
        makeAnimatedLuaSprite("round2Lyrics", "round2Lyrics", 0, 0) -- lmao animated lyrics moment
        addAnimationByPrefix('round2Lyrics', 'THATS', '1thats', 1, false)
        addAnimationByPrefix('round2Lyrics', 'WHY', '2why', 1, false)
        addAnimationByPrefix('round2Lyrics', 'THIS', '3this', 1, false)
        addAnimationByPrefix('round2Lyrics', 'IS', '4is', 1, false)
        addAnimationByPrefix('round2Lyrics', 'ROUND', '5round', 1, false)
        addAnimationByPrefix('round2Lyrics', 'ROUND2', '6round2', 1, false)
        playAnim("round2Lyrics", "THATS", true, false, 0)
        setProperty('round2Lyrics.antialiasing', false)
        addLuaSprite('round2Lyrics', false)
        scaleObject("round2Lyrics", 3.0, 3.0)
        setObjectCamera("round2Lyrics", 'other')
        setProperty("round2Lyrics.visible", false)
    end
end

function onEvent(name, value1, value2)
    if name == 'lyrics' then
        setTextString("lyrics", string.upper(value1))
        setTextString("lyricsShadow", string.upper(value1))

        if songName == 'Trinity' then
            if value2 == '' then
                setProperty("round2Lyrics.visible", false)
            else
                setProperty("round2Lyrics.visible", true)
                playAnim("round2Lyrics", string.upper(value2), true, false, 0)
            end
        end

        if value1 == 's' then -- this only happens in trinity legacy at the end so haha big brain move to center the text :)
            setProperty('lyrics.y', 370)
            setProperty('lyricsShadow.y', 370+3)
        end
    end
end

function onStepHit()
    if curStep == 4432 then
        if songName == 'Trinity' and downscroll then
            setTextString("lyrics", "")
            setTextString("lyricsShadow", "")
        end
    end
end

function onEndSong()
    setTextString("lyrics", "")
    setTextString("lyricsShadow", "")
end