vim.opt.swapfile = false
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Icons (must load before neo-tree/bufferline)
  { "nvim-tree/nvim-web-devicons", lazy = false, config = true },

  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = { width = 30 },
        filesystem = {
          filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = true },
          follow_current_file = { enabled = true },
        },
      })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP + Mason
  { "williamboman/mason.nvim", config = true },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "intelephense" },
        automatic_installation = true,
        automatic_enable = false,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(keys, cmd) vim.keymap.set("n", keys, cmd, { buffer = bufnr, silent = true }) end
          map("gd",         vim.lsp.buf.definition)
          map("gr",         vim.lsp.buf.references)
          map("K",          vim.lsp.buf.hover)
          map("<leader>rn", vim.lsp.buf.rename)
          map("<leader>ca", vim.lsp.buf.code_action)
          map("<leader>f",  function() vim.lsp.buf.format({ async = true }) end)
        end,
      })

      vim.lsp.enable({ "ts_ls", "intelephense" })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
        },
      })
    end,
  },

  -- Claude Code integration
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a",  nil,                              desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v", desc = "Send selection" },
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>",     desc = "Add file", ft = { "neo-tree" } },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
    },
  },

  -- Fuzzy file finder
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        winopts = { height = 0.6, width = 0.6, preview = { layout = "vertical" } },
      })
    end,
    keys = {
      { "<leader>p",  "<cmd>FzfLua files<cr>",     desc = "Find files" },
      { "<leader>fn", "<cmd>FzfLua files<cr>",     desc = "Search filenames" },
      { "<leader>fc", "<cmd>FzfLua live_grep<cr>", desc = "Search file contents" },
      { "<leader>sb", "<cmd>FzfLua buffers<cr>",   desc = "Find buffers" },
    },
  },

  -- Buffer tab bar
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          offsets = {
            { filetype = "neo-tree", text = "Files", highlight = "Directory", separator = true }
          },
        },
      })
    end,
  },
})

-- Open neo-tree automatically on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("neo-tree.command").execute({ action = "show" })
    vim.cmd("wincmd l")
  end,
})

vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true })

-- <leader>/ opens the reference menu popup (same as Prefix+/ in tmux)
vim.keymap.set("n", "<leader>/", function()
  local dotfiles = vim.fn.getenv("XDG_CONFIG_HOME")
  vim.fn.jobstart(
    "tmux display-popup -E -w 80% -h 80% " .. dotfiles .. "/tmux/tmux-menu.sh",
    { detach = true }
  )
end, { silent = true, desc = "Reference menu" })
