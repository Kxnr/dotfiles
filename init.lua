vim.cmd('source /home/kxnr/.config/nvim/vim_bindings.vim')
vim.cmd('nnoremap <leader>r :luafile $MYVIMRC<CR>')

vim.g.python3_host_prog = "/home/kxnr/.venv/base/bin/python3"

-- workaround for slow plugins: https://github.com/neovim/neovim/issues/23725
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
   -- disable lsp watcher. Too slow on linux
   wf._watchfunc = function()
     return function() end
   end
end

require('nvim-treesitter.configs').setup({highlight = { enable = true}})
require('plenary.async')
require('leap')
require('flit').setup()
require('fzf-lua').setup({"default"})
local iron = require('iron.core')

require('auto-save').setup({
  trigger_events = {
    "InsertLeave",
    "TextChanged",
    "FocusLost"
  },
  debounce_delay = 5000
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_cfg = require('lspconfig')
lsp_cfg.pylsp.setup({
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        jedi_completion = {
          enabled = true,
          include_class_objects = true,
          include_function_objects = true,
          fuzzy = true,
        },
        ruff = {
          enabled = true,
        },
	mypy = {
	  enabled = true,
          dmypy = true,
          live_mode = false,
          strict = true,
	},
	black = {
	  enabled = true,
	},
        isort = {
          enabled = true,
        },
        rope_autoimport = {
          enabled = true
        },
      }
    }
  }
})
lsp_cfg.svelte.setup({
  capabilities = capabilities,
})


local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args) vim.fn["vsnip#anonymous"](args.body) end
  },
  sources = {
    { name = 'nvim_lsp' }, 
    { name = 'vsnip' }, 
    { name = 'treesitter' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'cmdline' },
    { name = 'emoji' },
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    },
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#jumpable"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, {"i", "s"}),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, {"i", "s"}),
  },
})

require("bufferline").setup()

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    -- keymaps = {
    --   init_selection = '<c-space>',
    --   node_incremental = '<c-space>',
    --   scope_incremental = '<c-s>',
    --   node_decremental = '<M-space>',
    -- },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

iron.setup({
  config =  {
    repl_open_cmd = require("iron.view").split.vertical(.3),
    scratch_repl = true,
    repl_definition = {
      python = {
        command = {"ipython"},
      },
    }
  }
})

require("neogen").setup({
  snippet_engine = "vsnip",
  languages = {
    python = {
      template = {
        annotation_convention = "reST",
        position = "after"
      }
    }
  }
})
require("nvim-autopairs").setup()
require("illuminate").configure()
-- require("template").setup({
--   temp_dir = "/home/kxnr/templates"
-- })
require('openscad').setup({})


vim.keymap.set('n', '<leader>repl', '<cmd>IronFocus<CR>')

vim.cmd([[set completeopt=menu,menuone,noselect,preview]])
vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true})

vim.api.nvim_set_keymap("n", "<leader><S-f>", "<cmd>lua require('fzf-lua').files()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader><C-f>", "<cmd>lua require('fzf-lua').live_grep()<CR>", { noremap = true, silent = true })

-- https://github.com/fatih/vim-go/issues/1757
-- open quickfix full width
vim.cmd "autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1) | wincmd J | endif"

vim.api.nvim_set_keymap("n", "<Leader>ng", "<cmd>Neogen", {noremap = true, silent=true})

-- init bi-directional search with <leader><leader>
-- TODO: should this be <leader>/, to match the logic of flit?
-- the current is based on easymotion's default.
vim.keymap.set("n", "<leader><leader>", function ()
  local current_window = vim.fn.win_getid()
  require('leap').leap { target_windows = { current_window } }
end)
vim.api.nvim_set_keymap("n", "<leader>qf", "<cmd>lua vim.diagnostic.setqflist()<CR>", { noremap = true, silent = true })
