local startTime = 0
local duration = 3  

function onCreate()
    for i = 4, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
    end
end

function onUpdatePost(elapsed)
    if startTime < duration then
        startTime = startTime + elapsed

        for i = 4, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
        end
        
        if curStep == 0 then  -- Just before the song starts
            setPropertyFromGroup('strumLineNotes', 7, 'alpha', 0)
        end
    end
end
