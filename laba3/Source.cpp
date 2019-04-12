#include <stdio.h>
#include <stdlib.h>
#define ARRAY_SIZE 10

int main() {
	float sizeArray = (float)ARRAY_SIZE;
	int check;
	float elem;
	float arrayIsHere[ARRAY_SIZE];
	double result = 0.0;
	for (int i = 0; i < ARRAY_SIZE; i++) {
		do {
			printf("Enter element number %d: ", i + 1);
			check = scanf_s("%f", &elem);
			rewind(stdin);
		} while (!check);
		arrayIsHere[i] = elem;
	}
	_asm {
		xor ecx, ecx
		mov ecx, ARRAY_SIZE
		finit
		lea eax, arrayIsHere
		fld result
		cycle:
			fadd[eax]
			add eax, 4
			cmp ecx, 0
			dec ecx
		jnz cycle
			fdiv sizeArray
			fst result
			fwait
	}
	printf("\nAverage is: %.2lf\n", result);
	getchar(); 
	return 0;
}