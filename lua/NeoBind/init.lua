
M = {}

local buf, win

M.create_window = function ()
    -- create a buffer
    buf = vim.api.nvim_create_buf(false, true)

    -- get win height and width
    local height = vim.api.nvim_get_option("lines")
    local width = vim.api.nvim_get_option("columns")

    -- floating window height and width
    local win_height = math.ceil(height * 0.8)
    local win_width = math.ceil(width * 0.8)

    -- floating window starting position
    local win_x = math.ceil((height - win_height) / 2 - 1)
    local win_y = math.ceil((width - win_width) / 2)

    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = win_x,
        col = win_y
    }

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_command("setlocal cursorline")
    vim.api.nvim_command("setlocal nowrap")
end

M.list_recent_files = function (win, buf)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
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
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
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

M.open_recent = function ()
    M.create_window()
    M.list_recent_files(win, buf)
end

-- jump to window

vim.api.nvim_set_keymap('n', ',,r', ':lua require "NeoBind".open_recent()<CR>', {})
vim.api.nvim_set_keymap('n', ',n', ':lua require "NeoBind".open_file()<CR>', {})

return M
