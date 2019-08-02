import subprocess

region = 'PR'
site = 'QS'


cmd = 'ffmpeg -y -i ' + 'wav_files/'+region+'_'+site+'_'+'Multitrack_mixdown.wav' + '  -i ' + 'mp4_files/Only_Video/'+region+'_'+site+'_'+'GPP_animation.mp4' + '  -filter:a aresample=async=1 -c:a flac -c:v copy ' + 'mp4_files/'+region+'_'+site+'_complete_animation.mkv'
subprocess.call(cmd, shell=True)                                     # "Muxing Done
print('Muxing Done')
