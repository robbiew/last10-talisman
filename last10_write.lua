-- Last 10 Callers JSON Writer
-- [[loginitem]]                                
-- clear_screen = true                          
-- pause_after = false                          
-- command = "RUNSCRIPT"                        
-- data = "last10_write"                        
-- Include the dkjson library                   

-- Make sure you do `luarocks install dkjson` to install the json library!  

-------------------------------------------------------------------------------
local saveFile = "last10.json"
-------------------------------------------------------------------------------

local json = require "dkjson"

function writeCallerDataToJSON()
    local currentDate = os.date("%m/%d/%Y %H:%M:%S") -- Format date as MM/DD/YYYY HH:MM:SS
    local username = bbs_get_username()
    local location = bbs_get_user_location()
    local totalCalls = bbs_user_get_total_calls(username)
    local totalUploads = bbs_user_get_total_uploads(username)
    local totalDownloads = bbs_user_get_total_downloads(username)
    local totalMsgPosts = bbs_user_get_total_msgposts(username)
    local totalDoorsRun = bbs_user_get_total_doorsrun(username)

    local dataPath = bbs_get_data_path() -- Get the data path
    local jsonFilePath = dataPath .. "/" .. saveFile -- Create the full path to the JSON filename
    
    -- Check if file exists and is not empty
    local file = io.open(jsonFilePath, "r")
    local isEmpty = true
    if file then
        isEmpty = file:read("*a") == ""
        file:close()
    end

    local jsonFile = io.open(jsonFilePath, "a+") -- Open the JSON file in append mode

    -- Create a table with the data
    local data = {
        username = username,
        location = location,
        date = currentDate,
        totalCalls = totalCalls,
        totalUploads = totalUploads,
        totalDownloads = totalDownloads,
        totalMsgPosts = totalMsgPosts,
        totalDoorsRun = totalDoorsRun
    }

    -- Serialize the table into JSON format
    local jsonData = json.encode(data, { indent = true })

    if isEmpty then
        -- File is new or empty, start an array and add the first object
        jsonFile:write("[" .. jsonData .. "]")
    else
        -- File already contains data, append new object
        -- Move file pointer back to overwrite the last bracket
        jsonFile:seek("end", -1)
        jsonFile:write(",\n" .. jsonData .. "]")
    end

    jsonFile:close()
end

-- Run the function to write data to the JSON file
writeCallerDataToJSON()