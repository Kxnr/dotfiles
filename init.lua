vim.cmd('source /home/kxnr/.config/nvim/vim_bindings.vim')
vim.cmd('nnoremap <leader>r :luafile $MYVIMRC<CR>')

vim.g.python3_host_prog = "/home/kxnr/.venv/base/bin/python3"

-- workaround for slow plugins: https:--github.com/neovim/neovim/issues/23725
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
require('leap-spooky').setup()
require('flit').setup()
require('fzf-lua').setup({"default"})
require('dapui').setup()
require('ibl').setup()
require('lualine').setup()
require('Comment').setup()
require('nvim-surround').setup()
require('bqf').setup()

dap_python = require('dap-python')
dap_python.setup()
dap_python.test_runner = 'pytest'

local iron = require('iron.core')
require('auto-save').setup({
  trigger_events = {
    "InsertLeave",
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
        },
        rope_autoimport = {
          enabled = true
        }
      }
    }
  }
})

lsp_cfg.svelte.setup({
  capabilities = capabilities,
})

lsp_cfg.marksman.setup({})
lsp_cfg.rust_analyzer.setup( {
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = "clippy";
      },
      diagnostics = {
        enable = false;
      }
    }
  }
})

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require('cmp')
cmp.setup({
  preselect = cmp.PreselectMode.None,
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
      if vim.fn["vsnip#jumpable"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, {"i", "s"}),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if vim.fn["vsnip#jumpable"](-1) == 1 then
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
require('openscad').setup({})

vim.keymap.set('n', '<leader>repl', '<cmd>IronFocus<CR>')
vim.keymap.set('n', '<leader>dap', function() require("dapui").toggle() end)
vim.keymap.set('n', '<Leader>br', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>pytest', function() require('dap-python').test_method() end)
vim.keymap.set('n', '<Leader>dbg', function() require('dap').continue() end)


vim.keymap.set('n', '<Leader>nt', '<cmd>Neotree position=current toggle=true<CR>')
vim.keymap.set('n', '<Leader>nf', '<cmd>Neotree position=current reveal=true toggle=true<CR>')

vim.cmd([[set completeopt=menu,menuone,noselect,preview]])
vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end)
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end)
vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end)
vim.keymap.set({"n", "v"}, "<leader>ca", function() vim.lsp.buf.code_action() end)
vim.keymap.set({"n", "v"}, "<leader>ff", function() vim.lsp.buf.format() end)

vim.keymap.set("n", "<leader><S-f>", function() require('fzf-lua').files({ multiprocess = True }) end)
vim.keymap.set("n", "<leader><C-f>", function() require('fzf-lua').live_grep_glob({ multiprocess = True }) end)
vim.keymap.set("n", "<leader><A-f>", function() require('fzf-lua').lgrep_curbuf({ multiprocess = True }) end)
vim.keymap.set('n', '<Leader>ws', function() require('fzf-lua').files({cwd = '~/wiki'}) end)

-- https:--github.com/fatih/vim-go/issues/1757
-- open quickfix full width
vim.cmd "autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1) | wincmd J | endif"

vim.keymap.set("n", "<Leader>ng", ":Neogen")

-- init bi-directional search with <leader><leader>
-- TODO: should this be <leader>/, to match the logic of flit?
-- the current is based on easymotion's default.
vim.keymap.set("n", "<leader><leader>", function ()
  local current_window = vim.fn.win_getid()
  require('leap').leap { target_windows = { current_window } }
end)

vim.keymap.set("n", "<leader>ll", function() vim.diagnostic.setloclist() end)

local fzf = require "fzf-lua"
local fzf_data = require "fzf-lua".config.__resume_data

local function fzf_pages()
  fzf.files({
    prompt = "Wiki files>",
    cwd = vim.g.wiki_root,
    actions = {
      ['default'] = function(selected)
        local note = selected[1]
        if not note then
          if fzf_data.last_query then
            note = fzf_data.last_query
          end
        end
        print(note)
        local file = require('fzf-lua').path.entry_to_file(note).path
        vim.fn["wiki#page#open"](file)
      end,
    }
  })
end

local function fzf_tags()
  local tags_with_locations = vim.fn["wiki#tags#get_all"]()
  local root = vim.fn["wiki#get_root"]()
  local items = {}
  for tag, locations in pairs(tags_with_locations) do
    for _, loc in pairs(locations) do
      local path = vim.fn["wiki#paths#relative"](loc[1], root)
      local str = string.format("%s:%d:%s", tag, loc[2], path)
      table.insert(items, str)
    end
  end
  fzf.fzf_exec(items, {
    actions = {
      ['default'] = function(selected)
        local note = vim.split(selected[1], ':')[3]
        if note then
          vim.fn["wiki#page#open"](note)
        end
      end
    }
  })
end

local function fzf_toc()
  local toc = vim.fn["wiki#toc#gather_entries"]()
  local items = {}
  for _, hd in pairs(toc) do
    local indent = vim.fn["repeat"](".", hd.level - 1)
    local line = indent .. hd.header
    table.insert(items, string.format("%d:%s", hd.lnum, line))
  end
  fzf.fzf_exec(items, {
    actions = {
      ['default'] = function(selected)
        local ln = vim.split(selected[1], ':')[1]
        if ln then
          vim.fn.execute(ln)
        end
      end
    }
  })
end

vim.g.wiki_select_method = {
  pages = fzf_pages,
  tags = fzf_tags,
  toc = fzf_toc,
}

vim.g.wiki_journal = {
  name = 'journal',
  frequency='weekly',
  date_format= {
    daily = '%Y-%m-%d',
    weekly = '%Y_w%V',
    monthly = '%Y_m%m',
 },
}

