M = {}

local buf, win
local notes_dir = "/Users/sanketjadhav/allProjects/+Study/notes"

M.create_window = function (w, h)
    -- create a buffer which will be wiped once focus is lost
    buf = vim.api.nvim_create_buf(false, true)

    -- get win height and width
    local height = vim.api.nvim_get_option("lines")
    local width = vim.api.nvim_get_option("columns")

    -- floating window height and width
    local win_height = math.ceil(height * (h / 100)) -- h percent of the total screen
    local win_width = math.ceil(width * (w / 100)) -- w percent of the total screen

    -- floating window starting position
    local win_x = math.ceil((height - win_height) / 2 - 1)
    local win_y = math.ceil((width - win_width) / 2)

    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = win_x,
        col = win_y,
        border = 'rounded'
    }

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_command("setlocal cursorline")
    vim.api.nvim_command("setlocal nowrap")
end

M.list_recent_files = function (win, buf)
    vim.api.nvim_buf_set_option(0, 'modifiable', true)
    local item_count = vim.api.nvim_win_get_height(win) - 3
    local recentfiles = vim.api.nvim_get_vvar("oldfiles")
    local list = {}

    for i=1, item_count, 1 do 
        -- get path relative to home directory
        local path = vim.api.nvim_call_function('fnamemodify', {recentfiles[i], ":~"})
        if string.match(path, "term") then
            goto continue
        end
        table.insert(list, #list + 1, "  " .. path)
        ::continue::
    end

    vim.api.nvim_buf_set_lines(buf, 0, 0, false, {"Recent files"})
    -- line
    local width = vim.api.nvim_win_get_width(win)
    vim.api.nvim_buf_set_lines(buf, 1, 1, false, {string.rep('-', width)})
    vim.api.nvim_buf_set_lines(buf, 2, -1, false, list)
    vim.api.nvim_buf_set_option(0, 'modifiable', false)
end

M.open_file = function ()
    if win and vim.api.nvim_win_is_valid(win) then
        -- open file in a new buffer
        -- get the path
        local path = vim.api.nvim_get_current_line()
        -- open a new tabe with path
        vim.api.nvim_command("tabnew " .. path)
        -- clsoe the window after opening the file
        vim.api.nvim_win_close(win, {})
    else 
        print("Valid window not present")
    end
end

M.open_recent_window = function ()
    M.create_window(80, 80)
    M.list_recent_files(win, buf)
end

M.open_file_in_float = function()
    local file_name = vim.api.nvim_get_current_line()
    local path = notes_dir.."/"..file_name
    vim.api.nvim_command("edit "..path)
end

M.open_notes = function ()
    M.create_window(80, 80)
    local output = vim.api.nvim_exec("!ls /Users/sanketjadhav/allProjects/+Study/notes", {":!"})
    local list = {}
    for file in (output):gmatch('(.-)\n') do
        table.insert(list, #list + 1, file)
    end
    -- remove the first element
    table.remove(list, 1)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_keymap(buf, 'n',',n', ':lua require "neobind".open_file_in_float()<CR>', {})
end

M.open_jump_window = function ()
    M.create_window(80, 10) 
    vim.api.nvim_buf_set_lines(0, 0, 0, false, {">>> "})
    vim.api.nvim_win_set_cursor(0, {1, 5})
    vim.api.nvim_buf_set_keymap(0, 'n', ",j", ":echo 'pressed j'<CR>", {})
end

M.gif_animation_window = function ()
    local path = "/Users/sanketjadhav/allProjects/+lab/AsciiPython/anim.py"
    M.create_window(80, 80)
    -- execute the python file
    vim.api.nvim_command("term ")
end

-- jump to window
vim.api.nvim_set_keymap('n', ',,r', ':lua require "NeoBind".open_recent_window()<CR>', {})
vim.api.nvim_set_keymap('n', ',n', ':lua require "NeoBind".open_file()<CR>', {})
vim.api.nvim_set_keymap('n', ',,j', ':lua require "NeoBind".open_jump_window()<CR>', {})
vim.api.nvim_set_keymap('n', ',e', ':lua require "NeoBind".open_file_in_float()<CR>', {})

return M
