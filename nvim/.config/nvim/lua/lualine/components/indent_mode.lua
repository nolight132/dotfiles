local M = {}

--- @brief Gets the current indentation mode and width.
--- @return string A string representing the indentation mode, e.g., "Spaces: 2" or "Tabs: 8".
function M.get_indent_mode()
	-- 'expandtab' is true when spaces are used for indentation.
	local expandtab = vim.opt.expandtab:get()

	-- Get 'tabstop' value: number of spaces a tab character occupies.
	local tabstop = vim.opt.tabstop:get()

	-- Get 'shiftwidth' value: number of spaces used for each step of (auto)indent.
	local shiftwidth = vim.opt.shiftwidth:get()

	if expandtab then
		-- If 'expandtab' is true, we are using spaces for indentation.
		-- The effective width is determined by 'shiftwidth'.
		return "Spaces: " .. shiftwidth
	else
		-- If 'expandtab' is false, we are using tab characters for indentation.
		-- The effective width is determined by 'tabstop'.
		return "Tabs: " .. tabstop
	end
end

-- Return the function that LuaLine will call to get the component's text.
return M.get_indent_mode
