-- Automatically load external audio files with the same base name as the video.
-- Handles formats not recognized by mpv's built-in audio-file-auto (e.g. .mpa).
-- Checked extensions: mpa, mka, mp3, aac, flac, ogg, opus, m4a, wav, ac3, dts

local utils = require 'mp.utils'

local AUDIO_EXTS = { "mpa", "mka", "mp3", "aac", "flac", "ogg", "opus", "m4a", "wav", "ac3", "dts" }

mp.register_event("file-loaded", function()
    local path = mp.get_property("path")
    if not path then return end

    local dir, filename = utils.split_path(path)
    -- strip extension to get base name
    local basename = filename:match("^(.+)%.[^%.]+$") or filename

    for _, ext in ipairs(AUDIO_EXTS) do
        local audio_path = dir .. basename .. "." .. ext
        local info = utils.file_info(audio_path)
        if info and info.is_file then
            mp.commandv("audio-add", audio_path, "auto")
            mp.msg.info("Loaded external audio: " .. audio_path)
        end
    end
end)
