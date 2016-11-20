
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 640,
    height = 640,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        local design = {}
        design.width = 640
        design.height = design.width / framesize.width * framesize.height
        design.autoscale = "FIXED_WIDTH"
        
        return design;
    end
}

LOTA_TCP    = ""
LOTA_TCP_PORT = ""

LOTA_VERSION = "00.00.04.80"
NEIWANG = true

if NEIWANG == true then
    LOTA_VERSION_JSON       = ""
    LOTA_VERSION_TXT        = ""
    LOTA_VERSION_DOWNLOAD   = ""

    
    LOTA_UPDATE    = "115.29.148.25"
    -- LOTA_UPDATE = "112.126.85.84"
    -- LOTA_UPDATE = "120.26.14.216"
    LOTA_UPDATE_PORT = "5678"
else

    LOTA_VERSION_JSON       = ""
    LOTA_VERSION_TXT        = ""
    LOTA_VERSION_DOWNLOAD   = ""

    LOTA_UPDATE = "123.57.155.169"
    LOTA_UPDATE_PORT = "5678"
end