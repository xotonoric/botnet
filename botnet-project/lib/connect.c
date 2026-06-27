#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "connect.h"
#include "utils.h"
#include "macros.h"

int init_channel(char *ip, int port, char *name) {
    char msg[CMD_LENGTH];
    struct sockaddr_in server;

    // Convert the ip to network byte order
    server.sin_addr.s_addr = inet_addr(ip);
    
    // Set the server's communications domain
    server.sin_family = AF_INET;
    
    // Convert port to network byte order
    server.sin_port = htons(port);

    // Define a SOCK_STREAM socket
    int channel = socket(AF_INET, SOCK_STREAM, 0);

    if(channel < 0) {
        perror("socket:");
        exit(1);
    }

    // Use the defined channel to connect the slave to the master server
    int connection_status = connect(channel, (struct sockaddr *)&server, sizeof(server));

    if (connection_status < 0) {
        perror("connect:");
        exit(1);
    }

    // Send a greeting message back to master
    snprintf(msg, CMD_LENGTH, "%s:ready", name);
    respond(channel, msg);
    
    return channel;
}
