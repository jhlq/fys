//compile with gcc knappi.c -lncurses -o knappi
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <ncurses.h>
#include <stdlib.h>
 
char* readfile(char* fn){
    char *buffer=NULL;
    int string_size, read_size;
    FILE *handler=fopen(fn,"r");
    if (handler){
        fseek(handler,0,SEEK_END);
        string_size=ftell(handler);
        rewind(handler);
        buffer=(char*) malloc(sizeof(char)*(string_size+1));
        read_size=fread(buffer,sizeof(char),string_size,handler);
        buffer[string_size]='\0';
        fclose(handler);
    }
    return buffer;
}
char* usbdir(char* dir){
    FILE *f=popen("mount | grep /dev/sda1","r");
    if (EOF==fgetc(f)){
        printf("No usb memory found.\r\n");
        dir[0]='\0';
    } else {
        int spaces=0;
        int diri=0;
        while (1){
            int co=fgetc(f);
            if (spaces==2){
                dir[diri]=co;
                diri++;
            }
            if (co==' '){
                spaces++;
                if (spaces>2){
                    break;
                }
            }
        }
        dir[diri-1]='\0';
    }
    pclose(f);
    return dir;
}
int main( ) {
    initscr();
    //raw();
    keypad(stdscr, TRUE);
    noecho();
    refresh();
    char buttons[]="12345678";
    char* labels[8]={
        [0]="coming: worst",
        [1]="coming: okay",
        [2]="coming: good",
        [3]="coming: best",
        [4]="going: worst",
        [5]="going: okay",
        [6]="going: good",
        [7]="going: best"
    };
    int c;
    //setbuf(stdout,NULL); //better to fflush
    puts("Press q to quit, c to copy file to usb, v to view current buttons, s to set buttons and e to eject usb memory.\r\n");
    while (1){
        c=getch();
        if (c=='q'){
            printf("Quitting.\n");
            break;
        } else if (c=='c'){
            printf("Copying... ");
            char dir[100];
            usbdir(dir);
            if (dir[0]!='\0'){
                char* b=readfile("tryckningar.txt");
                FILE *usbf=fopen(strcat(dir,"/tryckningar.txt"),"w");
                fprintf(usbf,"%s",b);
                fclose(usbf);
                free(b);
                printf("Copied to usb memory at %s.\r\n",dir);
            }
            continue;
        } else if (c=='v'){
            printf("The current buttons are: %s\r\n",buttons);
        } else if (c=='s'){
            for (int i=0;i<strlen(buttons);i++){
                printf("Set button for \"%s\" (do not use special characters like ö): ",labels[i]);
                fflush(stdout);
                char bu=getch();
                putchar(bu);
                printf("\r\n");
                buttons[i]=bu;
            }
            printf("The current buttons are: %s\r\n",buttons);
        } else if (c=='e'){
            char dir[100];
            usbdir(dir);
            if (dir[0]!='\0'){
                char cmd[255]="sudo eject ";
                FILE *f=popen(strcat(cmd,dir),"r");
                pclose(f);
                printf("Ejected usb memory.\r\n");
            }
        }
        for (int i=0;i<strlen(buttons);i++){
            if (buttons[i]==c){
                struct tm* local;
                time_t seconds=time(NULL);
                local=localtime(&seconds);
                char* t=asctime(local);
                t[strlen(t)-1]=0;
                //char* str;
                //asprintf(str,"%s, %s\r\n",t,labels[i]);
                printf("%s, %s\r\n",t,labels[i]);
                FILE *tryck=fopen("tryckningar.txt","a");
                fprintf(tryck,"%s, %s\r\n",t,labels[i]);
                fclose(tryck);
                char dir[100];
                usbdir(dir);
                if (dir[0]!='\0'){
                    FILE *usbf=fopen(strcat(dir,"/tryckningar.txt"),"a");
                    fprintf(usbf,"%s, %s\r\n",t,labels[i]);
                    fclose(usbf);
                }
            }
        }
    }
    endwin();
    return 0;
}
