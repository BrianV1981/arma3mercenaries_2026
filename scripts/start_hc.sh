#!/bin/bash
cd /home/brian-vasquez/arma3server
tmux kill-session -t a3m_hc1 2>/dev/null
sleep 2

tmux new-session -d -s a3m_hc1 'stdbuf -o0 ./arma3server_x64 -client -connect=127.0.0.1 -port=2302 -profiles=/home/brian-vasquez/arma3server/server_logs -name=alanon -mod="@cba_a3;@ace3;@alive" -nosplash -noSound -filePatching 2>&1 | tee -a /home/brian-vasquez/arma3server/server_logs/arma3_hc1.log'
