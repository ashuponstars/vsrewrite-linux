local bumpDuration = 0.05
local bumpAmount = 1.05

function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == "Cambump" then
            triggerBump()
        end
    end
end

function onUpdate(elapsed)
    if bumpActive then
        local currentZoom = getProperty('camGame.zoom')
        doTweenZoom('quickZoom', 'camGame', currentZoom * bumpAmount, bumpDuration, 'sineInOut')
        runTimer('resetBumpZoom', bumpDuration)
        bumpActive = false
    end
end

function onTimerCompleted(tag)
    if tag == 'resetBumpZoom' then
        local currentZoom = getProperty('camGame.zoom')
        doTweenZoom('bumpResetTween', 'camGame', currentZoom, bumpDuration, 'sineInOut')
    end
end

function triggerBump()
    bumpActive = true
end
