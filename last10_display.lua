-- Set to false if you don't want the sysop included -------
local show_sysop = false
------------------------------------------------------------

function calculateDisplayTime(callDateTime)
    -- Extract date and time from the callDateTime string
    local callDate, callTime = callDateTime:match("([^ ]+) ([^ ]+)")
    if not callDate or not callTime then
        return "Time Error"
    end

    -- Extract individual date components
    local callMonth, callDay, callYear = callDate:match("(%d+)/(%d+)/(%d+)")
    local callHour, callMin, callSec = callTime:match("(%d+):(%d+):(%d+)")
    if not (callMonth and callDay and callYear and callHour and callMin and callSec) then
        return "Format Error"
    end

    -- Convert date and time components to numbers
    callMonth, callDay, callYear, callHour, callMin, callSec = tonumber(callMonth), tonumber(callDay), tonumber(callYear), tonumber(callHour), tonumber(callMin), tonumber(callSec)
    if not (callMonth and callDay and callYear and callHour and callMin and callSec) then
        return "Conversion Error"
    end

    -- Get the current date and time
    local currentDateTime = os.date("*t")

    -- Compare call date to current date
    if callDay == currentDateTime.day and callMonth == currentDateTime.month and callYear == currentDateTime.year then
        -- Call date is today; calculate the time difference in hours and minutes
        local callTimeInMinutes = callHour * 60 + callMin
        local currentTimeInMinutes = currentDateTime.hour * 60 + currentDateTime.min
        local diffInMinutes = currentTimeInMinutes - callTimeInMinutes

        if diffInMinutes < 1 then
            return "Just now"  -- For calls within the current minute
        end

        local hours = math.floor(diffInMinutes / 60)
        local minutes = diffInMinutes % 60
        local timeString = ""
        if hours > 0 then timeString = hours .. "h " end
        if minutes > 0 then timeString = timeString .. minutes .. "m " end
        return timeString .. "ago"
    else
        -- Call date is different; return the date as MM/DD/YYYY
        return string.format("%02d/%02d/%04d", callMonth, callDay, callYear)
    end
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
        if #lastLines == numLines then
            table.remove(lastLines, 1)
        end
        table.insert(lastLines, line)
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