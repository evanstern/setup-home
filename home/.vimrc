"
"   Evan Stern's (G)vimrc
"

" Use vim settings rather than vi (who uses vi anymore?)
set nocompatible

" Ensure that PYTHONPATH is not set (this is a problem with jedi-vim)
:let $PYTHONPATH = ""

" Pathogen {{{
" Infect ourselves with plugin goodness!
filetype off                    " Force reloading *after* pathogen is loaded
execute pathogen#infect()
call pathogen#helptags()
filetype plugin indent on       " Enable plugin/indenting detection
syntax enable                   " Use syntax coloring
" }}}

" Editing behavior {{{
set showmode                    " Show the current mode
set nowrap                      " Don't wordwrap, please.
set tabstop=4                   " Set tabs to 4 spaces
set softtabstop=4               " Allow deletion of the soft tabs
set expandtab                   " Expand tabs to spaces
set shiftwidth=4                " Set default tab to 4 (for auto-indenting)
set shiftround                  " Use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " Allow backspaces over everything
set autoindent                  " Auto indenting
set smartindent                 " Smart indentation (remembers previous indent)
set number                      " Line numbers are on by default
set smartcase                   " When searching, ignore case unless a capital
set smarttab                    " Insert tabs according to shiftwidth not tabstop
set scrolloff=5                 " Keep 5 lines off edges of screen during scroll
set virtualedit=all             " Allow cursor to go where it shouldn't
set nolist                      " Don't show hidden characters by default
set mouse=a                     " Allways enable the mouse
set nohlsearch                  " Do not highlight search strings
set incsearch                   " Show the best match 'so far' while searching
set formatoptions=crqn          " c = Auto-Wrap comments to 'textwidth'
                                " r = Insert current comment leader after <CR>
                                " q = Allow formatting of comments with 'gq
                                " n = Recognize numbered lists during formatting

" F12 puts you into 'paste mode' that will let you paste text from the buffer without it being
" autoindented. Super useful.
nnoremap <F12> :set invpaste paste?<CR>
set pastetoggle=<F12>

" Make scrolling a bit faster
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>
" }}}

" Folding behavior {{{
set foldenable                  " Enable folding by default
set foldcolumn=2                " Add a fold column
set foldmethod=marker           " Look for the tripple-{ and } markers
set foldlevel=99                " Fold it all by default

" what can trigger a fold to open?
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
" }}}

" Editor layout {{{
set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " Don't update the display while executing macros
set laststatus=2                " Show the status line always.
set cmdheight=1                 " Command bar of height 1 (default)

 " Set the ruler format
set rulerformat=%20(line-%l\ col-%c%V\ %p%%%)
" }}}

" Editor behavior {{{
colorscheme candy               " This is from the color-scheme-sample-pack plugin
set background=dark             " Use a dark background
set hidden                      " Don't close buffers. Preserve history
set switchbuf=useopen           " Use open files if you can
set history=1000                " Remember lots of history (we have the memory for it!)
set undolevels=1000             " I undo a *LOT* of stuff, so this is helpful
set nobackup                    " Backup files are annoying
set noswapfile                  " I don't think I have ever used one of these in my life.
set wildmenu                    " Use bash-like completion syntax for commandline stuff
set wildignore=*.swp,*.pyc      " Ignore these during autocompletion
set visualbell                  " Silence the bell sound, flash screen instead.
set showcmd                     " Show partial commands
set nomodeline                  " Do not allow other files to modify this one
set magic                       " Allow regex in search strings
set tags=./tags;
set ruler                       " Show the cursor position in the status bar
" }}}

" System specific {{{
" MSWIN is *true* if we are in a windows environment
let s:MSWIN = has("win16") || has("win32") || has("win64")
                \ || has("win95") || has("win32unix")

" If VI is running in a windows or unix/linux environment, then the
" default lookup paths for various things must change accordingly.
if s:MSWIN
    let s:Path = $VIMRUNTIME.'/'
else
    let s:Path = $HOME.'/.vim/'
endif
let $VIMSTORE=s:Path
let s:PluginPath = s:Path.'plugin/'

" The '.setwin.vim' file is used only in GVIM.  It is used to set the
" size and position of the window after it has been closed and
" re-opened.  Doing this allows the newly opened window to reposition
" itself to the same place as the last window.
let g:SetWin = s:Path.'.setwin.vim'

" GUI is *true* if we are in GVIM
let s:GUI = has("gui_running")

" AU will be *true* if this version of (G)VIM was compiled with the
" autocommand feature enabled.
let s:Au = has("autocmd")

" MENU will be *true* if this version of (G)VIM was compiled with
" support for the 'menu' feature
let s:Menu = has("menu")
" }}}

" Plugin Specific {{{
" Tlist
if s:MSWIN
    let Tlist_Ctags_Cmd='C:\\unix\\bin\\ctags.exe'
else
    let Tlist_Ctags_Cmd='/usr/bin/ctags'
endif
let Tlist_Display_Prototype= 1
let s:TagListOn = executable(Tlist_Ctags_Cmd)
noremap     <silent>    <F11>       <ESC><ESC>:Tlist<CR>
inoremap    <silent>    <F11>       <ESC><ESC>:Tlist<CR>

" NERDtree
noremap     <silent>    <LEADER>nt  <ESC><ESC>:NERDTreeToggle<CR>
" }}}

" Functions {{{
" SaveXY {{{
"======================================================================"
"                                                                      "
"      Function: SaveXY                                                "
"                                                                      "
"   Description: Creates or modifies a file called .setwin.vim which   "
"                contains commands to set GVIM's window's size and     "
"                position.                                             "
"                                                                      "
"======================================================================"
function! SaveXY()

    " Get the X and Y position of the window
    let x0=getwinposx()
    let y0=getwinposy()

    " Redirect the following command's output to the .setwin.vim file
    " by overwriting it (!).
    redir! > $VIMSTORE/setwin.vim
    silent echo "winpos" x0 y0
    silent echo "set lines=" . &lines
    silent echo "set columns=" . &columns
    redir END

endfunction
" }}}

" Filetype Specific {{{
if s:Au
    augroup filetype

        " Remove trailing whitespace
        autocmd BufWritePre * :%s/\s\+$//e

        " Text Files
        autocmd BufRead *.txt set textwidth=72

        " PSQL temp files
        autocmd BufRead,BufNewFile *\.edit\.* set filetype=sql

        " Perl Files
        autocmd BufRead *.pl
                \ vmap <silent> <F9> :s/^.\\|^$/#\ /g<CR> |
                \ vmap <silent> <F10> :s/\(^\ *\)#/\1/g<CR>

        " Python Files
        autocmd FileType python let PYTHONPATH='/usr/lib/python2.5'
        autocmd FileType python inoremap <Nul> <C-x><C-o>
        autocmd FileType python set formatoptions=cqro
        autocmd FileType python set textwidth=79
        autocmd Filetype python set tabstop=4

        " Set XHTML on turbogears .kid files
        autocmd BufRead,BufNewFile *.kid
                \ setfiletype xhtml |
                \ set fo-=c

        " Vim Files
        autocmd BufRead,BufNewFile *.vim set comments=fb:-,:\"
        autocmd BufRead,BufNewFile *.vim set textwidth=78

        " Javascript
        autocmd BufRead,BufNewFile *.js set ft=javascript syntax=javascript
        autocmd BufRead,BufNewFile *.js set comments=sr:/*,mb:*,ex:*/,://

        " JSON files
        autocmd BufRead, BufNewFile *.json set ft=javascript syntax=javascript

        " Make sure that there fo does not have the t option
        autocmd Filetype * set fo-=t

        " RST files
        autocmd FileType rst
            \ set formatoptions=want |
            \ set textwidth=82 |
            \ set nowrap

    augroup END

    " Jump to the last cursor position when opening a new buffer
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g'\"" |
        \ endif
endif
" }}}

" Useful mappings {{{
nmap <Leader>s :source $MYVIMRC <CR>
nmap <Leader>e :vsplit $MYVIMRC <CR>
vmap sb "zdi<b><C-R>z</b><ESC>
vmap sdi "zdi<div><C-R>z</div><ESC>
vmap ssp "zdi<span><C-R>z</span><ESC>
vmap scc "zdi<!--<C-R>z--><ESC>
"inoremap <Leader>d <ESC>:r! date +\%m/\%d/\%Y\ \%H:\%M <CR>i
" }}}

" Entry and Exit {{{
"" When GVIM is exited, call SaveXY() and when GVIM is entered into again
"" read the .setwin.vim file and execute the commands to set the window
"" back to the correct position again.
if s:Au && s:GUI
    autocmd VimLeave * call SaveXY()
    autocmd VimEnter * if filereadable( $VIMSTORE."/setwin.vim" )
                     \ | source $VIMSTORE/setwin.vim
                     \ | endif
endif
" }}}
" }}}
