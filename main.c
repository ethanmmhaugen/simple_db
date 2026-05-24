#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char* buffer;
    size_t buffer_size;
    ptrdiff_t input_size;
} InputBuffer;

InputBuffer* new_input_buffer() {
    InputBuffer* input_buffer = (InputBuffer*)malloc(sizeof(InputBuffer));
    input_buffer->buffer = NULL;
    input_buffer->buffer_size = 0;
    input_buffer->input_size = 0;

    return input_buffer;
}

void print_prompt() {
    return printf("db > ");
}

void read_input(InputBuffer* input_buffer) {
    ptrdiff_t bytes_read = getline(&(input_buffer->buffer), &(input_buffer->buffer_size), stdin);

    if(bytes_read <= 0) {
        printf("Error reading input\n");
        EXIT(EXIT_FAILURE);
    } else {
        input_buffer->input_size = bytes_read-1;
        input_buffer->buffer[bytes_read-1] = 0;
    }
}


int main(int argc, char* argv[]) {
    InputBuffer* input_buffer = new_input_buffer();

    while(true) {
        print_prompt();
        get_input(input_buffer);

        if(strcmp(input_buffer->buffer, ".exit") == 0) {
            close_input_buffer(input_buffer);
            exit(EXIT_SUCCESS);
        } else {
            printf("Unrecognized Command, '%s' .\n", input_buffer->buffer);
        }
    }
      
    return 0;
}