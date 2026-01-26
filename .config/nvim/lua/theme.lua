local M = {}

-- Colors from your Alacritty config
local colors = {
	bg = "#1E1E2E",
	fg = "#CDD6F4",
	bright_fg = "#DDE2F7",
	dim_fg = "#BAC2DE",

	black = "#45475A",
	red = "#F38BA8",
	green = "#A6E3A1",
	yellow = "#F9E2AF",
	blue = "#89B4FA",
	magenta = "#F5C2E7",
	cyan = "#94E2D5",
	white = "#BAC2DE",

	bright_black = "#585B70",
	bright_white = "#A6ADC8",

	cursor_bg = "#F5E0DC",
	cursor_txt = "#1E1E2E",

	visual_bg = "#F5E0DC",
	visual_txt = "#1E1E2E",
}

function M.apply()
	local c = colors

	-- Set global colors
	vim.cmd("hi clear")
	vim.o.background = "dark"

	-- Basic UI elements
	local hl = vim.api.nvim_set_hl
	hl(0, "Normal", { fg = c.fg, bg = c.bg })
	hl(0, "Normal", { fg = c.fg, bg = "NONE" })
	hl(0, "NormalFloat", { fg = c.fg, bg = "NONE" })
	hl(0, "SignColumn", { bg = "NONE" })
	hl(0, "LineNr", { fg = c.dim_fg, bg = "NONE" })
	hl(0, "CursorLine", { bg = "NONE" })
	hl(0, "CursorColumn", { bg = "NONE" })
	hl(0, "StatusLine", { bg = "NONE" })
	hl(0, "NormalFloat", { fg = c.fg, bg = c.bg })
	hl(0, "FloatBorder", { fg = c.dim_fg, bg = c.bg })

	-- Cursor
	hl(0, "Cursor", { fg = c.cursor_txt, bg = c.cursor_bg })
	hl(0, "CursorLine", { bg = "#2B2B3A" })
	hl(0, "CursorColumn", { bg = "#2B2B3A" })

	-- Selection
	hl(0, "Visual", { fg = c.visual_txt, bg = c.visual_bg })

	-- Line numbers
	hl(0, "LineNr", { fg = c.dim_fg })
	hl(0, "CursorLineNr", { fg = c.bright_fg, bold = true })

	-- Syntax highlighting
	hl(0, "Comment", { fg = c.dim_fg, italic = true })
	hl(0, "String", { fg = c.green })
	hl(0, "Keyword", { fg = c.magenta, bold = true })
	hl(0, "Identifier", { fg = c.blue })
	hl(0, "Function", { fg = c.yellow })
	hl(0, "Type", { fg = c.cyan })
	hl(0, "Constant", { fg = c.red })
	hl(0, "Number", { fg = c.red })

	-- Search
	hl(0, "Search", { bg = c.bright_black, fg = c.bg })
	hl(0, "IncSearch", { bg = c.green, fg = c.bg })

	-- Diagnostics
	hl(0, "DiagnosticError", { fg = c.red })
	hl(0, "DiagnosticWarn", { fg = c.yellow })
	hl(0, "DiagnosticInfo", { fg = c.blue })
	hl(0, "DiagnosticHint", { fg = c.cyan })

	-- Statusline compatible (Lualine etc.)
	hl(0, "StatusLine", { fg = c.fg, bg = "#2B2B3A" })
	hl(0, "StatusLineNC", { fg = c.dim_fg, bg = c.bg })

	-- NvimTree git status colors - FILE highlight groups (used by nvim-tree)
	hl(0, "NvimTreeGitFileDirtyHL", { fg = c.yellow, bold = true }) -- Yellow for modified/unstaged (uncommitted)
	hl(0, "NvimTreeGitFileStagedHL", { fg = c.green, bold = true }) -- Green for staged (added)
	hl(0, "NvimTreeGitFileNewHL", { fg = c.blue, bold = true }) -- Blue for new/untracked
	hl(0, "NvimTreeGitFileRenamedHL", { fg = c.cyan, bold = true }) -- Cyan for renamed
	hl(0, "NvimTreeGitFileIgnoredHL", { fg = c.dim_fg }) -- Gray for ignored
	hl(0, "NvimTreeGitFileMergeHL", { fg = c.red, bold = true }) -- Red for merge conflicts (errors)

	-- NvimTree folder git status (same colors as files)
	hl(0, "NvimTreeGitFolderDirtyHL", { fg = c.yellow, bold = true })
	hl(0, "NvimTreeGitFolderStagedHL", { fg = c.green, bold = true })
	hl(0, "NvimTreeGitFolderNewHL", { fg = c.blue, bold = true })
	hl(0, "NvimTreeGitFolderRenamedHL", { fg = c.cyan, bold = true })
	hl(0, "NvimTreeGitFolderIgnoredHL", { fg = c.dim_fg })
	hl(0, "NvimTreeGitFolderMergeHL", { fg = c.red, bold = true })

	-- NvimTree modified files
	hl(0, "NvimTreeModifiedFile", { fg = c.yellow, bold = true })
	hl(0, "NvimTreeModifiedFolder", { fg = c.yellow, bold = true })

	-- NvimTree LSP diagnostic highlights
	hl(0, "NvimTreeDiagnosticErrorFileHL", { fg = c.red, bold = true }) -- Red for files with errors
	hl(0, "NvimTreeDiagnosticWarnFileHL", { fg = c.yellow, bold = true }) -- Yellow for warnings
	hl(0, "NvimTreeDiagnosticInfoFileHL", { fg = c.blue }) -- Blue for info
	hl(0, "NvimTreeDiagnosticHintFileHL", { fg = c.cyan }) -- Cyan for hints

	-- NvimTree folder diagnostic highlights
	hl(0, "NvimTreeDiagnosticErrorFolderHL", { fg = c.red, bold = true })
	hl(0, "NvimTreeDiagnosticWarnFolderHL", { fg = c.yellow, bold = true })
	hl(0, "NvimTreeDiagnosticInfoFolderHL", { fg = c.blue })
	hl(0, "NvimTreeDiagnosticHintFolderHL", { fg = c.cyan })

	-- Create autocommand to reapply NvimTree highlights when they might get reset
	vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "FileType" }, {
		pattern = "*",
		callback = function()
			-- Reapply nvim-tree git highlights to ensure they persist
			hl(0, "NvimTreeGitFileDirtyHL", { fg = c.yellow, bold = true })
			hl(0, "NvimTreeGitFileStagedHL", { fg = c.green, bold = true })
			hl(0, "NvimTreeGitFileNewHL", { fg = c.blue, bold = true })
			hl(0, "NvimTreeGitFileRenamedHL", { fg = c.cyan, bold = true })
			hl(0, "NvimTreeGitFileIgnoredHL", { fg = c.dim_fg })
			hl(0, "NvimTreeGitFileMergeHL", { fg = c.red, bold = true })

			hl(0, "NvimTreeGitFolderDirtyHL", { fg = c.yellow, bold = true })
			hl(0, "NvimTreeGitFolderStagedHL", { fg = c.green, bold = true })
			hl(0, "NvimTreeGitFolderNewHL", { fg = c.blue, bold = true })
			hl(0, "NvimTreeGitFolderRenamedHL", { fg = c.cyan, bold = true })
			hl(0, "NvimTreeGitFolderIgnoredHL", { fg = c.dim_fg })
			hl(0, "NvimTreeGitFolderMergeHL", { fg = c.red, bold = true })

			hl(0, "NvimTreeModifiedFile", { fg = c.yellow, bold = true })
			hl(0, "NvimTreeModifiedFolder", { fg = c.yellow, bold = true })

			-- Reapply diagnostic highlights
			hl(0, "NvimTreeDiagnosticErrorFileHL", { fg = c.red, bold = true })
			hl(0, "NvimTreeDiagnosticWarnFileHL", { fg = c.yellow, bold = true })
			hl(0, "NvimTreeDiagnosticInfoFileHL", { fg = c.blue })
			hl(0, "NvimTreeDiagnosticHintFileHL", { fg = c.cyan })

			hl(0, "NvimTreeDiagnosticErrorFolderHL", { fg = c.red, bold = true })
			hl(0, "NvimTreeDiagnosticWarnFolderHL", { fg = c.yellow, bold = true })
			hl(0, "NvimTreeDiagnosticInfoFolderHL", { fg = c.blue })
			hl(0, "NvimTreeDiagnosticHintFolderHL", { fg = c.cyan })
		end,
	})
end

return M
