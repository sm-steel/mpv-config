-- Automatically load external audio files with the same base name as the video.
-- Handles formats not recognized by mpv's built-in audio-file-auto (e.g. .mpa).
--
-- Uses on_load hook so the audio is registered BEFORE on_preloaded runs,
-- meaning sub-select (which reads tracks at on_preloaded priority 25) will
-- already see the external audio when it makes its selection.
--
-- Checked extensions: mpa, mka, mp3, aac, flac, ogg, opus, m4a, wav, ac3, dts

local msg   = require 'mp.msg'
local utils = require 'mp.utils'

local AUDIO_EXTS = { "mpa", "mka", "mp3", "aac", "flac", "ogg", "opus", "m4a", "wav", "ac3", "dts" }

-- on_preloaded priority 10 runs before sub-select's hooks at 25/26/30.
-- At on_preloaded the demuxer is open so audio-add works.
mp.add_hook('on_preloaded', 10, function()
    local path = mp.get_property("path")
    if not path or path:find("://") then return end  -- skip network streams

    local dir, filename = utils.split_path(path)
    local basename = filename:match("^(.+)%.[^%.]+$") or filename

    for _, ext in ipairs(AUDIO_EXTS) do
        local audio_path = dir .. basename .. "." .. ext
        local info = utils.file_info(audio_path)
        if info and info.is_file then
            mp.commandv("audio-add", audio_path, "auto")
            msg.info("Added external audio: " .. audio_path)
        end
    end
end)
