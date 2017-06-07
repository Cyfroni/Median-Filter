#include <stdio.h>
#include <fstream>
#include <iostream>
#include <CImg.h>

extern "C" int filter(char*, char*, char*);

using namespace std;
using namespace cimg_library;

int main()
{

  char* picture;
  char* result;
  char* buffer;
  int length;	

  ifstream in;
  ofstream out;
  
  in.open("file.bmp");      	// open input file
  in.seekg(0, ios::end);        // go to the end
  length = in.tellg();          // report location (this is the length)
  in.seekg(0, ios::beg);        // go back to the beginning
  picture = new char[length];
  result = new char[length];

  in.read(picture, length); 
  buffer = new char[3*(*(int*)(picture+34) / *(int*)(picture+22))];
  in.close();  

  filter(buffer, picture, result);

  out.open("result.bmp"); 
  out.write(result, length);
  out.close();   

  CImg<unsigned char> pictureImage("file.bmp"), resultImage("result.bmp");
  CImgDisplay inDisplay(pictureImage,"Picture"), outDisplay(resultImage,"Result");
  while (!inDisplay.is_closed() && !outDisplay.is_closed())
  {
    inDisplay.wait();
    outDisplay.wait();
  }

  remove("result.bmp");
  delete[] picture;
  delete[] result;
  delete[] buffer;
  return 0;
}


