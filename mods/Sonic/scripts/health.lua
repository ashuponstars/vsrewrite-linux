local flickerTimer = 0.2
local flickerState = false
local flickerActive = false

local noCountdown = true
local countdownHealth = 100
local lagCheck = true
local healthOverride = false

function onCreate()

    makeLuaSprite("countDownValue", nil, 100) -- the variable for the timer

    makeLuaText('healthLabelShadow', 'HEALTH', 0, 255, 35)
    setTextFont('healthLabelShadow', 'sonic-1-hud-font.ttf')
    setTextSize('healthLabelShadow', 40)
    setTextColor('healthLabelShadow', '0x000000')
    setTextAlignment('healthLabelShadow', 'left')
    setObjectCamera('healthLabelShadow', 'hud')
    addLuaText('healthLabelShadow')

    makeLuaText('healthLabel', 'HEALTH', 0, 250, 30)
    setTextFont('healthLabel', 'sonic-1-hud-font.ttf')
    setTextSize('healthLabel', 40)
    setTextColor('healthLabel', '0xe7e700')
    setTextAlignment('healthLabel', 'left')
    setObjectCamera('healthLabel', 'hud')
    addLuaText('healthLabel')

    makeLuaText('healthValueShadow', '', 0, 385, 35)
    setTextFont('healthValueShadow', 'sonic-1-hud-font.ttf')
    setTextSize('healthValueShadow', 40)
    setTextColor('healthValueShadow', '0x000000')
    setTextAlignment('healthValueShadow', 'left')
    setObjectCamera('healthValueShadow', 'hud')
    addLuaText('healthValueShadow')

    makeLuaText('healthValue', '', 0, 380, 30)
    setTextFont('healthValue', 'sonic-1-hud-font.ttf')
    setTextSize('healthValue', 40)
    setTextColor('healthValue', '0xffffff')
    setTextAlignment('healthValue', 'left')
    setObjectCamera('healthValue', 'hud')
    addLuaText('healthValue')

    setProperty('healthLabel.alpha', 1)
    setProperty('healthValue.alpha', 1)
    setProperty('healthLabelShadow.alpha', 1)
    setProperty('healthValueShadow.alpha', 1)

    if downscroll then
        setProperty('healthLabel.y', 650)
        setProperty('healthValue.y', 650)
        setProperty('healthLabelShadow.y', 650+5)
        setProperty('healthValueShadow.y', 650+5)
    end

    runTimer('flickerTimer', flickerTimer, 0)
end

function onUpdate(elapsed)
    local health = getProperty('health')
    local minDisplay = 0
    local maxDisplay = 50
    local mappedHealth = math.floor(minDisplay + (health * (maxDisplay - minDisplay)))
    mappedHealth = math.min(mappedHealth, 100)

    if noCountdown then
        if mappedHealth <=1 and mappedHealth > 0 then
            setTextString('healthValue', 1)
            setTextString('healthValueShadow', 1)
        else
            setTextString('healthValue', mappedHealth)
            setTextString('healthValueShadow', mappedHealth)
        end
    else
        setTextString('healthValue', math.floor(countdownHealth))
        setTextString('healthValueShadow', math.floor(countdownHealth))
    end

    setTextString('healthLabel', 'HEALTH')
    setTextString('healthLabelShadow', 'HEALTH')

    ---

    local shadowOffsetX = 2
    local shadowOffsetY = 2
    local screenWidth = getProperty('screenWidth')
    local screenHeight = getProperty('screenHeight')
    local healthLabelWidth = getTextWidth('healthLabel')
    local healthValueWidth = getTextWidth('healthValue')
    local textHeight = getTextHeight('healthLabel')
    local totalWidth = healthLabelWidth + healthValueWidth
    local x = (screenWidth - totalWidth) / 2
    local y = (screenHeight - textHeight) / 2

    if not healthOverride then
        setProperty('healthLabelShadow.x', x + shadowOffsetX)
        setProperty('healthLabelShadow.y', y + shadowOffsetY)
        setProperty('healthLabel.x', x)
        setProperty('healthLabel.y', y)

        setProperty('healthValueShadow.x', x + healthLabelWidth + shadowOffsetX)
        setProperty('healthValueShadow.y', y + shadowOffsetY)
        setProperty('healthValue.x', x + healthLabelWidth)
        setProperty('healthValue.y', y)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'flickerTimer' then
        local health = getProperty('health')
        local minDisplay = 0
        local maxDisplay = 100
        local mappedHealth = math.floor(minDisplay + (health * (maxDisplay - minDisplay)))

        if not healthOverride then
            if noCountdown then
                if mappedHealth < 30 then
                    if flickerState then
                        setTextColor('healthLabel', '0xe80000')
                        flickerState = false
                    else
                        setTextColor('healthLabel', '0xe7e700')
                        flickerState = true
                    end
                else
                    setTextColor('healthLabel', '0xe7e700')
                    flickerState = false
                end
            else
                if countdownHealth < 30 then
                    if flickerState then
                        setTextColor('healthLabel', '0xe80000')
                        flickerState = false
                    else
                        setTextColor('healthLabel', '0xe7e700')
                        flickerState = true
                    end
                else
                    setTextColor('healthLabel', '0xe7e700')
                    flickerState = false
                end
            end
        end
    end
end

function onStepHit()

    --"why aren't you using getProperty?" cuz desync sucks dick and i don't know the value properly so im doing this jank math shit sorry!!!! -snow
    --(yes i could just debugPrint to find out the positioning but im lazy stfu!!!!)

    if curStep == 4556 then
        doTweenX("healthLabelMove", "healthLabel", (250 - 230) - 50, 0.2, "quadOut")
        doTweenX("healthLabelShadow", "healthLabelShadow", (255 - 230) - 50, 0.2, "quadOut")

        doTweenX("healthValue", "healthValue", (380 - 230) - 50, 0.2, "quadOut")
        doTweenX("healthValueShadow", "healthValueShadow", (385 - 230) - 50, 0.2, "quadOut")
    end

    if curStep == 4558 then
        doTweenX("healthLabelMove", "healthLabel", ((250 - 230) - 50) + 585, 0.2, "quadInOut")
        doTweenX("healthLabelShadow", "healthLabelShadow", ((255 - 230) - 50) + 585, 0.2, "quadInOut")

        doTweenX("healthValue", "healthValue", ((380 - 230) - 50) + 585, 0.2, "quadInOut")
        doTweenX("healthValueShadow", "healthValueShadow", ((385 - 230) - 50) + 585, 0.2, "quadInOut")
    end

    if curStep >= 4560 and lagCheck then
        setProperty("countDownValue.x", getTextString("healthValue"))
        noCountdown = false
        lagCheck = false
        startTween('healthCountdown', 'countDownValue', {x = 0}, 19.7, {ease = 'linear', onUpdate = 'healthCountdown'})
        --lua jank moment, i rlly should learn hscript properly soon -snow
    end

    if curStep == 4768 then
        cancelTween("healthCountdown")
        setProperty("countDownValue.x", 0)
        countdownHealth = 0
        healthOverride = true
        setTextColor('healthLabel', '0xe80000')
        doTweenX("healthLabel", "healthLabel", (((250 - 230) - 50) + 585) + 50, 0.05, "quadOut")
        doTweenX("healthLabelShadow", "healthLabelShadow", (((255 - 230) - 50) + 585) + 50, 0.05, "quadOut")

        doTweenX("healthValue", "healthValue", (((380 - 230) - 50) + 585) + 50, 0.05, "quadOut")
        doTweenX("healthValueShadow", "healthValueShadow", (((385 - 230) - 50)) + 50, 0.05, "quadOut")
    end
end

function onTweenCompleted(tag)
    if tag == "healthLabel" then
        doTweenX("healthLabel2", "healthLabel",  (((250 - 230) - 50) + 585) - 100, 0.1, "quadInOut")
        doTweenX("healthLabelShadow", "healthLabelShadow", (((255 - 230) - 50) + 585) - 100, 0.1, "quadInOut")

        doTweenX("healthValue", "healthValue", (((380 - 230) - 50) + 585) - 100, 0.1, "quadInOut")
        doTweenX("healthValueShadow", "healthValueShadow", (((385 - 230) - 50)) - 100, 0.1, "quadInOut")
    end

    if tag == "healthLabel2" then
        doTweenX("healthLabel3", "healthLabel",  (((250 - 230) - 50) + 585), 0.05, "quadInOut")
        doTweenX("healthLabelShadow", "healthLabelShadow", (((255 - 230) - 50) + 585), 0.05, "quadInOut")

        doTweenX("healthValue", "healthValue", (((380 - 230) - 50) + 585), 0.05, "quadInOut")
        doTweenX("healthValueShadow", "healthValueShadow", (((385 - 230) - 50)), 0.05, "quadInOut")
    end
end

function healthCountdown()
    countdownHealth = getProperty('countDownValue.x')
end