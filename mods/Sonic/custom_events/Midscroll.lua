function onEvent(name, value1, value2)
    if name == "Midscroll" then
        keepScroll = false --idk what this does??? it was just here before so whatever -snow
        for i = 0,3 do
            noteTweenX(i..'mid',i+4,screenWidth/2+(110*(i-2)),0.5, 'sineInOut')
        end

        if not downscroll then
            doTweenY("healthLabelY", "healthLabel", 650, 0.5, "sineInOut")
            doTweenY("healthValueY", "healthValue", 650, 0.5, "sineInOut")
            doTweenY("healthLabelShadowY", "healthLabelShadow", 650+5, 0.5, "sineInOut")
            doTweenY("healthValueShadowY", "healthValueShadow", 650+5, 0.5, "sineInOut")
        else
            doTweenY("healthLabelY", "healthLabel", 30, 0.5, "sineInOut")
            doTweenY("healthValueY", "healthValue", 30, 0.5, "sineInOut")
            doTweenY("healthLabelShadowY", "healthLabelShadow", 30+5, 0.5, "sineInOut")
            doTweenY("healthValueShadowY", "healthValueShadow", 30+5, 0.5, "sineInOut")
        end
    end
end