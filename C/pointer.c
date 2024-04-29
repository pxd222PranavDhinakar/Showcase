#include<stdio.h>
// What will be the output of the following C code?
int main(){
    // Define an integer variable
	int a = 130;
    // Define a pointer to a character
	char *ptr;
    // Cast the address of the integer variable to a pointer to a character
	ptr = (char *)&a;
    // The address of the integer variable a is cast to a pointer to a character
    // and assigned to ptr. This means ptr now points to the memory location of a,
    // but it will interpret the contents of that memory location as a char rather than an int.

	printf("%d ",*ptr); // This outputs -126
	return 0;
}