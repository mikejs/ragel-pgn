#include "pgn.h"

int main() {
    pgn_parse("\[Hello \"world\"][ good\"bye world\" ]"
        "\n[another \" line\"]");

    return 0;
}
