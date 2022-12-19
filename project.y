%{

#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
int yylex(void);
void yyerror(char *s);

// track the variable index
int no_variable = 0;


// handle properties of variables
struct variable_struct
{
    int variable_type;
    char variable_name[100];
    int int_value;
    float float_value;
    char *char_value;
}variable[1000];


// duplicate variable check
int checkVariable(char name[100])
{
    int i;
    for(i=0; i<no_variable; i++)
    {
        if(!strcmp(variable[i].variable_name, name)) return 1;
    }
    return 0;
}


// st the variable type
void setVariableType(int type)
{
	int i;
	for(i=0; i<no_variable; i++)
    {
		if(variable[i].variable_type == -1)
			variable[i].variable_type = type;
	}
}


// find a variable index
int getVariableIndex(char name[100])
{
	int i;
	for(i=0; i<no_variable; i++)
    {
		if(!strcmp(variable[i].variable_name, name))
			return i;
	}
	return -1;
}


%}


%union{
	double val;
	char* stringValue;
}


%token MAIN PURNO BORNO DOSOMIK SHURU SHESH JOG BIYOG GUN VAAG LOG LOG10 SIN COS TAN CHAPAO POW SOMAN OSOMAN BORO BOROSOMAN CHOTO CHOTOSOMAN LOOP THEKE STEP BACHAI GHOTONA SHESHGHOTONA JODI OTHOBA NOILE FEROT END MAX MIN ID NUM BAKKO

%left JOG BIYOG
%left VAAG GUN

%type<val> start statement declaration TYPE assignment expression temp jodi_Condition othoba_Condition noile_Condition for_code bachai_code ghotona_code ghotona_num_code sheshghotona_code print_code powFunct sinFunct cosFunct tanFunct log10Funct logFunct maxFunc minFunc MAIN PURNO BORNO DOSOMIK SHURU SHESH JOG BIYOG GUN VAAG LOG LOG10 SIN COS TAN CHAPAO POW SOMAN OSOMAN BORO BOROSOMAN CHOTO CHOTOSOMAN LOOP THEKE STEP BACHAI GHOTONA SHESHGHOTONA JODI OTHOBA NOILE FEROT END MAX MIN NUM

%type<stringValue> ID1 ID BAKKO

%%

start: MAIN SHURU statement SHESH {printf("\nValid Statement\n");}
        ;

statement: 
        | declaration statement
        | assignment statement
        | expression statement
        | jodi_Condition statement
        | for_code statement
        | bachai_code statement
        | print_code statement
        | powFunct statement
        | sinFunct statement
        | cosFunct statement
        | tanFunct statement
        | log10Funct statement
        | logFunct statement
        | maxFunc statement
        | minFunc statement
        | expression
        ;



// declaration
declaration: TYPE ID1 END 
{
	setVariableType($1);
};



TYPE: PURNO	{$$ = 1; printf("\nType--> Integer\n");}
	| DOSOMIK	{$$ = 2; printf("\nType--> Float\n");}
	| BORNO	{$$ = 0; printf("\nType--> Character\n");}
	;



ID1: ID1 ',' ID {
	if(checkVariable($3)==0){
		printf("\nValid declaration\n");
		strcpy(variable[no_variable].variable_name, $3);
		printf("\nVariable name: %s", $3);
		variable[no_variable].variable_type =  -1;
		no_variable = no_variable + 1;
	}
	else{
		printf("\nVariable is already used");
	}
} 
	| ID {
	if(checkVariable($1)==0){
		printf("\nValid declaration\n");
		strcpy(variable[no_variable].variable_name, $1);
		printf("\nVariable name: %s", $1);
		variable[no_variable].variable_type =  -1;
		no_variable = no_variable + 1;
	}
	else{
		printf("\nVariable is already used\n");
	}
	strcpy($$, $1);
}
	;



assignment: ID '=' expression END {
	$$ = $3;
	if(checkVariable($1)==1){
		int i = getVariableIndex($1);
		if(variable[i].variable_type==0){
			variable[i].char_value = (char*)&$3-'a';
			printf("\nVariable value: %s (STRING)", variable[i].char_value);
		}
		else if(variable[i].variable_type==1){
			variable[i].int_value = $3;
			printf("\nVariable value: %d (INTEGER)", variable[i].int_value);
		}
		else if(variable[i].variable_type==2){
			variable[i].float_value = (float)$3;
			printf("\nVariable value: %f (FLOAT)", variable[i].float_value);
		}
	}
	else{
		printf("\nVariable is not declared\n");
	}
}
	|ID '=' BAKKO END{
		//$$ = $3;
	    if(checkVariable($1)==1){
		int i = getVariableIndex($1);
		if(variable[i].variable_type==0){
			variable[i].char_value = $3;
			printf("\nVariable value: %s (STRING)", variable[i].char_value);
			}
		}
	}
	; 




expression:  NUM					            { $$ = $1; }
			| expression JOG expression	        { $$ = $1 + $3; }
			| expression BIYOG expression	    { $$ = $1 - $3; }
			| expression GUN expression	        { $$ = $1 * $3; }
			| expression VAAG expression	    { if($3){
														$$ = $1 / $3;
													}
													else{
														$$ = 0;
														printf("\ndivision by zero error\n");
													} 	
												}
			| expression '^' expression	        	{ $$ = pow($1 , $3);}
			| expression CHOTO expression	        { $$ = $1 < $3; }
			| expression BORO expression	        { $$ = $1 > $3; }
			| expression BOROSOMAN expression	    { $$ = $1 >= $3; }
			| expression CHOTOSOMAN expression	    { $$ = $1 <= $3; }
			| expression SOMAN expression	        { $$ = $1 == $3; }
			| expression OSOMAN expression	        { $$ = $1 != $3; }
			| '(' expression ')'		            { $$ = $2;}
			| temp                                  {$$=$1};

temp: '(' expression ')' {$$ = $2;}
	| ID{
	        int id_index = getVariableIndex($1);
			if(id_index == -1)
			{
				yyerror("\nVARIABLE DOESN'T EXIST\n");
			}
			else
			{
				if(variable[id_index].variable_type == 1)
				{
					$$ = variable[id_index].int_value;
				}
				else if(variable[id_index].variable_type == 2)
				{
					$$ = variable[id_index].float_value;
				}
			}
        }
	| NUM  {$$ = $1;}
	;



jodi_Condition:  JODI '(' expression ')''{'statement  '}' othoba_Condition noile_Condition {
				printf("\nIF CONDITION");
				int i = $3;
				if(i==1){
					printf("\nIF CONDITION IS TRUE\n");
				}
				else{
					printf("\nIF CONDITION IS FALSE\n");
				}
			}
			;
othoba_Condition: OTHOBA '(' expression ')''{' statement  '}' othoba_Condition {
				printf("\nELSE IF CONDITION\n");
				int i = $3;
				if(i==1){
					printf("\nELSE IF CONDITION IS TRUE\n");
				}
				else{
					printf("\nELSE IF CONDITION IS FALSE\n");
				}
			}
			|
			;
noile_Condition: NOILE '{' statement  '}' {
				printf("\nELSE CONDITION\n");
			}
			|
			;




for_code: LOOP ID THEKE NUM STEP NUM '{' statement '}' {
		printf("\nFor loop\n");
		int ii = getVariableIndex($2);
		int i = variable[ii].int_value;
		int j = $4;
		int inc = $6;
		int k;
		for(k=i; k<j; k=k+inc){
			printf("\nLOOP RUNNING(LOOP-THEKE)\n");
		}	
	}
	|LOOP ID THEKE ID STEP NUM '{' statement '}' {
		printf("\nFor loop\n");
		int ii = getVariableIndex($2);
		int i = variable[ii].int_value;
		int jj = getVariableIndex($4);
		int j = variable[jj].int_value;
		int inc = $6;
		int k;
		for(k=i; k<j; k=k+inc){
			printf("\nLOOP RUNNING(LOOP-THEKE)\n");
		}
	}
	|LOOP NUM THEKE ID STEP NUM '{' statement '}' {
		printf("\nFor loop\n");
		int i = $2;
		int jj = getVariableIndex($4);
		int j = variable[jj].int_value;
		int inc = $6;
		int k;
		for(k=i; k<j; k=k+inc){
			printf("\nLOOP RUNNING(LOOP-THEKE)\n");
		}
	}
	|LOOP NUM THEKE NUM STEP NUM '{' statement '}' {
		printf("\nFor loop\n");
		int i = $2;
		int j = $4;
		int inc = $6;
		int k;
		for(k=i; k<j; k=k+inc){
			printf("\nLOOP RUNNING(LOOP-THEKE)\n");
		}
	}
	;



bachai_code: BACHAI '(' ID ')' '{' ghotona_code '}' {
		printf("\nSwitch Case demo.\n");
	}
	;
ghotona_code: ghotona_num_code sheshghotona_code
	;

ghotona_num_code: GHOTONA NUM '{' statement '}' ghotona_num_code {
		printf("\nCase no: %d\n", $2);
	}
	|
	;
sheshghotona_code: SHESHGHOTONA '{' statement '}'
	;




print_code: CHAPAO '(' ID ')' END{
		int i = getVariableIndex($3);
		if(variable[i].variable_type == 1){
			printf("\nVariable name: %s, Value: %d\n\n", variable[i].variable_name, variable[i].int_value);
		}
		else if(variable[i].variable_type == 2){
			printf("\nVariable name: %s, Value: %f\n\n", variable[i].variable_name, variable[i].float_value);
		}
		else{
			printf("\nVariable name: %s, Value: %s\n\n", variable[i].variable_name, variable[i].char_value);
		}
	}
	;





powFunct: POW '(' expression ',' expression ')' END	{		
		int i;
		i = pow($3,$5);
		printf("\nPower function value: %d \n\n", i);
	}
	;

sinFunct: SIN '(' expression ')' END {
		printf("\nValue of Sin(%lf) is %lf\n\n",$3,sin($3*3.1416/180)); 
		$$=sin($3*3.1416/180);
	}
	;
	

cosFunct: COS '(' expression ')' END {
		printf("\nValue of Cos(%lf) is %lf\n\n",$3,cos($3*3.1416/180)); 
		$$=cos($3*3.1416/180);
	}
	;
tanFunct: TAN '(' expression ')' END {
		printf("\nValue of Tan(%lf) is %lf\n\n",$3,tan($3*3.1416/180)); 
		$$=tan($3*3.1416/180);
	}
	;


log10Funct: LOG10 '(' expression ')' END {
		printf("Value of Log10(%lf) is %lf\n\n",$3,(log($3*1.0)/log(10.0))); 
		$$=(log($3*1.0)/log(10.0));
	}
	;
logFunct: LOG '(' expression ')' END {
		printf("Value of Log(%lf) is %lf\n\n",$3,(log($3))); 
		$$=(log($3));
	}	
	;

maxFunc: MAX '(' expression ',' expression ')' END {
		printf("\nCalculate the maximum number.\n");
		if($3 > $5){
			$$ = $3;
		}
		else{
			$$ = $5;
		}
	}
	;

minFunc: MIN '(' expression ',' expression ')' END {
		printf("\nCalculate the minimum number.\n");
		if($3 < $5){
			$$ = $3;
		}
		else{
			$$ = $5;
		}
	}
	;
%%


void yyerror(char *s)
{
	fprintf(stderr, "\n%s", s);
}

int main(){
	freopen("input.txt", "r",stdin);
	freopen("output.txt", "w",stdout);
	yyparse();
	return 0;
}