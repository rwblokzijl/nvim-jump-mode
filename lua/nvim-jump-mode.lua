M = {}
local GN
M.setup = function (user_settings)
  local default_settings = {
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
      next = {},
      prev = {}
    }
  }
  local settings = vim.tbl_deep_extend("force", default_settings, user_settings)
  GN = {
    default_mode = settings.default_mode,
    jump_modes = settings.jump_modes,
    active_type  = settings.default_mode,
  }
  function GN:get_type (type_name)
    if type_name == nil then
      type_name = self.active_type
    end
    local type = vim.tbl_get(self.jump_modes, type_name)
    if type == nil then
      error("[GOTO NEXT] ERROR: '" .. type_name .. "' is not a configured type")
    end
    self.active_type = type_name
    return type
  end
  function GN:next(type_name)
    self:get_type(type_name).next_callback()
  end
  function GN:prev(type_name)
    self:get_type(type_name).prev_callback()
  end
  function GN:set_mode(type_name)
    self:get_type(type_name)
  end
  function GN:reset_mode()
    self:set_mode(self.default_mode)
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
  return GN.active_type
end

M.reset_mode = function()
  GN:reset_mode()
end

return M
