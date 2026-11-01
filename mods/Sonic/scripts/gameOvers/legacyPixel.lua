-- CUZ IM FUCKING LAZY TO DO THIS IN THE ACTUAL SCRIPT FUCK YOUUUUU

function onGameOverStart()
    setPropertyFromClass('openfl.Lib', 'application.window.title', "ILLEGAL INSTRUCTION")
    callMethod('camOther.fade', {0x270727, 0.0001, true})

    makeLuaSprite("pixelBGGameOver", "gameOver/legacy/legacyPixelGameOverBG", 115, -30)
	setProperty('pixelBGGameOver.antialiasing', false)
	setProperty('pixelBGGameOver.alpha', 1)
    setObjectCamera('pixelBGGameOver', 'other')
	setScrollFactor('pixelBGGameOver', 0, 0)
	addLuaSprite('pixelBGGameOver', false)
	scaleObject("pixelBGGameOver", 4, 4)

    makeLuaSprite("pixelSonicGameOver", "gameOver/legacy/legacyPixelGameOverSonic", 115, -30)
	setProperty('pixelSonicGameOver.antialiasing', false)
	setProperty('pixelSonicGameOver.alpha', 1)
    setObjectCamera('pixelSonicGameOver', 'other')
	setScrollFactor('pixelSonicGameOver', 0, 0)
	addLuaSprite('pixelSonicGameOver', false)
	scaleObject("pixelSonicGameOver", 4, 4)

    makeLuaSprite("ILLEGALINSTRUCTION", "gameOver/legacy/legacyPixelGameOverILLEGAL", 250, 50)
	setProperty('ILLEGALINSTRUCTION.antialiasing', false)
	setProperty('ILLEGALINSTRUCTION.alpha', 1)
    setObjectCamera('ILLEGALINSTRUCTION', 'other')
	setScrollFactor('ILLEGALINSTRUCTION', 0, 0)
	addLuaSprite('ILLEGALINSTRUCTION', false)
	scaleObject("ILLEGALINSTRUCTION", 3, 3)
    if flashingLights then
        runTimer('IIFLASH', 0.05, 999)
    end
    playSound('illegalInstruction', 0.5, 'illegalInstruction')
end

function onGameOverConfirm(retry)
    stopSound('illegalInstruction')
    if retry then
        cameraFade("camOther", "270727", 0.0001, true)
        runTimer('restartSong', 0.5)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'IIFLASH' then
        if loopsLeft % 2 == 0 then
            setProperty("ILLEGALINSTRUCTION.visible", false)
        else
            setProperty("ILLEGALINSTRUCTION.visible", true)
        end

        if loopsLeft == 1 then
            runTimer('IIFLASH', 0.05, 998)
        end
    end

    if tag == 'restartSong' then
        cameraFade("camOther", "000000", 0.0001, true)
        restartSong(true)
    end
end