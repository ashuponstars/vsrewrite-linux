function onCreate()
	addHaxeLibrary("Lib", "openfl"); -- the usual import for this stuff
end

function onEvent(name, value1, value2)
    if name == 'WindowTitle' then
        if value2 ~= 'reset' then
            setPropertyFromClass('openfl.Lib', 'application.window.title', value1)
        else
            setPropertyFromClass('openfl.Lib', 'application.window.title', "VS Sonic")
        end
    end
end

function onDestroy()
    setPropertyFromClass('openfl.Lib', 'application.window.title', "VS Sonic")
end