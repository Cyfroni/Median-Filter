#include <stdio.h>
#include <fstream>
#include <iostream>

extern "C" int filter(char*, char*, char*);

using namespace std;
int main(void)
{
  char* picture;
  char* result;
  char* buffor;
  int length;	

  ifstream in;
  ofstream out;
  
  in.open("file.bmp");      	  // open input file
  in.seekg(0, std::ios::end);     // go to the end
  length = in.tellg();            // report location (this is the length)
  in.seekg(0, std::ios::beg);     // go back to the beginning
  picture = new char[length];
  result = new char[length];

  in.read(picture, length); 
  buffor = new char[(*(int*)(picture+34) / *(int*)(picture+22))];
  //cout<<*(int*)(picture+34) / *(int*)(picture+22)<<endl;
  in.close();  

  //cout<<filter(buffor, picture, result)<<endl;
  filter(buffor, picture, result);

  out.open("result.bmp");  
  out.write(result, length);
  out.close();

  return 0;
}
