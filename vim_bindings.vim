" set runtimepath^=~/.vim runtimepath+=~/.vim/amarket
" let &packpath=&runtimepath

set nocompatible
set modeline
set modelines=10
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"Plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'vimwiki/vimwiki'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'tomtom/tcomment_vim'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'morhetz/gruvbox'
Plugin 'chrisbra/csv.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ibhagwan/fzf-lua'
Plugin 'tpope/vim-fugitive'
Plugin 'nvim-treesitter/nvim-treesitter'
Plugin 'nvim-treesitter/nvim-treesitter-textobjects'
Plugin 'Vigemus/iron.nvim'
Plugin 'ggandor/leap.nvim'
Plugin 'ggandor/flit.nvim'
Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'neovim/nvim-lspconfig'
Plugin 'hrsh7th/nvim-cmp'
Plugin 'hrsh7th/cmp-nvim-lsp'
Plugin 'hrsh7th/cmp-buffer'
Plugin 'hrsh7th/cmp-path'
Plugin 'hrsh7th/cmp-nvim-lsp-signature-help'
Plugin 'hrsh7th/cmp-emoji'
Plugin 'hrsh7th/vim-vsnip'
Plugin 'hrsh7th/vim-vsnip-integ'
Plugin 'hrsh7th/cmp-vsnip'
Plugin 'nvim-tree/nvim-web-devicons'
Plugin 'akinsho/bufferline.nvim'
Plugin 'rafamadriz/friendly-snippets'
Plugin 'danymat/neogen'
Plugin 'Pocco81/auto-save.nvim'
Plugin 'windwp/nvim-autopairs'
Plugin 'RRethy/vim-illuminate'
Plugin 'glepnir/template.nvim'
Plugin 'salkin-mada/openscad.nvim'
Plugin 'tpope/vim-repeat'
Plugin 'mfussenegger/nvim-dap'
Plugin 'mfussenegger/nvim-dap-python'
Plugin 'rcarriga/nvim-dap-ui'
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

nnoremap ; :
vnoremap ; :
nnoremap : ;
vnoremap : ;

" switch vimwiki to markdown
let g:vimwiki_list = [{
	\ 'path': '~/vimwiki/',
	\ 'template_path': '~/vimwiki/templates/',
	\ 'template_default': 'default',
	\ 'syntax': 'markdown',
	\ 'ext': '.md',
	\ 'path_html': '~/vimwiki/site_html/',
	\ 'custom_wiki2html': 'vimwiki_markdown',
	\ 'template_ext': '.tpl',
        \ 'auto_toc': 1,
        \ 'diary_frequency': 'weekly',
        \ 'cycle_bullets': 1,
        \ 'auto_diary_index': 1}]
let g:vimwiki_global_ext = 0

" Open new vimwiki diary pages with a template
" https:"frostyx.cz/posts/vimwiki-diary-template
au BufNewFile ~/vimwiki/diary/*.md :silent 0r !~/.vim/bin/generate-vimwiki-diary-template '%'

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
cnorea wd w\|bd

" NERDTree mappings
nnoremap <leader>nt :NERDTreeFocus<CR>
nnoremap <leader>ntt :NERDTreeToggle<CR>
nnoremap <leader>ntc :NERDTreeClose<CR>
nnoremap <leader>ntf :NERDTreeFind<CR>

" colors!
set background=dark
set termguicolors
colorscheme gruvbox
hi clear SpellBad
hi clear SpellCap
hi clear SpellRare
hi clear SpellLocal 
hi SpellBad cterm=underline ctermfg=red
hi SpellCap cterm=underline ctermfg=red
hi SpellRare cterm=underline ctermfg=green
hi SpellLocal cterm=underline ctermfg=blue

nnoremap <silent> <Leader>sp :setlocal spell! spelllang=en_us<CR>

" background toggle
nnoremap <silent> <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" airline
let g:airline_theme='gruvbox'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 0

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

" move code blocks with Ctrl
nnoremap <A-J> :m .+1<CR>==
nnoremap <A-K> :m .-2<CR>==
vnoremap <A-J> :m '>+1<CR>gv=gv
vnoremap <A-K> :m '<-2<CR>gv=gv

tnoremap <Esc> <C-\><C-n>

let g:minimap_width = 10
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1

nnoremap <silent> <leader>dn :lua require('dap-python').test_method()<CR>
nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
vnoremap <silent> <leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>
