local energy = peripheral.find("energy_detector")
local barrel = peripheral.find("minecraft:barrel")
local trash = peripheral.find("trashcans:item_trash_can_tile")

local FE_PER_COIN = 9600

local function scanPayment()
    local items = barrel.list()
    local payment = 0  -- in "coins"

    -- barrel.list() returns a table keyed by slot index
    for slot, stack in pairs(items) do
        if stack and stack.name then
            if stack.name == "numismatics:spur" then
                payment = payment + stack.count * 1
            elseif stack.name == "numismatics:bevel" then
                payment = payment + stack.count * 8
            elseif stack.name == "numismatics:sprocket" then
                payment = payment + stack.count * 16
            elseif stack.name == "numismatics:cog" then
                payment = payment + stack.count * 64
            elseif stack.name == "numismatics:crown" then
                payment = payment + stack.count * 512
            elseif stack.name == "numismatics:sun" then
                payment = payment + stack.count * 4096
            end
        end
    end

    return payment
end

while true do
    -- wait for a redstone pulse to "start a transaction"
    os.pullEvent("redstone")

    local paymentCoins = scanPayment()

    if paymentCoins > 0 then
        -- 1) Calculate total FE to send
        local totalFE = paymentCoins * FE_PER_COIN

        -- 2) Decide how long the transfer should take:
        --    - small payments: about 1s
        --    - large payments: up to 10s
        local seconds = paymentCoins
        if seconds < 64 then seconds = 1 end
        if seconds > 64 then seconds = 10 end

        -- 3) Compute FE/tick needed to send totalFE in `seconds`
        -- ComputerCraft runs at 20 ticks per second
        local ticks = seconds * 20
        local ratePerTick = math.floor(totalFE / ticks)

        -- safety fallback, just in case
        if ratePerTick < 1 then
            ratePerTick = 1
        end

        -- 4) Remove all payment items (they've now been "spent")
        for slot = 1, 27 do
            local stack = barrel.getItemDetail(slot)
            if stack and string.match(stack.name, "^numismatics:") then
                barrel.pushItems(peripheral.getName(trash), slot)
            end
        end

        -- 5) Apply the rate limit for the chosen duration
        -- use ~1s loops like your original
        for i = 1, seconds do
            energy.setTransferRateLimit(ratePerTick)
            sleep(0.95)
        end

        -- 6) Turn off transfer after we're done
        energy.setTransferRateLimit(0)
        sleep(0.1)
    end
end
