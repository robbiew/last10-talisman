-- Run this from loginitems.toml, e.g: --
-- [[loginitem]]                      --
-- clear_screen = true                --
-- pause_after = false                --
-- command = "RUNSCRIPT"              -- 
-- data = "last10_write"              --

function writeCallerDataToCSV()
    local currentDate = os.date("%m/%d/%Y %H:%M:%S") -- Format date as MM/DD/YYYY HH:MM:SS
    local username = bbs_get_username()
    local location = bbs_get_user_location()
    local totalCalls = bbs_user_get_total_calls(username)
    local totalUploads = bbs_user_get_total_uploads(username)
    local totalDownloads = bbs_user_get_total_downloads(username)
    local totalMsgPosts = bbs_user_get_total_msgposts(username)
    local totalDoorsRun = bbs_user_get_total_doorsrun(username)

    local dataPath = bbs_get_data_path() -- Get the data path
    local csvFile = io.open(dataPath .. "/callerData.csv", "a") -- Open the CSV file in append mode

    csvFile:write(string.format("%s,%s,%s,%d,%d,%d,%d,%d\n", username, location, currentDate, totalCalls, totalUploads, totalDownloads, totalMsgPosts, totalDoorsRun))

    csvFile:close()
end

writeCallerDataToCSV()

