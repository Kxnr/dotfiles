" set runtimepath^=~/.vim runtimepath+=~/.vim/amarket
" let &packpath=&runtimepath

set nocompatible
set modeline
set modelines=10
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"Plugins
" vim plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-repeat'
Plugin 'morhetz/gruvbox'

" Dependencies of other plugins
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-tree/nvim-web-devicons'
Plugin 'MunifTanjim/nui.nvim'

" nvim plugins
Plugin 'nvim-neo-tree/neo-tree.nvim'
Plugin 'lukas-reineke/indent-blankline.nvim'
Plugin 'kylechui/nvim-surround'
Plugin 'numToStr/Comment.nvim'
Plugin 'nvim-lualine/lualine.nvim'
Plugin 'ibhagwan/fzf-lua'
Plugin 'nvim-treesitter/nvim-treesitter'
Plugin 'nvim-treesitter/nvim-treesitter-textobjects'
Plugin 'ray-x/cmp-treesitter'
Plugin 'Vigemus/iron.nvim'
Plugin 'ggandor/leap.nvim'
Plugin 'ggandor/flit.nvim'
Plugin 'neovim/nvim-lspconfig'
Plugin 'hrsh7th/nvim-cmp'
Plugin 'hrsh7th/cmp-buffer'
Plugin 'hrsh7th/cmp-path'
Plugin 'hrsh7th/cmp-nvim-lsp-signature-help'
Plugin 'hrsh7th/cmp-emoji'
Plugin 'hrsh7th/vim-vsnip'
Plugin 'hrsh7th/vim-vsnip-integ'
Plugin 'hrsh7th/cmp-vsnip'
Plugin 'hrsh7th/cmp-nvim-lsp'
Plugin 'akinsho/bufferline.nvim'
Plugin 'rafamadriz/friendly-snippets'
Plugin 'danymat/neogen'
Plugin 'Pocco81/auto-save.nvim'
Plugin 'windwp/nvim-autopairs'
" Plugin 'glepnir/template.nvim'
Plugin 'salkin-mada/openscad.nvim'
Plugin 'mfussenegger/nvim-dap'
Plugin 'mfussenegger/nvim-dap-python'
Plugin 'rcarriga/nvim-dap-ui'
Plugin 'lervag/wiki.vim'
Plugin 'kevinhwang91/nvim-bqf'
Plugin 'jmbuhr/otter.nvim'
"End Plugins

call vundle#end()
filetype plugin indent on

" special xml and json filetypes
au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
au FileType json setlocal equalprg=jq
" End Vundle setup


" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if executable(s:clip)
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif


" stock vim options
nnoremap <SPACE> <Nop>
let mapleader=" "
syntax on
let signcolumn = 1
let updatetime = 250
set lazyredraw

let g:wiki_root = '~/wiki'

nnoremap ; :
vnoremap ; :
nnoremap : ;
vnoremap : ;

" csv plugin
let g:csv_delim=','

" options for vim indent guides
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1

" split bindings
set splitright
set splitbelow
nnoremap <leader>\ :vs<CR>
nnoremap <leader>- :split<CR>

nnoremap <leader>j <C-W>j
nnoremap <leader>k <C-W>k
nnoremap <leader>l <C-W>l
nnoremap <leader>h <C-W>h

" buffer bindings
let switchbuf="useopen"
let bclose_multiple = 0
nnoremap <leader>bl :ls<CR>:b<Space>
nnoremap <leader>b <C-^>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
cnoremap wd w\|bd

" colors!
set background=dark
set termguicolors
colorscheme gruvbox
hi clear SpellBad
hi clear SpellCap
hi clear SpellRare
hi clear SpellLocal 
hi SpellBad cterm=underdotted ctermbg=Red gui=underdotted guibg=Red guisp=Red
hi SpellCap cterm=underdotted ctermbg=Red gui=underdotted guibg=Red guisp=Red
hi SpellRare cterm=underdotted ctermbg=Green gui=underdotted guibg=Green guisp=Green
hi SpellLocal cterm=underdotted ctermbg=Blue gui=underdotted guibg=Blue guisp=Blue

nnoremap <silent> <Leader>sp :setlocal spell! spelllang=en_us<CR>

" create light grey ruler at col 80
set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=darkcyan

" make numbers hybrid
set number
set relativenumber

" delete without overwrite
noremap <leader>d "_d
noremap <leader>D "_D

" copy paste from copy register
noremap <leader>y "+y
noremap <leader>p "+p

" search options
set ignorecase
set smartcase

set showmatch
set incsearch
set hlsearch

nnoremap <leader>/ :nohlsearch<CR>

set backspace=indent,eol,start
set autoindent
set laststatus=2
set hidden

" indent options
set shiftwidth=2
set softtabstop=2
set expandtab

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldcolumn=1

" wrapping and wrap motion 
set wrap
set linebreak
set breakindent
set listchars=tab:.\ ,trail:_,extends:>,precedes:<,nbsp:~
set list

nnoremap j gj
nnoremap k gk
nnoremap 0 g0
nnoremap $ g$
nnoremap ^ g^

nnoremap gj j
nnoremap gk k
  
nnoremap g0 0
nnoremap g$ $
nnoremap g^ g

" make cursor stick to center with line
" centering replaced by knowing shortcuts: use zz, zt, and zb to center, top,
" and bottom current line
set cursorline

" move code blocks with Alt 
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

tnoremap <Esc> <C-\><C-n>

set textwidth=100
set formatoptions+=coqn1jr
set formatoptions-=t

" set markdown language fencing
let g:markdown_fenced_languages = ['bash=sh', 'javascript', 'js=javascript', 'json=javascript', 'typescript', 'ts=typescript', 'php', 'html', 'css', 'rust', 'sql', 'py=python', 'python']

" enable markdown folding, toggle headings with za, zR & zM toggle all
let g:markdown_folding = 1

" all folds start open, and bold/italic syntax hidden in markdown buffers
augroup markdown
  au FileType markdown setlocal syntax=markdown
  au FileType markdown setlocal foldlevel=99
  au FileType markdown setlocal conceallevel=2
  au FileType markdown setlocal textwidth=100
  au FileType markdown setlocal shiftwidth=2
augroup END
