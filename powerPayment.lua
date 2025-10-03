local energy = peripheral.find("energy_detector")
local barrel = peripheral.find("minecraft:barrel")
local trash = peripheral.find("trashcans:item_trash_can_tile")

function scanPayment()
    local items = barrel.list()
    local payment = 0

    for i = 1, #items do
        if (items[i].name == "numismatics:spur") then
            payment = payment + items[i].count
        elseif (items[i].name == "numismatics:bevel") then
            payment = payment + (items[i].count * 8)
        elseif (items[i].name == "numismatics:sprocket") then
            payment = payment + (items[i].count * 16)
        elseif (items[i].name == "numismatics:cog") then
            payment = payment +(items[i].count * 64)
        elseif (items[i].name == "numismatics:crown") then
            payment = payment + (items[i].count * 512)
        elseif (items[i].name == "numismatics:sun") then
            payment = payment + (items[i].count * 4096)
        end
    end

    return payment
end

while true do
    local payment = scanPayment()
    os.pullEvent("redstone")
    energy.setTransferRateLimit(9600 * payment)
    energy.setTransferRateLimit(0)
    if (payment > 0) then
        for i = 1, 27 do
            if (barrel.getItemDetail(i)) then
                if (string.match(barrel.getItemDetail(i).name, "numismatics:%w+")) then
                    barrel.pushItems(peripheral.getName(trash), i)
                end
            end
        end
    end
    sleep(3)
end