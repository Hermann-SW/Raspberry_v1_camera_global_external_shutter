#include <stdio.h>
typedef unsigned char uint8_t;
#include "../camera_index.h"

int main()
{
  fwrite(index_ov2640_html_gz, sizeof( index_ov2640_html_gz), 1, stdout);
}
