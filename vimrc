" vim startup script without dependencies. Useful together with sudovi

" {{{1 wat algemene dingen
let did_install_default_menus=1
let did_install_syntax_menu=1

set modelines=0
set nomodeline

set laststatus=2
set statusline=%<%F\ %h%m%r%=%-14.(%l,%c%V%)\ %P

function! InsertStatuslineColor(mode)
  if a:mode == 'i'
    highlight StatusLine ctermfg=magenta ctermbg=Black
  elseif a:mode == 'r'
    highlight StatusLine ctermfg=red ctermbg=Black
  else
    highlight StatusLine ctermfg=Cyan ctermbg=Black
  endif
endfunction

au InsertEnter * call InsertStatuslineColor(v:insertmode)
au InsertChange * call InsertStatuslineColor(v:insertmode)
au InsertLeave * call InsertStatuslineColor('')

" default the statusline when entering Vim
highlight StatusLine    ctermfg=Cyan ctermbg=Black
highlight StatusLineNC  ctermfg=DarkBlue ctermbg=Cyan

highlight CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
" highlight CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
nnoremap <Leader>c :set cursorline!<CR>

set wrap
set linebreak
set nolist
set textwidth=70
set wrapmargin=0

" ----------------------------------------------------
" See http://vim.wikia.com/wiki/Move_cursor_by_display_lines_when_wrapping
noremap <silent> <Leader>w :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Wrap OFF"
    setlocal nowrap
    set virtualedit=all
    silent! nunmap <buffer> <Up>
    silent! nunmap <buffer> <Down>
    silent! nunmap <buffer> <Home>
    silent! nunmap <buffer> <End>
    silent! iunmap <buffer> <Up>
    silent! iunmap <buffer> <Down>
    silent! iunmap <buffer> <Home>
    silent! iunmap <buffer> <End>
  else
    echo "Wrap ON"
    setlocal wrap linebreak nolist
    set virtualedit=
    setlocal display+=lastline
    noremap  <buffer> <silent> <Up>   gk
    noremap  <buffer> <silent> <Down> gj
    noremap  <buffer> <silent> <Home> g<Home>
    noremap  <buffer> <silent> <End>  g<End>
    inoremap <buffer> <silent> <Up>   <C-o>gk
    inoremap <buffer> <silent> <Down> <C-o>gj
    inoremap <buffer> <silent> <Home> <C-o>g<Home>
    inoremap <buffer> <silent> <End>  <C-o>g<End>
  endif
endfunction

onoremap <silent> j gj
onoremap <silent> k gk

function! NoremapNormalCmd(key, preserve_omni, ...)
  let cmd = ''
  let icmd = ''
  for x in a:000
    let cmd .= x
    let icmd .= "<C-\\><C-O>" . x
  endfor
  execute ":nnoremap <silent> " . a:key . " " . cmd
  execute ":vnoremap <silent> " . a:key . " " . cmd
  if a:preserve_omni
    execute ":inoremap <silent> <expr> " . a:key . " pumvisible() ? \"" . a:key . "\" : \"" . icmd . "\""
  else
    execute ":inoremap <silent> " . a:key . " " . icmd
  endif
endfunction

" Cursor moves by screen lines
call NoremapNormalCmd("<Up>", 1, "gk")
call NoremapNormalCmd("<Down>", 1, "gj")
call NoremapNormalCmd("<Home>", 0, "g<Home>")
call NoremapNormalCmd("<End>", 0, "g<End>")

" PageUp/PageDown preserve relative cursor position
call NoremapNormalCmd("<PageUp>", 0, "<C-U>", "<C-U>")
call NoremapNormalCmd("<PageDown>", 0, "<C-D>", "<C-D>")
" ----------------------------------------------------

set incsearch
set nocompatible
set formatoptions-=t
set formatoptions-=c
set breakat=\ \	!@*-+_;:,./?
set showbreak=->
set clipboard=unnamed
set noinsertmode
set nohidden
set nowrapscan
set ignorecase
set smartcase
set so=2
set lazyredraw
set selectmode=mouse,key
set backspace=2
set dictionary=
set tabstop=2
" set expandtab
set autoindent
set smartindent
set writebackup
set backup
set backupext=.bak
set history=100
set showmode
set maxmemtot=65536
set ch=1
set sw=2
set ls=2
set number
set mh
set viminfo='20,\"50,n~/.viminfo
set ruler
set visualbell
set clipboard=unnamed
set hlsearch
set showmatch
set shortmess=at
set cmdheight=2
set splitbelow
nmap <Insert> i
set wildignore=*.obj,*.exe,*.bak,*.jpg,*.png,*.gif
au BufReadCmd *.epub call zip#Browse(expand("<amatch>"))
syntax on
" 1}}}
" {{{1 utf-8
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  "setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif
" 1}}}
" {{{1 locaties
set dir=~/.tmp,~/tmp,/tmp
set backupdir=~/.tmp,~/tmp,/tmp
" 1}}}
" {{{1 versie 6 dingen
set foldmethod=marker
if version >= 600
  if has("gui")
    set foldcolumn=0
  endif
  set foldtext=FoldText()
  function FoldText()
    let line = getline(v:foldstart)
    let sub = substitute(line, '/\*\|\*/\|{{\d\=', '', 'g')
    return v:folddashes . sub
  endfunction
endif
" 1}}}
" {{{1 mappings
" spring naar indent boven en onder
map <F2> :call GoDown()<cr>
map <F3> :call GoUp()<cr>
" kopieer het resterende deel van bovenstaande regel
imap <F5> x<BS><Esc>:call CopyAbove("line")<Return>a
" opmaak regel
map <F4> <Home>gq<End>
" voeg datum / datum + user in
map  'd a<C-R>=strftime("%Y%m%d %H:%M :")<CR><Esc>i
map  'v O<C-R>=strftime("\# %Y%m%d %H:%M " ).expand($LOGNAME) . ": "<CR><Esc>a
" spellcheck
map  'e :w!<CR>:!aspell check --lang=en %<CR>:e! %<CR>
map  'n :w!<CR>:!aspell check --lang=nl %<CR>:e! %<CR>
" wissel naar volgende screenbuffer
nmap <Tab> <C-W>w
" copy
vmap <F7> "+ygv"zy`>
" paste (Shift-F7 to paste after normal cursor, Ctrl-F7 to paste over visual selection)
nmap <F7> "zgP
nmap <S-F7> "zgp
imap <F7> <C-r><C-o>z
vmap <C-F7> "zp`]
cmap <F7> <C-r><C-o>z
"copy register
autocmd FocusGained * let @z=@+
" 1}}}
function! CopyAbove(what) " {{{1
  if line(".") == 1
    return
  endif
  let CurPos = col(".")
  let LineLength = strlen(getline("."))
  normal! ma
  normal! kmb$
  if col(".") <= CurPos
    normal! `a
  else
    normal! `b
    if LineLength > 0
      normal l
    endif
    if a:what == "word"
      normal! vwhy`ap
    else
      normal! v$hy`ap
    endif
  endif
  unlet LineLength
  unlet CurPos
endfunction " 1}}}
function! GoDown() " {{{1
  while line(' ')<line('$')
    norm jyl
    if @"!=' '
      return
    endif
  endwhile
endfunction " 1}}}
function! GoUp() " {{{1
  while line(' ')<line('$')
    norm kyl
    if @"!=' '
      return
    endif
  endwhile
endfunction " 1}}}
function! DoPrettyXML() " {{{1
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML() " 1}}}
" {{{1 terminal kleuren
if $TRANSPARANT == "true"
  " leuk voor transparante terminals met een lichte achtergrond
  set background=light
  highlight Normal        ctermfg=Black
  highlight Statement     ctermfg=DarkBlue
  highlight Error         cterm=bold ctermfg=Red ctermbg=Yellow
  highlight Todo          cterm=bold ctermfg=Red ctermbg=Yellow
  highlight Cursor        ctermbg=Red ctermfg=White
  highlight ModeMsg       ctermfg=DarkGrey
  highlight Number        ctermfg=DarkGreen
  highlight String        ctermfg=DarkBlue
  highlight Identifier    ctermfg=Blue
  highlight Function      ctermfg=DarkBlue
  highlight Comment       ctermfg=DarkCyan
  highlight Repeat        ctermfg=DarkRed
  highlight Conditional   ctermfg=DarkRed
  highlight Define        ctermfg=DarkMagenta
  highlight LineNr        ctermfg=DarkCyan
  highlight NonText       ctermfg=DarkCyan
  highlight SpecialKey    ctermfg=DarkCyan
  highlight Einde         ctermbg=DarkCyan
  highlight DiffAdd       term=reverse cterm=bold ctermbg=green ctermfg=white
  highlight DiffChange    term=reverse cterm=bold ctermbg=blue ctermfg=white
  highlight DiffText      term=reverse cterm=bold ctermbg=DarkCyan ctermfg=white
  highlight DiffDelete    term=reverse cterm=bold ctermbg=red ctermfg=white
else
  set background=light
  highlight Normal        ctermfg=Black ctermbg=white
  highlight Statement     ctermfg=DarkBlue ctermbg=white
  highlight Error         cterm=bold ctermfg=Red ctermbg=Yellow
  highlight Todo          cterm=bold ctermfg=Red ctermbg=Yellow
  highlight Cursor        ctermbg=DarkBlue ctermfg=White
  highlight ModeMsg       ctermfg=DarkGrey ctermbg=white
  highlight Number        ctermfg=DarkGreen ctermbg=white
  highlight String        ctermfg=DarkBlue ctermbg=white
  highlight Identifier    ctermfg=Blue ctermbg=white
  highlight Function      ctermfg=DarkBlue ctermbg=white
  highlight Comment       ctermfg=DarkCyan ctermbg=white
  highlight Repeat        ctermfg=DarkRed ctermbg=white
  highlight Conditional   ctermfg=DarkRed ctermbg=white
  highlight Define        ctermfg=DarkMagenta ctermbg=white
  highlight LineNr        ctermfg=DarkCyan ctermbg=White
  highlight NonText       ctermfg=DarkCyan ctermbg=White
  highlight SpecialKey    ctermfg=DarkCyan ctermbg=White
  highlight Einde         ctermbg=DarkCyan ctermbg=White
  highlight DiffAdd       term=reverse cterm=bold ctermbg=green ctermfg=white
  highlight DiffChange    term=reverse cterm=bold ctermbg=blue ctermfg=white
  highlight DiffText      term=reverse cterm=bold ctermbg=DarkCyan ctermfg=white
  highlight DiffDelete    term=reverse cterm=bold ctermbg=red ctermfg=white
endif
" na 72 kolommen regeleinde aangeven
match Einde /\%72v/
" 1}}}
" {{{1 gui settings en kleuren
set guifont=Monospace\ 8
" Remove menu bar
set guioptions-=m
" Remove toolbar
set guioptions-=T
highlight Normal        guifg=Black
highlight Error         gui=bold guifg=Red
highlight Todo          gui=bold guifg=Red
highlight Cursor        guibg=DarkBlue guifg=White
" highlight StatusLine    guifg=DarkBlue
" highlight StatusLineNC  guifg=DarkGrey
highlight ModeMsg       guifg=DarkGrey
highlight Number        guifg=SeaGreen
highlight String        guifg=DarkCyan
highlight Identifier    guifg=Blue
highlight Function      guifg=DarkBlue
highlight Comment       guifg=DarkGrey
highlight Repeat        guifg=DarkRed
highlight Conditional   guifg=DarkRed
highlight Define        guifg=DarkMagenta
highlight LineNr        guifg=Grey
highlight NonText       guifg=Grey
highlight SpecialKey    guifg=Grey
highlight Einde         guibg=Cyan
match Einde /\%72v/
" 1}}}
" {{{1 smileys highlighten
syn match smiley "(:[-^]?[][)(><}{|/DP])"
highlight smiley guifg=magenta guibg=green
" 1}}}

