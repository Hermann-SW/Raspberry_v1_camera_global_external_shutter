// $ gcc circle.c -o circle -lm 
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

int main(int argc, char *argv[])
{
  double x,y,r,s,d;
  int i,N;
  char buf[100],cmd[10000]="",*src,*cut;

  assert(argc==9 || !"x y r s d N src cut");
  x=atof(argv[1]);
  y=atof(argv[2]);
  r=atof(argv[3]);
  s=atof(argv[4]);
  d=atof(argv[5]);
  N=atoi(argv[6]);
  src=argv[7];
  cut=argv[8];

  sprintf(buf, "pngtopnm %s.png > %s.pnm 2>/dev/null ; \\\n", src, src); strcat(cmd, buf);
  sprintf(buf, "pngtopnm %s.empty.png > %s.empty.pnm 2>/dev/null ; \\\n", src, src); strcat(cmd, buf);
  sprintf(buf, "cat %s.pnm | \\\n", src); strcat(cmd, buf);
  for(i=0; i<N; ++i)
  {
    double a;
    int X,Y;

    a=s+i*d;
    X=x+r*sin(a*M_PI/180.0)+0.5;
    Y=y+r*cos(a*M_PI/180.0)+0.5;

    sprintf(buf, "pnmcomp -xoff %d -yoff %d %s.pgm -alpha %s.pgm - | \\\n", X, Y, cut, cut); strcat(cmd, buf);

    fprintf(stderr, "let i=i-1\n");
    fprintf(stderr, "pnmcomp -xoff %d -yoff %d %s.full.pgm blk.md1.pnm > temp.pgm\n", X, Y, cut);
    fprintf(stderr, "pnmcomp -xoff 0 -yoff 0 %s.pnm -alpha temp.pgm %s.empty.pnm | \\\n", src, src);
    fprintf(stderr, "pnmtopng > x.`printf %%02d $i`.png\n");
  }
  sprintf(buf, "cat\n"); strcat(cmd, buf);

  system(cmd);

  return 0;
}
