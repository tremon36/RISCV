#include <stdio.h>
#include <stdlib.h>

#define ISR_BASE_ADDRESS 8000
#define DATA_BASE_ADDRESS 115200

int main(int argc, char** argv) {

    if(argc != 5) {
        printf("Syntax Error: link <.text file> <.ISR file > <.data file> <executable_name>\n");
        return 1;
    }

    FILE* text;
    FILE* data;
    FILE* isr;
    FILE* executable;

    text = fopen(argv[1],"rb");
    isr = fopen(argv[2],"rb");
    data = fopen(argv[3],"rb");

    executable = fopen(argv[4],"wb");

    char text_bin[65536];
    char data_bin[65536];
    char isr_bin[65536];

    int read = 0;
    u_int32_t text_bytes = 0; // number of bytes of text segment
    u_int32_t data_bytes = 0; // number of bytes of data segment
    u_int32_t isr_bytes = 0;

    // read text segment file
    while(read != EOF){
        read = fgetc(text);
        if(read != EOF) {
            text_bin[text_bytes] = (char)read;
            text_bytes++;
        }
    }
    fclose((text));

    // read data segment file
    read = 0;
    while(read != EOF){
        read = fgetc(data);
        if(read != EOF){
            data_bin[data_bytes] = (char)read;
            data_bytes++;
        }
    }
    fclose(data);

    // read ISR segment file
    read = 0;
    while(read != EOF){
        read = fgetc(isr);
        if(read != EOF){
            isr_bin[isr_bytes] = (char)read;
            isr_bytes++;
        }
    }
    fclose(isr);

    // First 12 bytes of the executable are address limits of segments.

    u_int32_t text_limit_address = text_bytes - 1;
    u_int32_t data_limit_address = data_bytes + DATA_BASE_ADDRESS - 1;
    u_int32_t isr_limit_address = isr_bytes + ISR_BASE_ADDRESS - 1;

    fwrite(&text_limit_address,1,sizeof(u_int32_t),executable);
    fwrite(&isr_limit_address,1,sizeof (u_int32_t),executable);
    fwrite(&data_limit_address,1,sizeof(u_int32_t),executable);

    // Next is the text segment

    fwrite(text_bin,1,text_bytes,executable);

    // Then the ISR segment

    fwrite(isr_bin,1,isr_bytes,executable);

    // And finally the data segment

    fwrite(data_bin,1,data_bytes,executable);

    fclose(executable);
    return 0;
}
