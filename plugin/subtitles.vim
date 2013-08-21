if exists('g:loaded_subtitles') || &cp
  finish
endif

let g:loaded_subtitles = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

" TODO

let &cpo = s:keepcpo
unlet s:keepcpo
