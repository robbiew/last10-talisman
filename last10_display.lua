-- Set to false if you don't want the sysop included -------
local show_sysop = false
local saveFile = "last10.json"
------------------------------------------------------------

-- Include the dkjson library
local json = require "dkjson"

function calculateDisplayTime(callDateTime)
    local callDate = callDateTime:match("([^ ]+)")
    if not callDate then
        return "Invalid Date"
    end

    local callMonth, callDay, callYear = callDate:match("(%d+)/(%d+)/(%d+)")
    if not (callYear and callMonth and callDay) then
        return "Invalid Date Format"
    end

    -- Return the date in MM/DD/YY format
    return string.format("%02d/%02d/%02d", callMonth, callDay, callYear % 100)
end

function displayLast10Entries()
    local sysopname = bbs_get_sysop_name()
    local dataPath = bbs_get_data_path()
    local jsonFile = io.open(dataPath .. "/" .. saveFile, "r")
    if not jsonFile then
        bbs_write_string("Error: Unable to open caller data file.\n")
        return
    end

    local jsonData = jsonFile:read("*a")
    jsonFile:close()

    local callers, pos, err = json.decode(jsonData)
    if err then
        bbs_write_string("Error decoding JSON: " .. err .. "\n")
        return
    end

    local lastCallers = {}
    local numEntries = 10
    for _, entry in ipairs(callers) do
        if show_sysop or entry.username ~= sysopname then
            if #lastCallers == numEntries then
                table.remove(lastCallers, 1)
            end
            table.insert(lastCallers, entry)
        end
    end

    for _, entry in ipairs(lastCallers) do
        local username, location, callDateTime, totalCalls, totalUploads, totalDownloads, totalMsgPosts, totalDoorsRun = 
            entry.username, entry.location, entry.date, entry.totalCalls, entry.totalUploads, entry.totalDownloads, entry.totalMsgPosts, entry.totalDoorsRun

        -- Only display the log if the sysop check passes
        if show_sysop or username ~= sysopname then
            username = #username > 18 and username:sub(1, 19) or username
            location = #location > 23 and location:sub(1, 23) or location
            local displayTime = calculateDisplayTime(callDateTime)

            local uploadMB = tonumber(totalUploads) / 1048576  -- Convert bytes to MB
            local uploadDisplay = string.format("%.1f", uploadMB)  -- Format to 1 decimal place

            local downloadMB = tonumber(totalDownloads) / 1048576  -- Convert bytes to MB
            local downloadDisplay = string.format("%.1f", downloadMB)  -- Format to 1 decimal place

            local output = string.format(" |11%-18s |13%-23s |05%-10s |08%-4d |08%-4s |07%-4d |15%-4d |15%-4d|07\r\n", 
                                            username, location, displayTime, totalCalls, 
                                            uploadDisplay, downloadDisplay, totalMsgPosts, totalDoorsRun)
            
            bbs_write_string(output)
        end
    end
end

bbs_display_gfile("last10_hdr")
displayLast10Entries()
bbs_display_gfile("last10_ftr")
bbs_pause()
