local terminal_state = { buf = -1, win = -1, last_tab = -1 }

---@function returns a function that toggles terminal in specified location
---@param terminal_location string float|bottom|tab
---@returns function fun() Toggles Terminal in specified location
return function(terminal_location)
    terminal_location = terminal_location or "float"
    return function()
        if terminal_location == "float" or terminal_location == "bottom" then
            if vim.api.nvim_buf_is_valid(terminal_state.buf) and vim.api.nvim_win_is_valid(terminal_state.win) then
                vim.api.nvim_win_hide(terminal_state.win)
                return
            end
        end

        if terminal_location == "tab" then
            local current_win = vim.api.nvim_get_current_win()
            if vim.wo[current_win].winbar == "Terminal" then
                vim.api.nvim_set_current_tabpage(terminal_state.last_tab)
                return
            end
            for _, tab_id in ipairs(vim.api.nvim_list_tabpages()) do
                local win_id = vim.api.nvim_tabpage_get_win(tab_id)
                local buf_id = vim.api.nvim_win_get_buf(win_id)
                if vim.wo[win_id].winbar == "Terminal" and vim.bo[buf_id].buftype == "terminal" then
                    terminal_state.last_tab = vim.api.nvim_get_current_tabpage()
                    vim.api.nvim_set_current_tabpage(tab_id)
                    vim.cmd.startinsert()
                    return
                end
            end
            terminal_state.last_tab = vim.api.nvim_get_current_tabpage()
            vim.cmd.tabnew()
            local win_id = vim.api.nvim_get_current_win()
            vim.wo[win_id].winbar = "Terminal"
            vim.cmd.term()
            vim.cmd.startinsert()
            return
        end

        if not vim.api.nvim_buf_is_valid(terminal_state.buf) then
            terminal_state.buf = vim.api.nvim_create_buf(false, true)
        end

        if terminal_location == "float" then
            local height = math.floor(vim.o.lines * 0.8)
            local width = math.floor(vim.o.columns * 0.8)

            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
            })
        elseif terminal_location == "bottom" then
            local width = vim.o.columns
            local height = math.floor(vim.o.lines * 0.45)
            terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
                split = "below",
                width = width,
                height = height,
            })
        else
            vim.error("Invalid location for terminal")
            return
        end

        if vim.api.nvim_get_option_value("buftype", { buf = terminal_state.buf }) ~= "terminal" then
            vim.cmd.term()
        end

        vim.cmd.startinsert()
    end
end
