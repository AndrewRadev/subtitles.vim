let b:player = subtitles#mplayer#New()

" TODO (2013-04-22) Reload subtitles in mplayer

command! -nargs=1 -complete=file Play call s:Play(<f-args>)
function! s:Play(video)
  call b:player.Start(a:video)
  call b:player.LoadSubtitles(expand('%'))
endfunction

nnoremap <buffer> <c-p> call b:player.Pause()

let b:current_time_string = ''
let b:current_time        = -1

let s:time_pattern = '\v(\d\d):(\d\d):(\d\d),(\d\d\d) --\> (\d\d):(\d\d):(\d\d),(\d\d\d)$'

augroup subtitles
  autocmd!
  autocmd CursorMoved <buffer> call s:UpdateTime()
  autocmd BufWrite <buffer> call b:player.LoadSubtitles(expand('%'))
augroup END

command! -buffer -nargs=1 Shift call s:Shift(<f-args>)
function! s:Shift(amount)
  for line in getbufline('%', 0, '$')
    if getline(line) =~ s:time_pattern
      let [start_time, end_time] = s:Times(getline(line))

      let start_s  = float2nr(start_time)
      let end_s    = float2nr(end_time)
      let start_ms = float2nr((start_time - start_s) * 1000)
      let end_ms   = float2nr((end_time - end_s) * 1000)

      let start_s += str2nr(a:amount)
      let end_s   += str2nr(a:amount)

      let new_time_string = ''
      let new_time_string .=
            \ printf("%02d", start_s / 3600).':'.
            \ printf("%02d", start_s / 60).':'.
            \ printf("%02d", float2nr(fmod(start_s, 60))).','.
            \ printf("%03d", start_ms)
      let new_time_string .= ' --> '
      let new_time_string .= printf("%02d", end_s / 3600).':'.
            \ printf("%02d", end_s / 60).':'.
            \ printf("%02d", float2nr(fmod(end_s, 60))).','.
            \ printf("%03d", end_ms)

      call setline(line, new_time_string)
    endif
  endfor
endfunction

function! s:UpdateTime()
  let pattern     = s:time_pattern
  let time_lineno = search(pattern, 'Wbcn')

  if time_lineno <= 0
    return
  endif

  let time_line = getline(time_lineno)

  if time_line == b:current_time_string
    return
  endif

  let b:current_time_string = time_line
  let [b:current_time, _]   = s:Times(time_line)

  call b:player.Seek(b:current_time)
  call b:player.LoadSubtitles(expand('%'))
endfunction

function! s:Times(time_string)
  let [_, start_h, start_m, start_s, start_ms, end_h, end_m, end_s, end_ms, _] = matchlist(a:time_string, s:time_pattern)

  let start_time = 0
  let start_time += str2nr(start_h) * 3600
  let start_time += str2nr(start_m) * 60
  let start_time += str2nr(start_s)
  let start_time += str2nr(start_ms) * 0.001

  let end_time = 0
  let end_time += str2nr(end_h) * 3600
  let end_time += str2nr(end_m) * 60
  let end_time += str2nr(end_s)
  let end_time += str2nr(end_ms) * 0.001

  return [start_time, end_time]
endfunction
