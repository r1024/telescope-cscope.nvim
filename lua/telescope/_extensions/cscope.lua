local conf = require("telescope.config").values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local utils = require "telescope.utils"

local load_cscope_db = 0

local function check_cscope_db()
  if load_cscope_db == 0 then
    local cscope_db = vim.fn.findfile("cscope.out", ".;")
    if cscope_db == "" then
      utils.notify("builtin.cscope", { msg = "Not found valid cscope db.", level = "ERROR" })
      return ""
    end
  end

  load_cscope_db = 1
  local cscope_db = vim.fn.findfile("cscope.out", ".;")
  vim.cmd("silent! cscope add " .. cscope_db)
  vim.go.cscopequickfix = "s-,c-,d-,i-,t-,e-,a-"
  vim.go.cscopeverbose = false
  return "ok"
end

local function cscope_fn(opts, querytype, name, title)
  local status_ok = check_cscope_db()
  if not status_ok then
    return
  end

  vim.fn.setqflist({})
  vim.cmd("normal! mY")
  vim.cmd("execute 'cs find " .. querytype .. " " .. name .. "'")
  vim.cmd("cclose")
  if querytype ~= "g" then
    vim.cmd("normal! `Y")
  end

  local qf_identifier = opts.id or vim.F.if_nil(opts.nr, "$")
  local locations = vim.fn.getqflist({ [opts.id and "id" or "nr"] = qf_identifier, items = true }).items
  if vim.tbl_isempty(locations) then
    return
  end

  pickers.new(opts, {
    prompt_title = title .. " (" .. name .. ")",
    finder = finders.new_table {
      results = locations,
      entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
    },
    previewer = conf.qflist_previewer(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

local function goto_definition(opts)
  local name = vim.fn.expand "<cword>"
  if name == "" then
    return
  end
  cscope_fn(opts, "g", name, "Find definition")
end

local function list_this_symbol(opts)
  local name = vim.fn.expand "<cword>"
  if name == "" then
    return
  end
  cscope_fn(opts, "s", name, "List symbol")
end

local function list_calling(opts)
  local name = vim.fn.expand "<cword>"
  if name == "" then
    return
  end
  cscope_fn(opts, "d", name, "List symbol")
end

local function list_called(opts)
  local name = vim.fn.expand "<cword>"
  if name == "" then
    return
  end
  cscope_fn(opts, "c", name, "List symbol")
end

local function refresh_cscope_db()
  -- find . -name "*.h" -o -name "*.c" -o -name "*.cc" > cscope.files
  -- vim.fn.execute('!cscope -bkq -i cscope.files', 'silent')
  --
  -- local cscope_db = vim.fn.findfile("cscope.out", ".;")
  -- vim.cmd("silent! cscope add " .. cscope_db)
  -- vim.go.cscopequickfix = "s-,c-,d-,i-,t-,e-,a-"
  -- vim.go.cscopeverbose = false
end

return require('telescope').register_extension {
  exports = {
    refresh_cscope_db = refresh_cscope_db,
    goto_definition = goto_definition,
    list_this_symbol = list_this_symbol,
    list_calling = list_calling,
    list_called = list_called,
  }
}
