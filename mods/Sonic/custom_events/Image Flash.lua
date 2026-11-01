function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == 'Image Flash' then
            makeLuaSprite('image', value1, 0, 0);
            scaleObject('image', 1, 1);
            addLuaSprite('image', false);
            setObjectCamera('image', 'hud');
            setProperty('image.alpha', 1);

            runTimer('startFade', value2);

            function onTimerCompleted(tag, loops, loopsleft)
                if tag == 'startFade' then
                    doTweenAlpha('fadeOut', 'image', 0, 1, 'linear');
                end
            end
            
            function onTweenCompleted(tag)
                if tag == 'fadeOut' then
                    removeLuaSprite('image', true);
                end
            end
        end
    end
end
