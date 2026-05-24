#include <stdio.h>
#include <stdlib.h>

ptrdiff_t custom_get_line(char** input_buffer, size_t* size, FILE* stream) {
    if(*size == 0) {
        *size = 1024;
        *input_buffer = malloc(*size);
    }

    size_t pos = 0;
    int c;

    while((c = fgetc(stream)) != EOF) {
        if(pos + 1 >= *size) {
            *size += 1024;
            *input_buffer = realloc(*input_buffer, *size);
        }

        (*input_buffer)[pos++] = c;

        if(c == '\n') {
            (*input_buffer)[pos] = '\0';
            return pos;
        }
    }

    return -1;
}
