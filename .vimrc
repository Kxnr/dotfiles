" Vundle setup
set nocompatible
set modeline
set modelines=10
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vimwiki/vimwiki'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'easymotion/vim-easymotion'
Plugin 'tomtom/tcomment_vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'fneu/breezy'
Plugin 'morhetz/gruvbox'
Plugin 'chrisbra/csv.vim'
Plugin 'christoomey/vim-tmux-navigator'
" End Plugins

call vundle#end()
filetype plugin indent on
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

nnoremap ; :
vnoremap ; :
nnoremap : ;
vnoremap : ;

" switch vimwiki to markdown
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext = 0

" Open new vimwiki diary pages with a template
" https://frostyx.cz/posts/vimwiki-diary-template
au BufNewFile ~/vimwiki/diary/*.md :silent 0r !~/.vim/bin/generate-vimwiki-diary-template '%'

" csv plugin
let g:csv_delim=','

" options for vim indent guides
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1

" options for you complete me, specific to each machine
let g:ycm_path_to_python_interpreter = '/home/kxnr/.venv/vim/bin/python'

" split bindings
nnoremap <leader>\ :vs<CR>
nnoremap <leader>- :split<CR>

nnoremap <leader>j <C-W><C-J>
nnoremap <leader>k <C-W><C-K>
nnoremap <leader>l <C-W><C-L>
nnoremap <leader>h <C-W><C-H>

" buffer bindings
let switchbuf="useopen"
nnoremap <leader>bl :ls<CR>:b<Space>
nnoremap <leader>b <C-^>

" tab bindings
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tm :tabmove
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>to :tabonly<CR>

" open file
" TODO: open in tab/split/current window
" nnoremap <leader>t
" nnoremap <leader>e
" nnoremap <leader>w\
" nnoremap <leader>w-

" NERDTree mappings
nnoremap <leader>nt :NERDTreeToggle<CR>

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
let g:airline_theme='breezy'
let g:airline_powerline_fonts = 1

" create light grey ruler at col 80
set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=darkcyan

" make numbers hybrid
set number
set relativenumber


" delete without overwrite
noremap <leader>d "_d
noremap <leader>D "_D
noremap <leader>p "0p
noremap <leader>P "0P

" yank to copy register
noremap <leader>y "+y

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


" fold by indent, and manual
augroup vimrc
  au BufReadPre * setlocal foldmethod=indent
  au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
augroup END
set foldenable
set foldlevelstart=10
set foldnestmax=10  
set foldcolumn=1


" wrapping and wrap motion 
set wrap
set linebreak
set nolist
" set textwidth=100
set listchars=tab:.\ ,trail:_,extends:>,precedes:<,nbsp:~

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
nnoremap <C-J> :m .+1<CR>==
nnoremap <C-K> :m .-2<CR>==
vnoremap <C-J> :m '>+1<CR>gv=gv
vnoremap <C-K> :m '<-2<CR>gv=gv

" Easy reload
nnoremap <leader>r :source $MYVIMRC<CR>
