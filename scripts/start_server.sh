#!/bin/bash
cd /home/brian-vasquez/arma3server
tmux kill-session -t a3m_live 2>/dev/null
pkill -9 arma3server_x64
sleep 2

tmux new-session -d -s a3m_live 'stdbuf -o0 ./arma3server_x64 -port=2302 -config=/home/brian-vasquez/arma3server/server.cfg -cfg=/home/brian-vasquez/arma3server/basic.cfg -profiles=/home/brian-vasquez/arma3server/server_logs -name=a3m_Server -mod="@cba_a3;@ace3;@alive" -serverMod="@a3m_db_core" -autoInit -enableHT -world=empty -nosplash -noSound -filePatching 2>&1 | tee -a /home/brian-vasquez/arma3server/server_logs/arma3_live.log'
