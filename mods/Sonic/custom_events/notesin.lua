function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == 'notesin' then
            local duration = tonumber(value1) or 1
            showNotes(duration)
        end
    end
end

function showNotes(fadeDuration)
    for i = 4, 7 do
        noteTweenAlpha('noteFadeIn'..i, i, 1, fadeDuration, 'linear')
    end
end
