module.exports=(parser, app)=>{
    app.post('/analizar',(req,res)=>{
        var prueba = req.body.prueba
        var ast = parser.parse(prueba);
        //var imprimibles="";        
       /* for(var a of ast.Imprimibles)
        {
            imprimibles+= a+'\n';
        }
        for(var b of ast.Errores)
        {
            imprimibles+= b+'\n';
        }
        */
        console.log("RETORNO:",ast.consola);
        var resultado = {
            arbol: ast.consola,
            consola: ast.consola
        }
        res.send(resultado)
    })
}