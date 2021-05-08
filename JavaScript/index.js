
var parser=require("./inicio")
parser.parse(`
void Principal(){
    print("-----------Factorial Iterativo---------");
    print("8! = " + factorialIterativo(8));
    print("-----------Factorial Recursivo---------");
    print("8! = " + factorialRecursivo(8));
}

int factorialIterativo(int n){
    int resultado = 1;
    for (int i = 1; i <= n; i++) {
        resultado = resultado * i;
    }
    return resultado;
}

int factorialRecursivo(int n) {
    if (n == 0) {
        return 1;
    }
    return (n * factorialRecursivo(n - 1));
}

exec Principal();
`)