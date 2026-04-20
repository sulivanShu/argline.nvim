local M = {}

function M.test_fonction()
	print("test_fonction ok")
end

function M.new_tab()
	vim.cmd.tabedit()
	vim.cmd.arglocal()
	vim.cmd.argdelete({ "*" })
end

function M.autocmd()
	local group = vim.api.nvim_create_augroup("auto_argadd", { clear = true })
	local function absolute(name)
		return vim.loop.fs_realpath(name) or vim.fn.fnamemodify(name, ":p")
	end
	vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
		group = group,
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			-- check if buftype is normal (not help, terminal, etc.)
			if vim.bo[buf].buftype ~= "" then
				return
			end
			-- check if bufname is not empty
			local name = vim.api.nvim_buf_get_name(buf)
			if name == "" then
				return
			end
			local abs_name = absolute(name)
			local argc = vim.fn.argc()
			local argset = {}
			for i = 0, argc - 1 do
				local abs_arg = absolute(vim.fn.argv(i))
				argset[abs_arg] = true
			end
			if argset[abs_name] then
				return
			end
			vim.cmd.argedit(name)
			vim.cmd.args()
		end,
	})
end

function M.next_or_first()
	if vim.fn.argc() == 0 then
		vim.notify("Nothing in the arglist", vim.log.levels.INFO)
		return
	end
	local i = vim.fn.argidx()
	local last = vim.fn.argc() - 1
	if i < last then
		vim.cmd.next()
	else
		vim.cmd.first()
	end
	vim.cmd.args()
end

function M.previous_or_last()
	if vim.fn.argc() == 0 then
		vim.notify("Nothing in the arglist", vim.log.levels.INFO)
		return
	end
	local i = vim.fn.argidx()
	if i > 0 then
		vim.cmd.previous()
	else
		vim.cmd.last()
	end
	vim.cmd.args()
end

function M.previous_or_first()
	if vim.fn.argc() == 0 then
		vim.notify("Nothing in the arglist", vim.log.levels.INFO)
		return
	end
	local i = vim.fn.argidx()
	if i > 0 then
		vim.cmd.previous()
	else
		vim.cmd.first()
	end
	vim.cmd.args()
end

function M.remove_arg()
	local win = vim.api.nvim_get_current_win()
	local ok, removed = pcall(vim.api.nvim_win_get_var, win, "removed_args")
	if not ok then
		removed = {}
	end
	if vim.fn.argc() > 1 then
		local name = vim.fn.bufname()
		table.insert(removed, name)
		vim.cmd.argdelete(name)
		M.previous_or_first()
		vim.cmd.args()
		vim.api.nvim_win_set_var(win, "removed_args", removed)
	else
		vim.notify("Last arg, type ZZ to close the window", vim.log.levels.INFO)
	end
end

function M.restore_arg()
	local win = vim.api.nvim_get_current_win()
	local ok, removed = pcall(vim.api.nvim_win_get_var, win, "removed_args")
	if not ok or #removed == 0 then
		return
	end
	local last = removed[#removed]
	vim.cmd.argedit(last)
	vim.cmd.args()
	table.remove(removed)
	vim.api.nvim_win_set_var(win, "removed_args", removed)
end

function M.args_or_empty()
	if vim.fn.argc() == 0 then
		vim.notify("Nothing in the arglist", vim.log.levels.INFO)
		return
	end
	vim.cmd.args()
end

return M
