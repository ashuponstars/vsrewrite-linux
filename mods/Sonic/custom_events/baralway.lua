function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        local fadeTime = tonumber(value1)
        local alphaValue = tonumber(value2)

        if name == 'baralway' then
            setProperty('healthLabel.alpha', alphaValue)
            setProperty('healthValue.alpha', alphaValue)
            setProperty('healthLabelShadow.alpha', alphaValue)
            setProperty('healthValueShadow.alpha', alphaValue)
        end
    end
end
