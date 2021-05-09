module.exports=(parser, app)=>{
    app.post('/analizar',(req,res)=>{
        var prueba = req.body.prueba
        var ast = parser.parse(prueba);
        console.log("RETORNO:",ast.consola);
        var resultado = {
            arbol: ast.arbol,
            consola: ast.consola,
            error:ast.error
        }
        res.send(resultado)
    })
}