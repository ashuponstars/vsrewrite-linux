function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then
        if name == 'RandomizeSonic' then
            -- random number between 1 and 100
            local randomValue = getRandomInt(1, 100)

            -- set character based on the random value thingy
            if randomValue <= 30 then
                triggerEvent('Change Character', 'dad', 'Sonic')
            else
                triggerEvent('Change Character', 'dad', 'SonicB')
            end
        end
    end
end
