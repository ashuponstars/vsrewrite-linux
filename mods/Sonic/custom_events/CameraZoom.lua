function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == "CameraZoom" then
            amount = value1
            duration = value2
            doTweenZoom('in','camGame',amount,duration,'circOut')
        end
    end
end