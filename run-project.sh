#!/usr/bin/env zsh
mkdir balls
rm balls/*.png
julia ./main.jl
ffmpeg -y -pattern_type glob -i 'balls/*.png' -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4
ffmpeg -y -i out.mp4 -vf "fps=30" -loop 0 out.gif