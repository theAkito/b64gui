#!/bin/bash

# Windows
nimble fbuild && \
strip b64gui.exe && \
mv b64gui.exe /mnt/c/Users/Akito/Desktop/b64gui.exe

# Linux amd64
nim c \
  --define:danger \
  --opt:speed \
  --app:gui \
  --out:b64gui \
  src/b64gui && \
strip b64gui && \
mv b64gui /mnt/c/Users/Akito/Desktop/b64gui_linux_x64