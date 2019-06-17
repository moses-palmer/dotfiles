" Let :W save with sudo
command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!
