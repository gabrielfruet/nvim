-- =============================================================================
-- Tabline with Mode Indicator + Custom Tab Renderer (v2)
-- =============================================================================

---
-- SECTION 1: Mode Widget
-- This code is for displaying the current editor mode.
---

local mode_map = {
    ['n'] = 'N', ['no'] = 'O', ['nov'] = 'O', ['noV'] = 'O', ['no\22'] = 'O',
    ['niI'] = 'N', ['niR'] = 'N', ['niV'] = 'N', ['nt'] = 'N', ['v'] = 'V',
    ['vs'] = 'V', ['V'] = 'V', ['Vs'] = 'V', ['\22'] = 'V', ['\22s'] = 'V',
    ['s'] = 'S', ['S'] = 'S', ['\19'] = 'S', ['i'] = 'I', ['ic'] = 'I',
    ['ix'] = 'I', ['R'] = 'R', ['Rc'] = 'R', ['Rx'] = 'R', ['Rv'] = 'R',
    ['Rvc'] = 'R', ['Rvx'] = 'R', ['c'] = 'C', ['cv'] = 'E', ['ce'] = 'E',
    ['r'] = 'R', ['rm'] = 'M', ['r?'] = 'M', ['!'] = 'T', ['t'] = 'T',
}

local mode_names = {
    N = 'NORMAL', O = 'O-PENDING', V = 'VISUAL', S = 'SELECT', I = 'INSERT',
    R = 'REPLACE', C = 'COMMAND', E = 'EX', M = 'MORE', T = 'TERMINAL',
}

local function get_mode()
    local current_mode_code = vim.api.nvim_get_mode().mode
    local code = mode_map[current_mode_code] or 'N'
    local name = mode_names[code]
    local text = string.format(' %s ', name)
    return string.format('%%#StatusLineMode%s#%s%%*', code, text)
end

---
-- SECTION 2: Main Tabline Builder
-- This function now correctly finds the buffer name and omits the close button.
---
---
MAX_CONTEXT = 5

local function build_full_tabline()
    local line = get_mode() .. ' '
    local current_tab = vim.api.nvim_get_current_tabpage()
    local all_tabs = vim.api.nvim_list_tabpages()

    if #all_tabs <= 1 then
        return line .. '%#TabLineFill#%T'
    end

    for i, tab in ipairs(all_tabs) do
        -- Highlight: active tab vs inactive tabs
        if tab == current_tab then
            line = line .. '%#TabLineSel#'
        else
            line = line .. '%#TabLine#'
        end

        -- Make tab clickable
        line = line .. string.format('%%%dT', i)

        -- Active window + buffer in this tab
        local win = vim.api.nvim_tabpage_get_win(tab)
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)

        local label
        if buf_name == "" then
            label = "[No Name]"
        else
            -- Shorten path more like default `tabline`
            -- `:~` → show `~` for home, `:.` → relative path, `:h`/`:t` → head/tail
            buf_name = vim.fn.fnamemodify(buf_name, ":~")
            ---@type string
            label = vim.fn.pathshorten(buf_name, 1)
            -- i want to shorten the string to a cap of 20 chars
            label = string.sub(label, 1, 20)
        end

        line = line .. " " .. label .. " "
    end

    return line .. "%#TabLineFill#%T"
end


---
-- SECTION 3: Setup
-- This part defines highlights and applies the configuration.
---

local function set_highlights()
    local mode_colors = {
        N = { bg = '#458588', fg = '#ebdbb2' }, I = { bg = '#98971a', fg = '#282828' },
        V = { bg = '#b16286', fg = '#ebdbb2' }, R = { bg = '#cc241d', fg = '#ebdbb2' },
        C = { bg = '#689d6a', fg = '#282828' }, S = { bg = '#d65d0e', fg = '#282828' },
        T = { bg = '#a89984', fg = '#282828' }, O = { bg = '#d79921', fg = '#282828' },
        M = { bg = '#fe8019', fg = '#282828' }, E = { bg = '#fb4934', fg = '#282828' },
    }
    for code, colors in pairs(mode_colors) do
        vim.api.nvim_set_hl(0, 'StatusLineMode' .. code, { bg = colors.bg, fg = colors.fg, bold = true })
    end
end

-- Expose the build function to the global scope.
_G._build_full_tabline = build_full_tabline

-- Run the setup.
set_highlights()
vim.opt.showtabline = 2
vim.opt.tabline = '%!v:lua._build_full_tabline()' -- Use the expression syntax for the full builder.

vim.api.nvim_create_autocmd({ 'ModeChanged', 'TabNew', 'TabClosed', 'BufEnter' }, {
    pattern = "*",
    group = vim.api.nvim_create_augroup('MyTablineRedraw', { clear = true }),
    command = "redrawtabline",
})
