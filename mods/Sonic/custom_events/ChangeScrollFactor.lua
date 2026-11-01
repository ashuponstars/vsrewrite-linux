function onEvent(name, value1, value2)
    if name == "ChangeScrollFactor" then
        local scrollFactor = tonumber(value1)
        local character = value2

        if character == 'dad' then
            setScrollFactor('dad', scrollFactor, scrollFactor)
        elseif character == 'bf' then
            setScrollFactor('boyfriend', scrollFactor, scrollFactor)
        elseif character == 'gf' then
            setScrollFactor('gf', scrollFactor, scrollFactor)
        end
    end
end
