#ifndef UTILS_H
#define UTILS_H

int respond(int s, char *msg_buf);
int receive(int s, char *msg);
int parse(int s, char *msg, char* name);
int execute(int s, char *cmd);
char* alias_img();

#endif
