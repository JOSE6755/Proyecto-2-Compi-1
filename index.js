
var parse=require("./inicio")
parse.parse(`
int [] b=new int [5];
int c=4;
b[4]=5;
if(b[c]==5){
imprimir(b[c]);
}

`);

