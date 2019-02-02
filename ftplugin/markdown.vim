lua << END_LUA

local function extract_link(line, col)
  local link_end = string.find(line, ")", col, true)
  if link_end == nil then
    print("It's not a link")
    return nil
  end

  return string.match(string.sub(line, 1, link_end), "%[[^%[%]]*%]%(([^%(%)]*)%)$")
end

function follow_link()
  local cur_win = vim.api.nvim_get_current_win()
  local col = vim.api.nvim_win_get_cursor(cur_win)[2]
  local line = vim.api.nvim_get_current_line()

  local link_path = extract_link(line, col)
  if link_path == nil then
    return
  end

  if string.match(link_path, "^%a+://") ~= nil then
    os.execute(string.format("xdg-open %s &> /dev/null", link_path))
  else
    if string.match(link_path, "^/") ~= nil then
      vim.api.nvim_command(string.format("edit %s", link_path))
    else
      vim.api.nvim_command(string.format("edit %%:p:h/%s", link_path))
    end
  end
end

function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local res = string.match(line, "%[([ x])%]")
  if res == nil then
    return
  end

  if res == 'x' then
    line = string.gsub(line, "%[x%]", "[ ]", 1)
  else
    line = string.gsub(line, "%[ %]", "[x]", 1)
  end

  vim.api.nvim_set_current_line(line)
end

END_LUA

autocmd FileType markdown nnoremap <script> <CR> :lua follow_link()<CR>
autocmd FileType markdown nnoremap <script> <Space> :lua toggle_checkbox()<CR>
