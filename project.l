%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	#include <math.h>
	#include "project.tab.h"
	extern char* strdup(const char*);
	void yyerror(char *s);
%}



jukto "jukto"[ ][a-z]+.[h]
letter [a-zA-Z]
digit [0-9]
number [-]?{digit}{digit}*[.]?{digit}*
string	["].*["]
id (_|{letter})({letter}|{digit})*
ws [ \t\n]
delim ({ws})*
single_comment [ ]*[s][l][-][-][{letter}{digit}@$%^&*(){}_+,-.:\|?>< ]*

%%

prodhan              return(MAIN);
purno	             return(PURNO);
borno	             return(BORNO);
dosomik	             return(DOSOMIK);
shuru                return(SHURU);
shesh                return(SHESH);
jog                  return(JOG);
biyog		         return(BIYOG);
gun	                 return(GUN);
vaag		         return(VAAG);
log 	             return(LOG);
log10 	             return(LOG10);
sin		             return(SIN);
cos                  return(COS);
tan                  return(TAN);
chapao               return(CHAPAO);
pow                  return(POW);
soman                return(SOMAN);
osoman               return(OSOMAN);
boro                 return(BORO);
borosoman            return(BOROSOMAN);
choto                return(CHOTO);
chotosoman           return(CHOTOSOMAN);
ghurao               return(LOOP);
theke                return(THEKE);
step                 return(STEP);
bachai               return(BACHAI);
ghotona              return(GHOTONA);
sheshghotona         return(SHESHGHOTONA);
jodi                 return(JODI);
othoba               return(OTHOBA);
noile                return(NOILE);
ferot                return(FEROT);
end                  return(END);
max                  return(MAX);
min                  return(MIN);

{delim}              {}
{jukto}              printf("Adding header files\n");
{id}	             {yylval.stringValue = strdup(yytext); return(ID);}
{number}	         {  int length = strlen(yytext);
			            int i = 0;
			            while(i<length){
				            if(yytext[i]=='.'){
					        yylval.val = atof(yytext); 
					        return(NUM);
				            }
				        i++;
			            }
                        yylval.val = atoi(yytext); 
                        return(NUM);
		            }
{string}	        {
						yytext++;
						int l=strlen(yytext);
						yylval.stringValue=yytext;
						yylval.stringValue[l-1]='\0';
						return(BAKKO);
					}
[,;{}=()]	        {yylval.stringValue = strdup(yytext); return *yytext;}
.		            yyerror("Invalid Character for this edition.");
{single_comment} 	{printf("This is a single line comment\n\n");}

%%

int yywrap(void){
	return 1;
}