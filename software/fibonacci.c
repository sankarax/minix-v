#include <stdint.h>

int main()
{
    volatile uint32_t *ptr = (volatile uint32_t *)0x400;

    int n = 40;

    int a = 0;
    int b = 1;
    int temp;

    for (int i = 0; i < n; i++)
    {
        temp = a + b;
        a = b;
        b = temp;

        *ptr = a;
    }

    while (1);

    return 0;
}