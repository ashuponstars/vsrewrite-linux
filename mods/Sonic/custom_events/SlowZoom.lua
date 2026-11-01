local defaultZoom = 1 

function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == "SlowZoom" then
            local targetZoom = tonumber(value1)
            local zoomParams = split(value2, ',')
            
            if #zoomParams == 2 then
                local zoomDuration = tonumber(zoomParams[1])
                local holdTime = tonumber(zoomParams[2])
                
                if targetZoom and zoomDuration and holdTime then
                    -- Set slow zoom
                    doTweenZoom('camZoom', 'camGame', targetZoom, zoomDuration, 'sineInOut')
                    runTimer('resetZoom', zoomDuration + holdTime)
                end
            end
        end
    end
end

function onTimerCompleted(tag)
    if tag == 'resetZoom' then
        -- Reset zoom back to default value
        doTweenZoom('resetZoomTween', 'camGame', defaultZoom, 1, 'sineInOut')
    end
end

-- Helper function to split a string by a delimiter
function split(input, delimiter)
    local t = {}
    for str in string.gmatch(input, "([^" .. delimiter .. "]+)") do
        table.insert(t, str)
    end
    return t
end
