#include "pgn.h"
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <ctype.h>

%%{
    machine pgn;

    action start_str {
        buf_len = 0;
    }

    action finish_str {
        if (buf_len >= buf_size) {
            buf_size += 1024;
            buf = realloc(buf, buf_size);
        }
        *(buf + buf_len++) = '\0';
    }

    action str_char {
        if (buf_len >= buf_size) {
            buf_size += 1024;
            buf = realloc(buf, buf_size);
        }
        *(buf + buf_len++) = fc;
    }

    action start_tp {
        tp = malloc(sizeof(tag_pair));
        tp->next = NULL;
        if (tags->start == NULL) {
            tags->start = tp;
        }

        if (tags->end != NULL) {
            tags->end->next = tp;
        }
        tags->end = tp;
    }

    action tag_name {
        /* tag_name max length is 255 characters */
        strncpy(tp->name, buf, 256);
        tp->name[255] = '\0';
    }

    action finish_tp {
        tp->value = malloc(buf_len);
        strncpy(tp->value, buf, buf_len);
    }

    symbol_cont = ( alnum | '_' | '+' | '#' | '=' | ':' | '-' ) >str_char;
    symbol = (alnum >str_char symbol_cont*) >start_str %finish_str;

    str_char = [^"] >str_char;
    string = ('"' str_char* '"') >start_str %finish_str;

    tag_name = symbol %tag_name;

    tag_pair = ('[' space* tag_name space* string space* ']') >start_tp %finish_tp;

    main := tag_pair ( space* tag_pair )*;
}%%

%% write data;

typedef struct tag_pair_t {
    char name[256];
    char *value;
    struct tag_pair_t *next;
} tag_pair;

typedef struct {
    tag_pair *start;
    tag_pair *end;
} tag_list;

void pgn_parse(char *p) {
    const char *pe = p + strlen(p);
    const char *eof = pe;
    int cs = 0;

    char symbol[256];
    char *symp = symbol;
    char *buf = malloc(1024);
    size_t buf_len = 0, buf_size = 1024;
    tag_list *tags = calloc(1, sizeof(tag_list));
    tag_pair *tp;

    %% write init;
    %% write exec;

    printf("Tag pairs:\n");
    tp = tags->start;
    while(tp != NULL) {
        printf("[%s \"%s\"]\n", tp->name, tp->value);
        tp = tp->next;
    }
    printf("Done.\n");
}