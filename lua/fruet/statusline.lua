local M = {}

M.enabled = true -- Flag for lazy.nvim or other plugin managers

-- =============================================================================
-- Helper Functions
-- =============================================================================

-- A simple wrapper to format text with a highlight group.
local function hl_wrapper(hl_group, text)
    return string.format('%%#%s#%s%%*', hl_group, text)
end

local function set_highlights()
    -- Dynamically get colors from the current theme to make the statusline adaptive.
    local colors_ft = vim.api.nvim_get_hl(0, { name = 'Function', link = false })
    local colors_tlscp = vim.api.nvim_get_hl(0, { name = 'TelescopeNormal', link = false })
    local colors_tsctx = vim.api.nvim_get_hl(0, { name = 'TreesitterContext', link = false })
    local colors_comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })

    -- Filetype & Branch Highlights
    vim.api.nvim_set_hl(0, 'StatusLineFiletype', { bg = colors_tsctx.bg, fg = colors_tlscp.bg, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineBranch', { bg = colors_tsctx.bg, fg = colors_tlscp.bg })

    -- General Info Highlights
    vim.api.nvim_set_hl(0, 'StatusLineInfo', { bg = 'none', fg = 'fg' })
    vim.api.nvim_set_hl(0, 'StatusLineInfoNC', { bg = 'none', fg = colors_comment.fg }) -- Use Comment color for inactive windows
    vim.api.nvim_set_hl(0, 'StatusLineEncoding', { fg = '#98971a', bg = 'none' })
    vim.api.nvim_set_hl(0, 'StatusLineFilePercent', { fg = '#b16286', bg = 'none' })

    -- Mode-specific Highlights (Refactored to be DRY)
    -- Mapping from mode code to color values.
    local mode_colors = {
        N = { name = 'NORMAL', bg = '#458588', fg = '#ebdbb2' },
        I = { name = 'INSERT', bg = '#98971a', fg = '#282828' },
        V = { name = 'VISUAL', bg = '#b16286', fg = '#ebdbb2' },
        R = { name = 'REPLACE', bg = '#cc241d', fg = '#ebdbb2' },
        C = { name = 'COMMAND', bg = '#689d6a', fg = '#282828' },
        S = { name = 'SELECT', bg = '#d65d0e', fg = '#282828' },
        T = { name = 'TERMINAL', bg = '#a89984', fg = '#282828' },
        O = { name = 'O-PENDING', bg = '#d79921', fg = '#282828' },
        M = { name = 'MORE', bg = '#fe8019', fg = '#282828' },
        E = { name = 'EX', bg = '#fb4934', fg = '#282828' },
    }

    -- Loop through the colors to create the highlight groups automatically.
    for code, colors in pairs(mode_colors) do
        vim.api.nvim_set_hl(0, 'StatusLineMode' .. code, { bg = colors.bg, fg = colors.fg, bold = true })
        vim.api.nvim_set_hl(0, 'StatusLineMode' .. code .. 'Symbol', { fg = colors.bg, bg = 'none' })
    end
end

-- =============================================================================
-- Component Widgets
-- =============================================================================

-- Maps Vim's internal mode codes to our simplified, single-letter codes.
local mode_map = {
    ['n'] = 'N', ['no'] = 'O', ['nov'] = 'O', ['noV'] = 'O', ['no\22'] = 'O',
    ['niI'] = 'N', ['niR'] = 'N', ['niV'] = 'N', ['nt'] = 'N',
    ['v'] = 'V', ['vs'] = 'V', ['V'] = 'V', ['Vs'] = 'V', ['\22'] = 'V', ['\22s'] = 'V',
    ['s'] = 'S', ['S'] = 'S', ['\19'] = 'S',
    ['i'] = 'I', ['ic'] = 'I', ['ix'] = 'I',
    ['R'] = 'R', ['Rc'] = 'R', ['Rx'] = 'R', ['Rv'] = 'R', ['Rvc'] = 'R', ['Rvx'] = 'R',
    ['c'] = 'C', ['cv'] = 'E', ['ce'] = 'E',
    ['r'] = 'R', ['rm'] = 'M', ['r?'] = 'M',
    ['!'] = 'T', ['t'] = 'T',
}

local mode_names = {
    N = 'NORMAL', O = 'O-PENDING', V = 'VISUAL', S = 'SELECT', I = 'INSERT',
    R = 'REPLACE', C = 'COMMAND', E = 'EX', M = 'MORE', T = 'TERMINAL',
}

--- Returns the formatted mode indicator.
function M.get_mode()
    local current_mode_code = vim.api.nvim_get_mode().mode
    local code = mode_map[current_mode_code] or 'N' -- Default to Normal
    local name = mode_names[code]
    local text = string.format(' %s ', name)
    return hl_wrapper('StatusLineMode' .. code, text)
end

--- Returns the Git branch name, if in a git repository.
function M.get_branch()
    -- Using vim.fn.system is non-blocking in this context and safe for the statusline.
    local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
    if branch ~= '' then
        local text = string.format(' %s', branch)
        return hl_wrapper('StatusLineBranch', text)
    end
    return ''
end

--- Returns the filename with its devicon.
function M.get_filename(is_current_window)
    local filename = vim.fn.expand('%:t')
    if filename == '' then return '[No Name]' end

    -- Determine highlight based on window focus
    local hl_group = is_current_window and 'StatusLineInfo' or 'StatusLineInfoNC'

    local icon, _ = require('nvim-web-devicons').get_icon(filename, nil, { default = true })
    local text = string.format('%s %s', icon, filename)

    -- Add buffer flags
    local flags = ''
    if vim.bo.modified then flags = flags .. '+' end
    if vim.bo.readonly then flags = flags .. '' end
    if flags ~= '' then
        text = text .. ' ' .. flags
    end

    return hl_wrapper(hl_group, text)
end

--- Returns a summary of LSP diagnostics.
function M.get_diagnostics()
    local levels = {
        error = { icon = 'ERROR', count = 0, hl = 'DiagnosticError' },
        warn = { icon = 'WARN', count = 0, hl = 'DiagnosticWarn' },
        info = { icon = 'INFO', count = 0, hl = 'DiagnosticInfo' },
        hint = { icon = 'HINT', count = 0, hl = 'DiagnosticHint' },
    }

    for _, diag in ipairs(vim.diagnostic.get(0)) do
        if diag.severity == vim.diagnostic.severity.ERROR then levels.error.count = levels.error.count + 1
        elseif diag.severity == vim.diagnostic.severity.WARN then levels.warn.count = levels.warn.count + 1
        elseif diag.severity == vim.diagnostic.severity.INFO then levels.info.count = levels.info.count + 1
        elseif diag.severity == vim.diagnostic.severity.HINT then levels.hint.count = levels.hint.count + 1
        end
    end

    local parts = {}
    for _, level in pairs(levels) do
        if level.count > 0 then
            table.insert(parts, hl_wrapper(level.hl, string.format('%s %d', level.icon, level.count)))
        end
    end

    if #parts == 0 then
        return hl_wrapper('DiagnosticOk', 'OK') -- Assumes a DiagnosticOk highlight exists
    end

    return table.concat(parts, ' ')
end

--- Returns the line/column position.
function M.get_position()
    return ' %l:%c '
end


-- =============================================================================
-- Main Statusline Builder
-- =============================================================================

--- Constructs the full statusline string.
-- Note: Functions are exposed to _G (global) so they can be called from vim.o.statusline.
_G._statusline_get_mode = M.get_mode
_G._statusline_get_branch = M.get_branch
_G._statusline_get_filename = M.get_filename
_G._statusline_get_diagnostics = M.get_diagnostics
_G._statusline_get_position = M.get_position

function M.build_statusline()
    -- Check if the current window is active for highlighting purposes
    local is_cwin = vim.g.statusline_winid == vim.fn.win_getid() and 1 or 0

    local left = {
        '%{%v:lua._statusline_get_filename(' .. is_cwin .. ')%}',
    }

    local middle = {
        '%{%v:lua._statusline_get_diagnostics()%}',
    }

    local right = {
        hl_wrapper('StatusLineEncoding', ' %{&fenc} '),
        hl_wrapper('StatusLineFilePercent', ' %p%% '),
        '%{%v:lua._statusline_get_position()%}',
    }

    return table.concat(left, ' ')
        .. '%=' .. table.concat(middle, ' ')
        .. '%=' .. table.concat(right, ' ')
end

_G._build_full_statusline = M.build_statusline


-- =============================================================================
-- Setup
-- =============================================================================

set_highlights()
vim.opt.laststatus = 2
vim.opt.statusline = '%!v:lua._build_full_statusline()'
