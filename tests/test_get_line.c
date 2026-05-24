#include <stdio.h>
#include <stdlib.h>
#include "../custom_get_line.c"

int main() {
    char* buffer = NULL;
    size_t size = 0;

    ptrdiff_t bytes_read = custom_get_line(&buffer, &size, stdin);

    printf("Allocated size: '%zu', Bytes read: '%td'\n", size, bytes_read);
    for(int i = 0; i < bytes_read; i++) {
        printf("%c", buffer[i]);
    }

    free(buffer);
    return 0;
}
