function! subtitles#mplayer#New()
  return {
        \ 'pipe':    tempname(),
        \ 'started': 0,
        \
        \ 'Start':         function('subtitles#mplayer#Start'),
        \ 'Pause':         function('subtitles#mplayer#Pause'),
        \ 'Stop':          function('subtitles#mplayer#Stop'),
        \ 'Seek':          function('subtitles#mplayer#Seek'),
        \ 'LoadSubtitles': function('subtitles#mplayer#LoadSubtitles'),
        \ 'Command':       function('subtitles#mplayer#Command'),
        \ }
endfunction

function! subtitles#mplayer#Start(video_file) dict
  call system('mkfifo '.self.pipe)
  call system('mplayer '.shellescape(a:video_file).' -slave -input file='.self.pipe.' &')

  let self.started = 1
endfunction

function! subtitles#mplayer#Seek(seconds) dict
  let seconds = string(a:seconds)
  call self.Command('seek '.seconds.' 2')
endfunction

function! subtitles#mplayer#Pause() dict
  call self.Command('pause')
endfunction

function! subtitles#mplayer#Stop() dict
  call self.Command('quit')
  let self.started = 0
endfunction

function! subtitles#mplayer#Command(command) dict
  return system('echo '.shellescape(a:command).' > '.self.pipe)
endfunction

function! subtitles#mplayer#LoadSubtitles(filename) dict
  call self.Command('sub_load '.a:filename)
endfunction
