-- luacheck: globals mp
-- local i=require"inspect"
local msg = require "mp.msg"

local function fetch(url,opts)
  local luacurl_available, cURL = pcall(require,'cURL')
  if luacurl_available then
    local safe_url = url:match("[0-9a-zA-Z%%+~:/._-]+")
    local buf={}
    local o = opts or {}
    -- local UA = "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/111.0"
    local UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36"
    local c = cURL.easy_init()
    local headers = {
      "Accept: */*",
      -- "Accept-Language: ru,en",
      -- "Accept-Charset: utf-8,cp1251,koi8-r,iso-8859-5,*",
      "Cache-Control: no-cache",
      ("Referer: %s"):format(o.ref or "https://amedia.online/"),
    }
    c:setopt_httpheader(headers)
    c:setopt_followlocation(1)
    c:setopt_header(1)
    -- c:setopt_proxy("") -- TODO: conditional
    c:setopt_useragent(UA)
    -- c:setopt_cookiejar(o.cookie or "/tmp/mpv.animedia.cookies")
    -- c:setopt_cookiefile(o.cookie or "/tmp/mpv.animedia.cookies")
    c:setopt_url(safe_url)
    c:setopt_writefunction(function(chunk) table.insert(buf, chunk); return true; end)
    c:perform()
    -- print(i(buf))
    return table.concat(buf)
  else
    msg.error"Sorry, I need Lua-cURL (https://github.com/Lua-cURL/Lua-cURLv3) for work."
    msg.error"Please, install it using system package manager or any other method"
    msg.error"The goal is that Lua interpreter that mpv was built with should be able to find it"
  end
end

local function animyCheck()
  local path = mp.get_property("path", "")
  -- local path = mp.get_property("stream-open-filename", "")
  if path:match("^(%a+://amedia.online/.*)") then
    msg.verbose[[Hello! Animedia link detected.]]
    local o -- luacheck: ignore

    local req_o = {}
    for k,v in path:gmatch[=[%#%#%#([^%=%#]+)%=([^%#]+)]=] do
      req_o[k] = v
    end
    path=path:gsub("###.+$","")

    local main_src = fetch(path, o)
    local player_url = main_src:match([=[<iframe[^>]+src="([^"]+)"]=])
    if player_url then
      -- msg.info(player_url)
      if player_url:match"mangavost%.org" then
        local q = {
          ["auto"] = "/hls",
          ["720p"] = "/hls/720",
          ["360p"] = "/hls/360",
        }

        local match_pattern = [=[https://mangavost.org/content/stream/[^"']+/hls/index.m3u8]=]
        local player_src = fetch(player_url, o)
        local vid_url = player_src:match(match_pattern)
        if vid_url then
          local qual = q[req_o.q] or q["auto"]
          vid_url = vid_url:gsub("/hls", qual)
          local title_core = main_src:match([=[og:title" content="([^"]+)"]=])
          local ser_num = path:match([=[/episode/(%d+)/seriya]=])
          -- TODO: иногда серии могут иметь не ту нумерацию, которая в URL
          local title = ("%s - серия %d"):format(title_core, ser_num)
          mp.set_property("title", title)
          mp.set_property("stream-open-filename", vid_url)
          -- TODO: fill playlist with neighbour episodes
        else
          msg.error[[Current player is MangaVost, but something gone wrong when we tried to get video URL. Please, report.]] -- luacheck: ignore
        end
      else
        msg.error[[Unknown player (don't know how to handle it). Please, report.]]
        msg.error(("Player URL is: %s"):format(player_url))
        os.exit(1)
      end
    end
    -- mp.set_property("ytdl_hook-exclude", 'animy')
  end
end

mp.add_hook("on_load",10, animyCheck)

