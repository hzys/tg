CONTACT_NAME = 'Fedr' -- It can be a part of contacts name
MESSAGE_COUNT = 50000
DATABASE_FILE = 'chat_history.sqlite3'

function history_cb(extra, success, history)
   if success then
     successCount = successCount + 1
      chatsFile:write("-----------new history start----------\n")
      print("------new history start---------")
      for _,m in ipairs(ReverseTable(history)) do
         if not m.service then -- Ignore Telegram service messages
--             local out = m.out and 1 or 0 -- Cast boolean to integer
            if m.text == nil then -- No nil value
               m.text = ''
            end
--             local sql = [[
--                   INSERT INTO messages
--                   (`from`, `to`, `text`, `out`, `date`, `message_id`, `media`, `media_type`,`url`)
--                   VALUES (
--                      ']] .. m.from.print_name .. [[',
--                      ']] .. m.to.print_name .. [[',
--                      ']] .. m.text .. [[',
--                      ']] .. out .. [[',
--                      ']] .. m.date .. [[',
--                      ']] .. m.id .. [[',
--                         ]]
            if (m.media ~= nil) then
              m.text = "[" .. m.media.type .. "]"
--                sql = sql .. "NULL, NULL, NULL)"
--             elseif m.media.type == 'webpage' and m.media.url ~= nil then
--                sql = sql .. "'1','".. m.media.type .. "', '" .. m.media.url .. "')"
--             else
--                sql = sql .. "'1','".. m.media.type .. "', NULL)"
            end
            local sql = os.date('%Y-%m-%d %H:%M:%S', m.date) .. " " .. m.from.print_name .. ":" .. m.text
            chatsFile:write(sql .. "\n")
--             print(m.id)
            -- require 'pl.pretty'.dump(m)
--             print(sql)
--             db:exec(sql)
         end
      end
        chatsFile:write("---------------------\n")
        chatsFile:write("\n")
        chatsFile:flush()
--       print("---------------------")
--       print()
      currIndex = currIndex + 1
    else
      print ("history_cb failure")
   end
   print ("successCount = " .. successCount)

   -- get next history
   getNext()
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

-- not working
function sortTable(t)
  table.sort(t, function(a, b) return a.date > b.date end)
  return t
end

function dialogs_cb(extra, success, dialog)
  successCount = 0
   if success then
     print("dialogs_count:" .. #dialog)
     dialogs = dialog
     currIndex = 0
     getNext()
   end
end

function contacts_cb(extra, success, contacts)
  successCount = 0
  if success then
     print("dialogs_count:" .. #contacts)
     dialogs = contacts
     currIndex = 0
     getNext()
  else
    print("contacts_cb failure")
  end
end

function getNext()
  d = dialogs[currIndex]
  if not d then
    chatsFile:close()
    print("fetched all chats")
    return
  end

  v = d.peer
  print("get_history for " .. v.print_name)
  sleep(1)

  if v.print_name ~= nil and not string.match(v.print_name, "Telegram") then
    get_history(v.print_name, MESSAGE_COUNT, history_cb, dialogs)
  else
    print("v.print_name == nil or == telegram")
    currIndex = currIndex + 1
    getNext()
  end
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function on_binlog_replay_end ()
--    sqlite3 = require("lsqlite3")
--    db = sqlite3.open(DATABASE_FILE)
--
--    db:exec[[
--          CREATE TABLE messages (
--             `id` INTEGER PRIMARY KEY,
--             `from` TEXT,
--             `to` TEXT,
--             `text` TEXT,
--             `out` INTEGER,
--             `date` INTEGER,
--             `message_id` INTEGER,
--             `media` TEXT,
--             `media_type` TEXT,
--             `url` TEXT
--                                );
--           ]]

  chatsFile = io.open("chats.txt", "w+")
   get_dialog_list(dialogs_cb, contacts_extra)
end

function on_msg_receive (msg)
end

function on_our_id (id)
end

function on_secret_chat_created (peer)
end

function on_user_update (user)
end

function on_chat_update (user)
end

function on_get_difference_end ()
end
