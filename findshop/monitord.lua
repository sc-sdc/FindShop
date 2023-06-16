--[[
    FindShop Monitor Daemon
    Copyright (C) 2023 slimit75

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

-- Load & open modem to ShopSync channel
local modem = peripheral.wrap("top")
modem.open(9773)

-- Loop to check for shops continously
findshop.infoLog("monitord", "Started monitord")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    -- Verify received message is valid
    if (message.type) and (message.type == "ShopSync") then
        -- Check to see if this shop already exists in the cache
        index = nil
        for i, shop in ipairs(findshop.shops) do
            if (message.info.location) and (shop.info.location) then
                local coord = shop.info.location.coordinates
                local scannedCoord = message.info.location.coordinates

                local x_check = coord[1] == scannedCoord[1]
                local y_check = coord[2] == scannedCoord[2]
                local z_check = coord[3] == scannedCoord[3]

                if x_check and y_check and z_check then
                    index = i
                    break
                end
            else
                if (shop.info.name == message.info.name) then
                    if (shop.info.owner) then
                        if (shop.info.owner == message.info.owner) then
                            index = i
                        end
                    else
                        index = i
                    end
                end
            end
        end

        -- Add (updated?) shop to cache
        if index == nil then
            table.insert(findshop.shops, message)
            findshop.infoLog("monitord", "Found new shop! " .. message.info.name)
        else
            findshop.shops[index] = message
        end
    end
end
