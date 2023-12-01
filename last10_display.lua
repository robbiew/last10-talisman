-- Set to false if you don't want the sysop included -------
local show_sysop = false
------------------------------------------------------------

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
    local csvFile = io.open(dataPath .. "/callerData.csv", "r")
    if not csvFile then
        bbs_write_string("Error: Unable to open caller data file.\n")
        return
    end

    local lastLines = {}
    local numLines = 10
    for line in csvFile:lines() do
        local username = line:match("([^,]+)") -- Extract the username from the line

        if show_sysop or username ~= sysopname then
            if #lastLines == numLines then
                table.remove(lastLines, 1)
            end
            table.insert(lastLines, line)
        end
    end
    csvFile:close()

    for _, line in ipairs(lastLines) do
        local data = {}
        for value in line:gmatch("([^,]+)") do
            table.insert(data, value)
        end

        if #data < 8 then
            bbs_write_string("Error: Incomplete data in line.\n")
            break
        end

        local username, location, callDateTime, totalCalls, totalUploads, totalDownloads, totalMsgPosts, totalDoorsRun = table.unpack(data)

        -- Only display the log if the sysop check passes
        if show_sysop or username ~= sysopname then
            username = #username > 15 and username:sub(1, 15) or username
            location = #location > 15 and location:sub(1, 15) or location
            local displayTime = calculateDisplayTime(callDateTime)
        
        -- Convert uploads to megabytes and format for 3-digit space
        local uploadMB = tonumber(totalUploads) / 1048576  -- Convert bytes to MB
        local uploadDisplay = string.format("%.1f", uploadMB)  -- Format to 1 decimal place

        local downloadMB = tonumber(totalDownloads) / 1048576  -- Convert bytes to MB
        local downloadDisplay = string.format("%.1f", downloadMB)  -- Format to 1 decimal place

        local output = string.format(" |11%-18s |13%-18s |05%-15s |08%-4d |08%-4s |07%-4d |15%-4d |15%-4d|07\r\n", 
                                        username, location, displayTime, totalCalls, 
                                        uploadDisplay, downloadDisplay, totalMsgPosts, totalDoorsRun)
        
        bbs_write_string(output)
        end
    end
end


bbs_display_gfile("last10_hdr")
displayLast10Entries()
bbs_display_gfile("last10_ftr")
bbs_write_string(" |14Press any key....\r\n|07")
bbs_getchar()
