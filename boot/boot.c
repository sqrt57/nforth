#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DICT_SIZE				64 * 1024	/* Length of dictionary in bytes */
#define	PARAMETER_STACK_SIZE	256 * 4		/* Maximum size of parameter stack */
#define RETURN_STACK_SIZE		256 * 4		/* Maximum size of return stack */

int *dictionary;		/* Memory for dictionary */
int *parameter_stack;	/* Memory for parameter stack */
int *return_stack;		/* Memory for return stack */

/*
 * Stacks grow upwards.
 * Stack pointers point to the current top of stack.
 */
int *ps;	/* Current parameter stack pointer */
int *rs;	/* Current return stack pointer */

int *ip;	/* Current instruction pointer */

void init()
{
	dictionary = (int*) malloc(DICT_SIZE);
	parameter_stack = (int*) malloc(PARAMETER_STACK_SIZE);
	return_stack = (int*) malloc(RETURN_STACK_SIZE);
}

void reset()
{
	ps = parameter_stack - 1;
	rs = return_stack - 1;
}

/*
 * Command-line arguments parsing
 */

int starts_with(const char *str, const char *start)
{
	return strncmp(str, start, strlen(start)) == 0;
}

typedef struct source_info
{
	char *source_code;
	char *file_name;
	struct source_info *next;
};

struct source_info *source_infos;

void add_source_info(char *source_code, char *file_name)
{
	struct source_info *new_info;
	struct source_info *last;

	new_info = (struct source_info *) malloc(sizeof(struct source_info));
	new_info->source_code = source_code;
	new_info->file_name = file_name;
	new_info->next = NULL;

	if (source_infos == NULL) {
		source_infos = new_info;
	} else {
		last = source_infos;
		while (last->next != NULL)
			last = last->next;
		last->next = new_info;
	}
}

int main(int argc, char *argv[])
{
	int i;

	init();
	reset();

	for (i = 0; i < argc; ++i)
	{
	}

	return 0;
}
