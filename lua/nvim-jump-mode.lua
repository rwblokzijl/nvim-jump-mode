M = {}
local GN
M.setup = function (user_settings)
  local default_settings = {
    open_fold_on_jump = true,
    center_line_on_jump = true,
    mappings = {
      next = {
        { modes = {'n'}, key = "n" }
      },
      prev = {
        { modes = {'n'}, key = "N" }
      },
      leader_next = {
        { modes = {'n'}, key = "gn" }
      },
      leader_prev = {
        { modes = {'n'}, key = "gp" }
      },
    },
    jump_modes = {
      search = {
        next_callback = function () vim.cmd 'silent! norm! n' end,
        prev_callback = function () vim.cmd 'silent! norm! N' end,
      },
    },
    default_mode = "search",
  }
  local jump_mode_default = {
    mappings = {
      pass_history = false,
      next = {},
      prev = {}
    }
  }
  local settings = vim.tbl_deep_extend("force", default_settings, user_settings)
  GN = {
    default_mode = settings.default_mode,
    jump_modes = settings.jump_modes,
    active_mode  = settings.default_mode,
    history = {}
  }
  function GN:set_active_mode(mode_name)
    self.active_mode = mode_name
    self.history = {}
  end
  function GN:get_mode (mode_name)
    local mode = vim.tbl_get(self.jump_modes, mode_name)
    if mode == nil then
      error("[GOTO NEXT] ERROR: '" .. mode_name .. "' is not a configured mode")
    end
    return mode
  end
  function GN:get_history(mode)
    if mode.pass_history == true then
      return self.history
    else
      return nil
    end
  end
  function GN:jump(mode_name, callback_name)
    if mode_name == nil then
      mode_name = self.active_mode
    else
      self:set_active_mode(mode_name)
    end
    local mode = self:get_mode(mode_name)
    local history = self:get_history(mode)
    if history == nil then
      self:get_mode(mode_name)[callback_name]()
    else
      self.history = self:get_mode(mode_name)[callback_name](history)
    end
    if settings.open_fold_on_jump then
      vim.cmd 'silent! norm! zv'
    end
    if settings.center_line_on_jump then
      vim.cmd 'silent! norm! zz'
    end
  end
  function GN:prev(mode_name)
    self:jump(mode_name, "prev_callback")
  end
  function GN:next(mode_name)
    self:jump(mode_name, "next_callback")
  end
  function GN:reset_mode()
    self:set_active_mode(self.default_mode)
  end

  -- keybinds
  for _, mapping in ipairs(settings.mappings.next) do
    vim.keymap.set(mapping.modes, mapping.key, function()GN:next()end, {noremap = true, silent = true})
  end
  for _, mapping in ipairs(settings.mappings.prev) do
    vim.keymap.set(mapping.modes, mapping.key, function()GN:prev()end, {noremap = true, silent = true})
  end
  for name, jump_mode_user in pairs(GN.jump_modes) do
    local jump_mode = vim.tbl_deep_extend("force", jump_mode_default , jump_mode_user)
    if vim.tbl_get(jump_mode, "mode_leader") ~= nil then
      for _, leader in ipairs(settings.mappings.leader_next) do
        vim.keymap.set(leader.modes, leader.key .. jump_mode.mode_leader , function()GN:next(name)end, {noremap = true, silent = true})
      end
      for _, leader in ipairs(settings.mappings.leader_prev) do
        vim.keymap.set(leader.modes, leader.key .. jump_mode.mode_leader , function()GN:prev(name)end, {noremap = true, silent = true})
      end
    end
    for _, mapping in ipairs(jump_mode.mappings.next) do
      vim.keymap.set(mapping.modes, mapping.key, function()GN:next(name)end, {noremap = true, silent = true})
    end
    for _, mapping in ipairs(jump_mode.mappings.prev) do
      vim.keymap.set(mapping.modes, mapping.key, function()GN:prev(name)end, {noremap = true, silent = true})
    end
  end

  vim.api.nvim_create_user_command("NextModeReset", function()GN:reset_mode()end, {})

  return GN
end

M.mode = function ()
  return GN.active_mode
end

M.reset_mode = function()
  GN:reset_mode()
end

return M
