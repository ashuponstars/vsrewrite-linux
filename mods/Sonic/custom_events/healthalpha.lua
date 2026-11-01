function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        local fadeTime = tonumber(value1)
        local alphaValue = tonumber(value2)

        if name == 'healthalpha' then
            doTweenAlpha('healthLabelAlpha', 'healthLabel', alphaValue, fadeTime, 'QuadOut')
            doTweenAlpha('healthValueAlpha', 'healthValue', alphaValue, fadeTime, 'QuadOut')
            doTweenAlpha('healthLabelShadowAlpha', 'healthLabelShadow', alphaValue, fadeTime, 'QuadOut')
            doTweenAlpha('healthValueShadowAlpha', 'healthValueShadow', alphaValue, fadeTime, 'QuadOut')
        end
    end
end
