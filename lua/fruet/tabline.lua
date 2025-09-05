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

local function build_full_tabline()
    -- Start with our custom mode indicator.
    local line = get_mode() .. ' '

    local current_tab = vim.api.nvim_get_current_tabpage()
    local all_tabs = vim.api.nvim_list_tabpages()

    -- Don't render tabs if there's only one.
    if #all_tabs <= 1 then
        line = line .. '%#TabLineFill#%T'
        return line
    end

    -- Loop through all available tab pages.
    for i, tab in ipairs(all_tabs) do
        -- Set highlight: TabLineSel for active tab, TabLine for others.
        if tab == current_tab then
            line = line .. '%#TabLineSel#'
        else
            line = line .. '%#TabLine#'
        end

        -- Make the tab label clickable.
        line = line .. string.format('%%{%d}T', i)

        -- Get the active window in this specific tab.
        local win_handle = vim.api.nvim_tabpage_get_win(tab)
        -- Get the buffer displayed in that window.
        local buf_handle = vim.api.nvim_win_get_buf(win_handle)
        -- Get the name of that buffer.
        local buf_name = vim.api.nvim_buf_get_name(buf_handle)

        -- Add padding and the file name (just the "tail" of the path).
        local file_name = vim.fn.fnamemodify(buf_name, ':t')
        line = line .. ' ' .. (file_name or '[No Name]') .. ' '
    end

    -- After the last tab, reset highlight and fill the rest of the line.
    line = line .. '%#TabLineFill#%T'

    return line
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
