#include "wasm_component.h"

void exports_wasm_component_name(wasm_component_string_t *ret) {
    wasm_component_string_set(ret, "mul_c");
}

char* int_to_str(int value, char* buffer) {
    int i = 0;
    int is_negative = 0;

    if (value == 0) {
        buffer[i++] = '0';
        buffer[i] = '\0';
        return buffer;
    }

    if (value < 0) {
        is_negative = 1;
        value = -value;
    }

    while (value != 0) {
        buffer[i++] = (value % 10) + '0';
        value /= 10;
    }

    if (is_negative) {
        buffer[i++] = '-';
    }

    buffer[i] = '\0';

    int start = 0;
    int end = i - 1;
    while (start < end) {
        char temp = buffer[start];
        buffer[start] = buffer[end];
        buffer[end] = temp;
        start++;
        end--;
    }

    return buffer;
}

int32_t exports_wasm_component_process(int32_t a, int32_t b) {
    char message[100];
    char a_str[20];
    char b_str[20];

    int_to_str(a, a_str);
    int_to_str(b, b_str);

    int pos = 0;
    const char* prefix = "multiplying ";
    for (int i = 0; prefix[i]; i++) {
        message[pos++] = prefix[i];
    }

    for (int i = 0; a_str[i]; i++) {
        message[pos++] = a_str[i];
    }

    const char* middle = " by ";
    for (int i = 0; middle[i]; i++) {
        message[pos++] = middle[i];
    }

    for (int i = 0; b_str[i]; i++) {
        message[pos++] = b_str[i];
    }

    message[pos] = '\0';

    wasm_component_string_t log_message;
    wasm_component_string_set(&log_message, message);
    nve_wasm_component_host_log(&log_message);

    return a * b;
}