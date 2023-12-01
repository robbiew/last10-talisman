-- Set to false if you don't want the sysop included -------
local show_sysop = false
------------------------------------------------------------

function calculateDisplayTime(callDateTime)
    local callDate = callDateTime:match("([^ ]+)")
    if not callDate then
        return "Invalid Date"
    end

    local callYear, callMonth, callDay = callDate:match("(%d+)/(%d+)/(%d+)")
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

            local output = string.format(" |13%-18s |05%-18s |03%-18s |08%-3d |08%-3d |07%-3s |15%-3d |15%-3d\r\n", 
                                         username, location, displayTime, totalCalls, 
                                         totalUploads, totalDownloads, totalMsgPosts, totalDoorsRun)
            
            bbs_write_string(output)
        end
    end
end


bbs_display_gfile("last10_hdr")
displayLast10Entries()
bbs_display_gfile("last10_ftr")
bbs_write_string(" |14Press any key....\r\n|07")
bbs_getchar()
