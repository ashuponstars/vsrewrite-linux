local defaultZoom = 1

function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == "ZoomLiso" then
            local targetZoom = tonumber(value1)
            local zoomParams = split(value2, ',')
            
            if #zoomParams == 2 then
                local zoomDuration = tonumber(zoomParams[1])
                local holdTime = tonumber(zoomParams[2])
                
                if targetZoom and zoomDuration and holdTime then
                    doTweenZoom('camZoom', 'camGame', targetZoom, zoomDuration, 'sineInOut')
                    
                    runTimer('resetZoom', zoomDuration + holdTime)
                else
                    setProperty("defaultCamZoom", targetZoom)
                end
            end
        end
    end
end

function onTimerCompleted(tag)
    if tag == 'resetZoom' then
        doTweenZoom('resetZoomTween', 'camGame', defaultZoom, 1, 'sineInOut')
    end
end

function split(input, delimiter)
    local t = {}
    for str in string.gmatch(input, "([^" .. delimiter .. "]+)") do
        table.insert(t, str)
    end
    return t
end
