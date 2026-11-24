// One workload: shortest paths from a switch-selected source in a 24-node map.
// The graph is deterministic, connected, and generated at run time.
// No division, remainder, library, or initialized data segment is required.
typedef unsigned int u32;
typedef unsigned short u16;

#define NODES 24u
#define INF 0x3fffffffu

int main(void) {
    volatile u32 *io = (volatile u32 *)0;
    u32 source = io[0];
    while (source >= NODES) source -= NODES;

    volatile u16 edge[NODES][NODES];
    volatile u32 distance[NODES];
    volatile unsigned char visited[NODES];

    for (u32 i = 0; i < NODES; ++i) {
        distance[i] = INF;
        visited[i] = 0;
        for (u32 j = 0; j < NODES; ++j) {
            u32 pattern = (i * 13u + j * 7u + (i ^ j) * 3u) & 7u;
            u32 neighbor = (i + 1u == j) || (j + 1u == i) ||
                           (i == 0u && j == NODES - 1u) ||
                           (j == 0u && i == NODES - 1u);
            u32 weight = 1u + (((i + 1u) * (j + 3u) +
                                (i ^ j) * 11u) & 63u);
            edge[i][j] = (i != j && (neighbor || pattern < 3u))
                       ? (u16)weight : 0;
        }
    }

    distance[source] = 0;
    for (u32 step = 0; step < NODES; ++step) {
        u32 best = INF;
        u32 current = NODES;
        for (u32 v = 0; v < NODES; ++v) {
            if (!visited[v] && distance[v] < best) {
                best = distance[v];
                current = v;
            }
        }
        if (current == NODES) break;
        visited[current] = 1;
        for (u32 v = 0; v < NODES; ++v) {
            u32 weight = edge[current][v];
            if (weight && !visited[v] && best + weight < distance[v])
                distance[v] = best + weight;
        }
    }

    u32 reachable = 0, sum = 0, maximum = 0;
    u32 digest = 0x12345678u;
    for (u32 v = 0; v < NODES; ++v) {
        u32 d = distance[v];
        io[16u + v] = d; // Full answer: RAM words 16..39.
        if (d != INF) {
            ++reachable;
            sum += d;
            if (d > maximum) maximum = d;
        }
        digest = (digest << 5) ^ (digest >> 2) ^ d ^ v;
    }

    io[1] = reachable;
    io[2] = sum;
    io[3] = maximum;
    io[4] = digest;
    io[5] = 0x600du; // Last store: end of measured interval.
    for (;;) { }
}
