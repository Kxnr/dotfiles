vim.cmd('source /home/kxnr/.config/nvim/vim_bindings.vim')
vim.cmd('nnoremap <leader>r :luafile $MYVIMRC<CR>')

vim.g.python3_host_prog = "/home/kxnr/.venv/base/bin/python3"

require('nvim-treesitter.configs').setup({ensure_installed = "all", highlight = { enable = true}})
require('plenary.async')
require('leap')
require('fzf-lua').setup({"default"})
local iron = require('iron.core')

require('lspconfig').pyright.setup({})
require('lspconfig').pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        ruff = {
          enabled = True
        }
      }
    }
  }
})
require('workspaces').setup()
require('codeium').setup({})
require('neogen').setup({ snippet_engine = "vsnip" })
require('auto-save').setup({
  trigger_events = {
    "InsertLeave",
    "TextChanged",
    "FocusLost"
  },
  debounce_delay = 1000
})

  -- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local servers = {'pylsp', 'pyright'}
for _, lsp in ipairs(servers) do
  require('lspconfig')[lsp].setup({
    capabilities = capabilities
  })
end

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
    { name = 'codeium' },
    { name = 'buffer' },
    { name = "treesitter" },
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
    scratch_repl = true,
    repl_definition = {
      python = {
        command = {"python"},
      },
      repl_open_cmd = require("iron.view").right('30%'),
    }
  }
})

vim.keymap.set('n', '<leader><leader>py', '<cmd>IronFocus<CR>')

vim.cmd([[set completeopt=menu,menuone,noselect,preview]])
vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = True, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = True, silent = true })

vim.keymap.set("n", "<leader><C-f>", "<cmd>lua require('fzf-lua').files()<CR>", { noremap = True, silent = true })
vim.keymap.set("n", "<leader><C-S-f>", "<cmd>lua require('fzf-lua').grep_project()<CR>", { noremap = True, silent = true })

