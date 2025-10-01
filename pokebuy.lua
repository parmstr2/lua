require("button")
require("pokelist")

local mon = peripheral.wrap("top")
local player = peripheral.find("player_detector")
local barrel = peripheral.find("minecraft:barrel")
local coins = peripheral.wrap("left")

-- make sure math.random is seeded once at the start of your program
math.randomseed(os.time())

function clearMon()
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.clear()
end

function generatePoke() 
    -- pick a random entry
    local randomIndex = math.random(#pokelist)  -- # gives the length of the array part
    local poke = pokelist[randomIndex]

    return poke
end

function scanPayment(poke)
    local items = barrel.list()
    local payment = poke[2]

    for i = 1, #items do
        if (items[i].name == "numismatics:spur") then
            payment = payment - items[i].count
        elseif (items[i].name == "numismatics:bevel") then
            payment = payment - (items[i].count * 8)
        elseif (items[i].name == "numismatics:sprocket") then
            payment = payment - (items[i].count * 16)
        elseif (items[i].name == "numismatics:cog") then
            payment = payment - (items[i].count * 64)
        elseif (items[i].name == "numismatics:crown") then
            payment = payment - (items[i].count * 512)
        elseif (items[i].name == "numismatics:sun") then
            payment = payment - (items[i].count * 4096)
        end
    end

    return payment
end

function purchasePoke(poke)
    clearMon()
    local x, y = mon.getSize()

    local sentence1 = "To confirm the purchase of " .. poke[1]
    local sentence2 = "click the player detector to the right."
    local sentence3 = "To cancel click anywhere on the screen."

    mon.setCursorPos(x/2 - #sentence1/2, y/2)
    mon.write(sentence1)
    mon.setCursorPos(x/2 - #sentence2/2, y/2+1)
    mon.write(sentence2)
    mon.setCursorPos(x/2 - #sentence3/2, y/2+2)
    mon.write(sentence3)

    while true do
        local event = {os.pullEvent()}
        if (event[1] == "playerClick") then
            local change = scanPayment(poke)
            if (change <= 0) then
                commands.exec("pokegive " .. event[2] .. " " .. poke[1])
                change = change * -1
                for i = 1, 27 do
                    if (string.match(barrel.getItemDetail(i).name, "numismatics:%w+")) then
                        barrel.pushItems(peripheral.getName(coins), i)
                    end
                end
                if (change > 0) then
                    coin = {1, 8, 16, 64, 512, 4096}
                    for i = 6, 1, -1 do
                        coins.pushItems(peripheral.getName(barrel), i, change % coin[i])
                        change = change - (coin[i] * (change % coin[i]))
                    end
                end
            else
                clearMon()
                local rejection = "I'm sorry but you have insufficient funds"
                mon.setCursorPos(x/2 - #rejection/2, y/2)
                mon.write(rejection)
            end
        elseif (event[1] == "monitor_touch") then
            clearMon()
            break
        end
    end
end

while true do
    -- Generate 6 random pokemon
    local poke1 = generatePoke()
    local poke2 = generatePoke()
    local poke3 = generatePoke()
    local poke4 = generatePoke()
    local poke5 = generatePoke()
    local poke6 = generatePoke()

    clearMon()
    
    -- Create 6 buttons to represent those pokemon
    local button1 = Button(15, 5, poke1[1] .. "(" .. poke1[2] .. ")")
    button1.draw(mon)
    local button2 = Button(15, 9, poke2[1] .. "(" .. poke2[2] .. ")")
    button2.draw(mon)
    local button3 = Button(15, 13, poke3[1] .. "(" .. poke3[2] .. ")")
    button3.draw(mon)
    local button4 = Button(35, 5, poke4[1] .. "(" .. poke4[2] .. ")")
    button4.draw(mon)
    local button5 = Button(35, 9, poke5[1] .. "(" .. poke5[2] .. ")")
    button5.draw(mon)
    local button6 = Button(35, 13, poke6[1] .. "(" .. poke6[2] .. ")")
    button6.draw(mon)

    os.startTimer(10)

    local event = {os.pullEvent()}

    if (event[1] == "monitor_touch") then
        if (button1.clicked(event[3], event[4])) then
            purchasePoke(poke1)
        elseif (button2.clicked(event[3], event[4])) then
            purchasePoke(poke2)
        elseif (button3.clicked(event[3], event[4])) then
            purchasePoke(poke3)
        elseif (button4.clicked(event[3], event[4])) then
            purchasePoke(poke4)
        elseif (button5.clicked(event[3], event[4])) then
            purchasePoke(poke5)
        elseif (button6.clicked(event[3], event[4])) then
            purchasePoke(poke6)
        end
    end
end