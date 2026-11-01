function onEvent(name, value1, value2, strumTime)
    if name == "CameraFlash" then
        cameraFlash("camOther", value1, value2, true)
    end
end
--lol