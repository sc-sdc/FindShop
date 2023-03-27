--[[
    FindShop Daemon

	slimit75 2023
]]--

local commandName = "findshop"
local botName = "&b&lFindShop"
local botNameError = "&c&lFindShop"

while true do
    local event, user, command, args = os.pullEvent("command")

    if command == commandName then
        if #args == 0 then
            chatbox.tell(user, "FindShop is a command/service to find shops with a certain item and display their prices using ShopSync." , botName, nil)
        elseif #args > 1 then
            chatbox.tell(user, "**Error!** FindShop does not currently support multiple search parameters.", botNameError,  nil)
        elseif _G.shops == {} then
            chatbox.tell(user, "**Error!** FindShop was unable to find any shops.", botNameError, nil, "format")
        else
            print("[DEBUG] Searching for " .. args[1] .. "...")
            results = {}

            for i = 1, #shops do
                for z = 1, #shops[i].items do
                    if string.find(shops[i].items[z].item.name, args[1]) and (shops[i].items[z].shopBuysItem ~= true) then
                        priceKST = 0
                        for y = 1, #shops[i].items[z].prices do
                            if shops[i].items[z].prices[y].currency == "KST" then
                                priceKST = shops[i].items[z].prices[y].value
                                break
                            end
                        end

                        table.insert(results, {
                            shop = {
                                name = shops[i].info.name,
                                owner = shops[i].info.owner,
                                location = "x" .. shops[i].info.location.coordinates[1] .. " y" .. shops[i].info.location.coordinates[2] .. " z" .. shops[i].info.location.coordinates[3]
                            },
                            price = priceKST,
                            stock = shops[i].items[z].stock
                        })
                        break
                    end
                end
            end

            if #results == 0 then
                chatbox.tell(user, '**Error!** FindShop was unable to find any shops with the item: "' .. args[1] .. '".', botNameError, nil)
            else
                local printResults = ""

                for i = 1, #results do
                    printResults = printResults .. "\n&3" .. results[i].shop.name .. " &o&7(" .. results[i].shop.location .. ") &a" .. results[i].price .. " KST &fx" .. results[i].stock
                end

                chatbox.tell(user, "FindShop found the following: " .. printResults, botName, nil, "format")
            end
        end
     end
end
