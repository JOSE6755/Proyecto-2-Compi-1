%{
    //Varias variables para guardar simbolos e instrucciones para retornalas a la interfaz
    var Simbolos=new Map();
    var pilaCicl=[];
    var pilaFun=[];
    var consolita=""
    var consolita2=""
    var errores="Errores:\n"
    //Objeto para delimitar los bloques de instrucciones
    const Entorno=function(anterior){
        return{
            Simbolos:new Map(),
            anterior:anterior
        }
    }
    //Entorno que engloba el programa
    var Global=Entorno(null)
    //Objeto creado para la creacion de variables
    function NuevoSimbolo(valor,tipo,Exp,tipo2){
        return{
            Valor:valor,
            Tipo:tipo,
            Exp:Exp,
            Ti:tipo2
        }
    }
    //objeto creado para diferenciar las creaciones de operaciones
    function NuevaOp(Operandoizq,Operandoder,tipo){
        return{
            Opizq:Operandoizq,
            Opder:Operandoder,
            Tipo:tipo
        }
    }
    //objeto creado para diferenciar la accion print
    const Imprimir=function(Exp,tipo){

        return{
            Exp:Exp,
            TipoIns:tipo
        }

    }
    //objeto para diferenciar el operador unario de una resta
    function OperaUna(Operandoizq,tipo){
        return{
            Opizq:Operandoizq,
            Opder:null,
            Tipo:tipo
        }
    }
    //funcion dada den taller de jison para ejecutar bloques de instrucciones
    function EjectBloque(LINS,ent){
        var retu=null;
        for(var elemento of LINS){
       
            switch(elemento.TipoIns){
                case "imprimir":
                    var e=evaluar(elemento.Exp,ent);
                    console.log(e.Valor);
                    consolita+=String(e.Valor)+"\n"
                    consolita2+=consolita
                    
                    
                    break;
                case "crear":
                   retu=ExecCrear(elemento,ent);
                    break;
                case "asignar":
                    retu=ExecAsign(elemento,ent);
                    break;
                case "SI":
                    retu=ExecSI(elemento,ent,ent)
                    break;
                case "switch":
                    retu=ExecSwitchi(elemento,ent)
                    break;
                case "while":
                    retu=ExecWhiles(elemento,ent)
                    break;
                case "do while":
                    retu=ExecWhiles2(elemento,ent)
                    break;
                case "for":
                    retu=ExecFores(elemento,ent)
                    break
                case "funcion":
                    retu=ExecFuncionar(elemento,Global)
                    break
                case "llamada":
                    ExecLlamar(elemento,ent)
                    retu=null
                    break
                case "return":
                    if(pilaFun.length>0){
                        retu=elemento.Exp
                    }else{
                        console.log("Instruccion return fuera de una funcion o metodo")
                        errores+="Instruccion return fuera de una funcion o metodo\n"
                    }
                    break
                case "break":
                    if(pilaCicl.length>0){
                    return elemento
                    }else{
                        console.log("Break fuera de un switch o ciclo detectado")
                        errores+="Break fuera de un switch o ciclo detectado\n"
                    }
                    break;
                case "continue":
                    if(pilaCicl.length>0){
                        return elemento
                    }else{
                        console.log("continue fuera de un switch o ciclo detectado")
                        errores+="continue fuera de un switch o ciclo detectado\n"
                    }
            }
            if(retu){
                
                return retu
            }
        }
        
        return null
    }
    //funcion dada en taller de jison para llevar a cabo operaciones entre valores
    function evaluar(operacion,ent){
        var izq;
        var der;
        switch(operacion.Tipo){
            case "bool":
                return NuevoSimbolo(operacion.Valor,operacion.Tipo)
            
            case "String":
                return NuevoSimbolo(operacion.Valor,operacion.Tipo)
            case "int":
                return NuevoSimbolo(parseFloat(operacion.Valor),operacion.Tipo)
            case "double":
                return NuevoSimbolo(parseFloat(operacion.Valor),operacion.Tipo)
            case "ID":
            var temporal=ent
                while(temporal!=null){
                    if (temporal.Simbolos.has(operacion.Valor)){
                        var valorID=temporal.Simbolos.get(operacion.Valor)
                        return NuevoSimbolo(valorID.Valor,valorID.Tipo)
                    }
                    temporal=temporal.anterior
                }
                console.log("No existe la variable: "+operacion.Valor);
                errores+="No existe la variable: "+operacion.Valor+"\n"
                return NuevoSimbolo("@error@","error");
            case "char":
                return NuevoSimbolo(operacion.Valor,operacion.Tipo)
            case "cambio":
                var result=ExecCambios(Cambios(operacion.Valor.Exp,operacion.Valor.Tipo),ent)
                return result
            case "mayus":
                var result=ExecLetras(Letras(operacion.Exp,operacion.Ti),ent)
                return result
            case "funcion":
                var result=ExecLlamar(LLAMADA(operacion.Valor.Exp,operacion.Valor.Param),ent)
                return result
            case "array":
                var temporal=ent
                while(temporal!=null){
                    if(temporal.Simbolos.has(operacion.Exp)){
                        var val=temporal.Simbolos.get(operacion.Exp)
                        var auxiliar=evaluar(operacion.Ti,ent)
                        if(auxiliar.Tipo=="int" && auxiliar.Valor>=0 &&auxiliar.Valor<=(val.length-1)){
                            val=val[auxiliar.Valor]
                            return NuevoSimbolo(val.Valor,val.Tipo)
                        }else{
                            console.log("La posicion: "+operacion.Valor.Param.Valor+" Se encuentra fuera del tamaño indicado anteriormente")
                            errores+="La posicion: "+operacion.Valor.Param.Valor+" Se encuentra fuera del tamaño indicado anteriormente\n"
                            return NuevoSimbolo("@error@","error")
                        }
                    }
                    temporal=temporal.anterior
                }
                console.log("No existe el array"+operacion.Valor)
                errores+="No existe el array"+operacion.Valor+"\n"
                return NuevoSimbolo("@error@","error")
                break
            case "list":
                var temporal=ent
                while(temporal!=null){
                    if(temporal.Simbolos.has(operacion.Exp)){
                        var val=temporal.Simbolos.get(operacion.Exp)
                        var auxiliar=evaluar(operacion.Ti,ent)
                        if(auxiliar.Tipo=="int" && auxiliar.Valor>=0 &&auxiliar.Valor<=(val.length-1)){
                            val=val[auxiliar.Valor+1]
                            return NuevoSimbolo(val.Valor,val.Tipo)
                        }else{
                            console.log("La posicion: "+operacion.Valor.Param.Valor+" Se encuentra fuera del tamaño indicado anteriormente")
                            errores+="La posicion: "+operacion.Valor.Param.Valor+" Se encuentra fuera del tamaño de la lista \n"
                            return NuevoSimbolo("@error@","error")
                        }
                    }
                    temporal=temporal.anterior
                }
                console.log("No existe la lista"+operacion.Valor)
                errores+="No existe la lista"+operacion.Valor+"\n"
                return NuevoSimbolo("@error@","error")
            case "redondeos":
                var result=ExecRedondeos(REDONDEOS(operacion.Exp,operacion.Ti),ent)
                return result
        }
        izq=evaluar(operacion.Opizq,ent)
        if (operacion.Opder!=null){
            der=evaluar(operacion.Opder,ent)

        }
        var retorno="error"
        switch (operacion.Tipo){
            case "+":
                switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);
                                break
                            case "bool":
                                retorno="int"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "char":
                                retorno="int"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "String":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);  
                                break
                        }
                    case "double":
                        if(!der){
                            retorno="double"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);
                                break
                            case "bool":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "char":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "String":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);  
                                break
                        }
                    case "bool":
                        if(!der){
                            retorno="bool"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);
                                break
                            case "String":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);  
                                break
                        }
                    case "char":
                        if(!der){
                            retorno="char"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);
                                break
                            case "char":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "String":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);  
                                break
                        }
                    case "String":
                        if(!der){
                            retorno="String"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="String"
                                 return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);
                                break
                            case "bool":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "char":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno); 
                                break
                            case "String":
                                retorno="String"
                                return NuevoSimbolo(izq.Valor+der.Valor,retorno);  
                                break
                        }
                }
                break;
            case "-":
                switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor-der.Valor,retorno);
                                 break 
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno);
                                break
                            case "bool":
                                retorno="int"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                break
                            case "char":
                                retorno="int"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                break
                             
                        }
                    case "double":
                        if(!der){
                            retorno="double"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno);
                                break
                            case "bool":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                break
                            case "char":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                break
                            
                        }
                    case "bool":
                        if(!der){
                            retorno="bool"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno);
                                break
                            
                        }
                    case "char":
                        if(!der){
                            retorno="char"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor-der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor-der.Valor,retorno);
                                break
                            
                        }
                }
                break;
            case "*":
                switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor*der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor*der.Valor,retorno);
                                break
                            
                            case "char":
                                retorno="int"
                                return NuevoSimbolo(izq.Valor*der.Valor,retorno); 
                                break
                        }
                    case "double":
                        if(!der){
                            retorno="double"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(izq.Valor*der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor*der.Valor,retorno);
                                break
                             
                            case "char":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor*der.Valor,retorno); 
                                break
                            
                        }
                    case "char":
                        if(!der){
                            retorno="char"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor*der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor*der.Valor,retorno);
                                break
                             
                        }
                }
                break;
            case "/":
                switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(izq.Valor/der.Valor,retorno);
                                 break 
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor/der.Valor,retorno);
                                break
                             
                            case "char":
                                retorno="int"
                                return NuevoSimbolo(izq.Valor/der.Valor,retorno); 
                                break
                             
                        }
                    case "double":
                        if(!der){
                            retorno="double"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(izq.Valor/der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor/der.Valor,retorno);
                                break
                             
                            case "char":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor/der.Valor,retorno); 
                                break
                             
                        }
                    
                    case "char":
                        if(!der){
                            retorno="char"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor/der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor/der.Valor,retorno);
                                break
                             
                        }
                    
                }
                break;
            case "umenos":
                switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                           return NuevoSimbolo(0-izq.Valor,retorno)
                            break
                        }
                        
                    case "double":
                        if(!der){
                            retorno="double"
                           return NuevoSimbolo(0-izq.Valor,retorno)
                            break
                        }
                }
                        
                    
                break;
            case "%":
                switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(izq.Valor%der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor%der.Valor,retorno);
                                break 
                        }
                    case "double":
                        if(!der){
                            retorno="double"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(izq.Valor%der.Valor,retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(izq.Valor%der.Valor,retorno);
                                break
                              
                        }
                }
                   
                break;
            case "^":
            switch(izq.Tipo){
                    case "int":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="int"
                                 return NuevoSimbolo(Math.pow(izq.Valor,der.Valor),retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(Math.pow(izq.Valor,der.Valor),retorno);
                                break
                            
                        }
                    case "double":
                        if(!der){
                            retorno="int"
                            break
                        }
                        switch(der.Tipo){
                            case "int":
                                retorno="double"
                                 return NuevoSimbolo(Math.pow(izq.Valor,der.Valor),retorno); 
                                 break
                            case "double":
                                retorno="double"
                                return NuevoSimbolo(Math.pow(izq.Valor,der.Valor),retorno);
                                break
                            
                        }
            }
            case "not":
                return NuevoSimbolo(!izq.Valor,izq.Tipo);
                break;
            case "and":
                return NuevoSimbolo(izq.Valor&&der.Valor,izq.Tipo);
                break;
            case "or":
                return NuevoSimbolo(izq.Valor||der.Valor,izq.Tipo);
                break;
            case ">":
                return NuevoSimbolo(izq.Valor>der.Valor,"bool");
                break;
            case "<":
                return NuevoSimbolo(izq.Valor<der.Valor,"bool");
                break;
            case ">=":
                return NuevoSimbolo(izq.Valor>=der.Valor,"bool");
                break;
            case "<=":
                return NuevoSimbolo(izq.Valor<=der.Valor,"bool");
                break;
            case "==":
                return NuevoSimbolo(izq.Valor==der.Valor,"bool");
                break;
            case "!=":
                return NuevoSimbolo(izq.Valor!=der.Valor,"bool");
                break;
            
        }
    }
    //objeto creado para diferenciar la instruccion crear de otras
    const Creacion=function(ID,Tipo,Exp,Tipo2,Tam){
        return{
            Id:ID,
            Tipo:Tipo,
            Exp:Exp,
            Tipo2:Tipo2,
            Tamaño:Tam,
            TipoIns:"crear"
        }
    }
    //Funcion daa en taller de jison para ejecutar la creacion de variables
    function ExecCrear(Crear,ent){
        if(ent.Simbolos.has(Crear.Id)){
            console.log("La variable: "+Crear.Id+" ya existe en este ambito")
            errores+="La variable: "+Crear.Id+" ya existe en este ambito\n"
            return;
        }

        var  valor;
        
            if(Crear&& Crear.Exp){
                if(Crear.Tipo2){
                    if(Crear.Tipo==Crear.Tipo2){
                        Crear.Tipo2="array"
                        valor=[]
                        for(var array of Crear.Exp){
                            var val=evaluar(array,ent)
                            if(Crear.Tipo=="string"){
                                Crear.Tipo="String"
                            }
                            if(Crear.Tipo=="boolean"){
                                Crear.Tipo="bool"
                            }
                            if(val.Tipo==Crear.Tipo){
                                valor.push(val)
                            }else{
                                console.log("Los datos ingresados no coinciden con el tipo del array")
                                errores+="Los datos ingresados no coinciden con el tipo del array\n"
                                return
                            }
                        }
                    }else{
                        console.log("Los tipos de datos no coindicen con el del array")
                        errores+="Los datos ingresados no coinciden con el tipo del array\n"
                        return
                    }
                    
                }else{
                    if(Crear.Tipo=="string"){
                        Crear.Tipo="String"
                    }
                    if(Crear.Tipo=="boolean"){
                        Crear.Tipo="bool"
                    }
                valor=evaluar(Crear.Exp,ent);
                if(valor.Tipo!=Crear.Tipo){
                    console.log("El tipo no coincide con la variable a crear")
                   errores+= "El tipo no coincide con la variable a crear\n"
                }
                }
                
            }else{
                if(Crear.Tipo2){
                    if (Crear.Tipo==Crear.Tipo2){
                        if(Crear.Tamaño){
                        Crear.Tipo2="array"
                        var numero=evaluar(Crear.Tamaño,ent)
                        valor=[]
                        var temporal="mientras"
                        
                        for(var tamano=0;tamano<numero.Valor;tamano++){
                            switch(Crear.Tipo){
                                case "int":
                                    temporal=NuevoSimbolo(0,"int")
                                    break;
                                case "double":
                                    temporal=NuevoSimbolo(0.0,"double")
                                    break;
                                case "char":
                                    temporal=NuevoSimbolo('\u0000',"char")
                                    break;
                                case "String":
                                    temporal=NuevoSimbolo("","String")
                                    break;
                            }
                            valor.push(temporal)

                        }
                    }else{
                        valor=[]
                        Crear.Tipo2="list"
                        valor.push(NuevoSimbolo("list",Crear.Tipo))
                    }
                    }else{
                        console.log("Los tipos de datos ingresados en el array no coinciden")
                        errores+="Los datos ingresados no coinciden con el tipo del array\n"
                        return
                    }
                }else{
                    if(Crear.Tipo=="string"){
                        Crear.Tipo="String"
                    }
                    if(Crear.Tipo=="boolean"){
                        Crear.Tipo="Boolean"
                    }
                switch(Crear.Tipo){
                    case "int":
                        valor=NuevoSimbolo(0,"int");
                        break;
                    case "String":
                        valor=NuevoSimbolo("","String")
                        break;
                    case "double":
                        valor=NuevoSimbolo(0.0,"double")
                        break;

                    case "Boolean":
                        valor=NuevoSimbolo(false,"Boolean")
                        break;
                    case "char":
                        valor=NuevoSimbolo('',"char")
                        break;

                
                }
                }
            }
            
        
        
            
        
        ent.Simbolos.set(Crear.Id,valor)
        
    }
    //Objeto para diferenciar la accion de asignar de otras
    const Asign=function(id,Exp,Exp2){
        return{
            Id:id,
            Exp:Exp,
            TipoIns:"asignar",
            Exp2:Exp2
        }
    }
    //Funcion dada en taller de jison para asignar valores a variables
    const ExecAsign=function(asignar,ent){
        var val=evaluar(asignar.Exp,ent)
        var temporal=ent
        while(temporal!=null){
            if(temporal.Simbolos.has(asignar.Id)){
                var simbol=temporal.Simbolos.get(asignar.Id);
                if(asignar.Exp2){
                    if(asignar.Exp2.Tipo!="list"){
                        var n=evaluar(asignar.Exp2,ent)
                        if(n.Tipo=="int"&&val.Tipo==simbol[0].Tipo){
                            if(n.Valor>=0 && n.Valor<simbol.length){
                                simbol[n.Valor]=val
                                return;
                            }else{
                                console.log("Ocurrio un error con: "+asignar.Id)
                                errores+="Ocurrio un error con: "+asignar.Id+"\n"
                                return
                            }
                        }else{
                            console.log("Ocurrio un error con: "+asignar.Id)
                            errores+="Ocurrio un error con: "+asignar.Id+"\n"
                                return
                        }
                    }else{
                        if(val.Tipo==simbol[0].Tipo){
                            simbol.push(val)
                            temporal.Simbolos.set(asignar.Id,simbol)
                            return
                        }
                    }
                }else{
                    if(simbol.Tipo=="Boolean"){
                        simbol.Tipo="bool"
                    }
                    if(val.Tipo=="char"){
                        if(val.Valor.length!=0){
                            console.log("La longitud de: "+val.Valor+"Es diferente de 1 por lo tanto no se considera de tipo char")
                            errores+="La longitud de: "+val.Valor+"Es diferente de 1 por lo tanto no se considera de tipo char\n"
                            return
                        }
                    }
                    if (simbol.Tipo=="double" && val.Tipo=="int"){
                    val.Tipo="double"
                }
                
                if(simbol.Tipo===val.Tipo){
                    temporal.Simbolos.set(asignar.Id,val);
                    return
                }else{
                    console.log("Tipos incompatibles: ",simbol.Tipo,",",val.Tipo)
                    errores+="Tipos incompatibles: ",simbol.Tipo,",",val.Tipo+"\n"
                    return
                }
                }
                
                
            }
            temporal=temporal.anterior
            
        }
        console.log("No se encontro la variable: ",asignar.Id)
        errores+="No se encontro la variable: ",asignar.Id+"\n"


    }
    //Objeto para diferenciar la instruccion if else de otros
    const SI=function(Exp,AreaSi,AreaSiNo){
        return{
            Exp:Exp,
            AreaSi:AreaSi,
            AreaSiNo:AreaSiNo,
            TipoIns:"SI"
        }
    }
    //Funcion dada en taller de jison para ejecutar un bloque if o else
    function ExecSI(SI,ent){
        var cond=evaluar(SI.Exp,ent)
        if (cond.Tipo="bool"){
            if(cond.Valor){
                var nuevo=Entorno(ent)
                return EjectBloque(SI.AreaSi,nuevo)
            }else if(SI.AreaSiNo!=null){
                var nuevo=Entorno(ent)
                return EjectBloque(SI.AreaSiNo,nuevo)
            }
        }else{
            console.log("Se esperab una condicion dentro del if")
            errores+="Se esperab una condicion dentro del if\n"
        }
    }
    //Objeto para diferenciar el switch de lo demas
    const SWITCHI=function(Exp, Lcases,Default){
        return{
            Exp:Exp,
            Lcases:Lcases,
            Default:Default,
            TipoIns:"switch"
        }
    }
    //Objeto para diferenciar los casos en un switch
    const Cases=function(Exp,Area){
        return{
            Exp:Exp,
            Area:Area,
        }
    }
    //Funcion dada en taller de jison para ejecutar un switch-case
    function ExecSwitchi(Switchi,ent){
        pilaCicl.push("switch")
        var eject=false
        var nuevito=Entorno(ent)
        for(var cas of Switchi.Lcases){
            var cond=evaluar(NuevaOp(Switchi.Exp,cas.Exp,"=="),ent);
            if (cond.Tipo=="bool"){
                if(cond.Valor){
                   
                    var result=EjectBloque(cas.Area,nuevito)
                    if(result && result.TipoIns=="break"){
                        pilaCicl.pop()
                        return
                    }else if(res){
                        pilaCicl.pop()
                        return result
                    }
                }
            }else{
                pilaCicl.pop()
                return
            }
        }
        if (Switchi.Default && eject==false){
            var result=EjectBloque(Switchi.Default,nuevito);
        }
        pilaCicl.pop()
        return 
    }
    //Objeto para diferenciar la instruccion rompert o break
    const ROMPER=function(){
        return{
            TipoIns:"break"
        }
    }
    //Objeto para diferencias el ciclo while de otros
    const WHILES=function(Exp,Area){
        return{
            Exp:Exp,
            Area:Area,
            TipoIns:"while"
        }
    }
    //Funcion dada en taller de jison para ejecutar un ciclo while
    function ExecWhiles(Whiles,ent){
        pilaCicl.push("while");
        
        while(true){
            nuevito=Entorno(ent)
            var result=evaluar(Whiles.Exp,ent)
            if(result.Tipo=="bool"){
                if(result.Valor){
                    var eject=EjectBloque(Whiles.Area,nuevito);
                    if (eject && eject.TipoIns=="break"){
                        break
                    }else if(eject){
                        pilaCicl.pop()
                        return eject
                    }else if(eject && eject.TipoIns=="continue"){
                        continue
                    }
                }else{
                    break
                }
            }else{
                console.log("Se esperaba una condicion dentro del ciclo while")
                errores+="Se esperaba una condicion dentro del ciclo while\n"
                pilaCicl.pop();
                return
            }
        }
    }
    //Objeto para diferencias el ciclo do while de un while normal
    const WHILES2=function(Exp,Area){
        return{
            Exp:Exp,
            Area:Area,
            TipoIns:"do while"
        }
    }
    //funcion para ejecutar un ciclo do while
    function ExecWhiles2(Whiles,ent){
        pilaCicl.push("do while");
        while(true){
            nuevito=Entorno(ent)
            var result=evaluar(Whiles.Exp,ent)
            var eject=EjectBloque(Whiles.Area,nuevito);
            if (eject && eject.TipoIns=="break"){
                break
            }else if(eject){
                pilaCicl.pop()
                return eject
            }else if(eject && eject.TipoIns=="continue"){
                continue
            }
            if(result.Tipo=="bool"){
                if(result.Valor){
                    
                    
                }else{
                    break
                }
            }else{
                console.log("Se esperaba una condicion dentro del ciclo while")
                errores+="Se esperaba una condicion dentro del ciclo while\n"
                pilaCicl.pop();
                return
            }
        }
        
    }
    //Objeto para diferenciar el ciclo for
    const FORES=function(Expinicio,Expfin,Expavance,Area){
        return{
            Expinicio:Expinicio,
            Expfin:Expfin,
            Expavance:Expavance,
            Area:Area,
            TipoIns:"for"
        }
    }
    //Funcion dada en taller de jison para ejectuar un ciclo for
    function ExecFores(desde,ent){
        pilaCicl.push("for")
        var nuevito=Entorno(ent)
        if(desde.Expinicio.TipoIns=="crear"){
            ExecCrear(desde.Expinicio,nuevito)
        }else{
            ExecAsign(desde.Expinicio,nuevito)
        }
        while(true){
            var cond=evaluar(desde.Expfin,nuevito)
            if(!cond.Valor){
                pilaCicl.pop();
                return;
            }
            var nue=Entorno(nuevito)
            var result=EjectBloque(desde.Area,nue)
            if (result && result.TipoIns=="break"){
                break
            }else if(result){
                pilaCicl.pop()
                return result
            }
            if(desde.Expavance.Exp.Opder){
                var par1=desde.Expavance.Id
                var par2=NuevaOp(desde.Expavance.Exp.Opizq,desde.Expavance.Exp.Opder,desde.Expavance.Exp.Tipo)
                var par3=Asign(par1,par2)
                ExecAsign(par3,nuevito)
            }
            if(eject && eject.TipoIns=="continue"){
                continue
            }
        }
        pilaCicl.pop();
        return
    }
    //Objeto dado en taller de jison para realizar retornos
    const RETORNAR=function(Exp){
        return{
            Exp:Exp,
            TipoIns:"return"
        }
    }
    //Objeto para diferenciar las funciones
    const FUNCIONAR=function(id,param,tipo,area){
        return{
            id:id,
            Param:param,
            Tipo:tipo,
            Area:area,
            TipoIns:"funcion"
        }
    }
    //Funcion dada en taller de jison para ejecutar el contenido de una funcion
    function ExecFuncionar(elem,ent){
        var name=elem.id+"$"
        if(ent.Simbolos.has(name)){
            console.log("La funcion: ",elem.id," ya ha sido declarada anteriormente")
            errores+="La funcion: ",elem.id," ya ha sido declarada anteriormente\n"
            return;
        }
        ent.Simbolos.set(name,elem)
    }
    //Objeto para diferencias las llamadas
    const LLAMADA=function(id,param){
        return{
            Id:id,
            Param:param,
            TipoIns:"llamada"
        }
    }
    //Funcion dada en taller de jison para llamadas a metodos y funciones
    function ExecLlamar(llamada,ent){
        var name=llamada.Id+"$"
        var resul=[]
        for(var params of llamada.Param){
            var val=evaluar(params,ent)
           
            resul.push(val)
        }
        var temporal=ent
        var simbol=null
        while(temporal!=null){
            if(temporal.Simbolos.has(name)){
                simbol=temporal.Simbolos.get(name)
                break
            }
            temporal=temporal.anterior
        }
        if(!simbol){
            console.log("No se encontro la funcion: ",llamada.Id," con los parametros indicados")
            errores+="No se encontro la funcion: ",llamada.Id," con los parametros indicados\n"
            return NuevoSimbolo("@error@","error")
        }
        pilaFun.push(llamada.Id)
        var nuevito=Entorno(Global)
        var indice=0
        for(var creacion of simbol.Param){
            creacion.Exp=resul[indice]
            ExecCrear(creacion,nuevito)
            indice++
        }
        var retorno=NuevoSimbolo("@error@","error")
        var result=EjectBloque(simbol.Area,nuevito)
        if(result){
            if(result.Tipo=="void"){
                if(simbol.Tipo!="void"){
                console.log("No se espera un retorno")
                errores+="No se espera un retorno"
                
                }else{
                retorno=NuevoSimbolo("@void@","void")

                }
            }else{
                var expresion=evaluar(result,nuevito)
                if(expresion.Tipo!=simbol.Tipo){
                    console.log("El tipo a retornar no coindice con el indicado")
                    errores+="El tipo a retornar no coindice con el indicado\n"
                    retorno=NuevoSimbolo("@error@","error")
                }else{
                    retorno=expresion
                }
            }
        }else{
            if(simbol.Tipo!="void"){
                console.log("Se espera algo a retornar")
                errores+="Se espera algo a retornar\n"
                retorno=NuevoSimbolo("@error@","error")

            }else{
                retorno=NuevoSimbolo("@void@","void")
            }
        }
        pilaFun.pop()
        return retorno
    }
    //objeto a utilizar para realizar operaciones ++ y --
    const Incrementos=function(id,Exp){
        return{
            
            Id:id,
            Exp:Exp

        }

    }
    //objeto para diferencias los casteos entre datos
    const Cambios=function(val,Tipo){
        return{
            Valor:val,
            Tipo:Tipo,
            TipoIns:"cambio"
        }
    }
    //Funcion a ejecutar para realizar casteos entre diferentes datos
    function ExecCambios(cambio,ent){
        var evaluado=evaluar(cambio.Valor,ent)
        switch(evaluado.Tipo){
            case "int":
                switch(cambio.Tipo){
                    case "double":
                        return NuevoSimbolo(evaluado.Valor,"double")
                        break
                    case "char":
                        var nuevo=String.fromCharCode(evaluado.Valor)+"";
                        return NuevoSimbolo(nuevo,"char")
                        break
                    case "String":
                        return NuevoSimbolo(evaluado.Valor+"","String")
                        break
                    case "int":
                        
                        return NuevoSimbolo(evaluado.Valor,"int")
                    default:
                        console.log("Tipo de dato incorrecto")
                        errores+="Tipo de dato incorrecton\n"
                        return NuevoSimbolo("@error@","error")
                    
                }
            case "double":
                switch(cambio.Tipo){
                    case "int":
                        var nuevo=Math.trunc(evaluado.Valor)
                        return NuevoSimbolo(nuevo,"int")
                        break
                    case "String":
                        return NuevoSimbolo(evaluado.Valor+"","String")
                        break
                    case "double":
                        
                        return NuevoSimbolo(evaluado.Valor,"double")
                    default:
                        console.log("Tipo de dato incorrecto")
                         errores+="Tipo de dato incorrecton\n"
                        return NuevoSimbolo("@error@","error")
                    
                }
            case "char":
                switch(cambio.Tipo){
                    case "int":
                        var nuevo=evaluado.Valor.charCodeAt(0)
                        return NuevoSimbolo(nuevo,"int")
                        break
                    case "double":
                        var nuevo=evaluado.Valor.charCodeAt(0)
                        return NuevoSimbolo(nuevo,"double")
                        break
                    case "char":
                        return NuevoSimbolo(evaluado.Valor,"char")
                    default:
                        console.log("Tipo de dato incorrecto")
                         errores+="Tipo de dato incorrecton\n"
                        return NuevoSimbolo("@error@","error")
                    
                }
           
            
            
                    
                
        }
    }
    //objeto para diferencias los casteos
    const Letras=function(val,Tipo){
        return{
            Valor:val,
            Tipo:Tipo,
            TipoIns:"mayus"
        }
    }
    //Funcion a ejecutar para realizar los casteos y funciones lower y upper
    function ExecLetras(mayus,ent){
        var evaluado=evaluar(mayus.Valor,ent)
        switch(mayus.Tipo){
            case "String":
                switch(evaluado.Tipo){
                    case "double":
                        return NuevoSimbolo(evaluado.Valor,"String")
                    
                    case "bool":
                        return NuevoSimbolo(evaluado.Valor+"","String")
                    case "int":
                        return NuevoSimbolo(evaluado.Valor,"String")
                    case "char":
                            return NuevoSimbolo(evaluado.Valor+"","String")
                    case "String":
                        return NuevoSimbolo(evaluado.Valor,"String")
                    default:
                        console.log("Tipo no definido")
                        errores+="Tipo no definido\n"
                        return NuevoSimbolo("@error@","error")
                }
            case "upper":
            
                if(evaluado.Tipo=="String"){
                    var val=evaluado.Valor.toUpperCase()
                    return NuevoSimbolo(val,"String")
                }else{
                    console.log("La funcion upper solo funcion en Strings y el tipo de dato fue: "+evaluado.Tipo)
                    errores+="La funcion upper solo funcion en Strings y el tipo de dato fue: "+evaluado.Tipo+"\n"
                    return NuevoSimbolo("@error@","error")
                }
            case "lower":
                
                if(evaluado.Tipo=="String"){
                    var baj=evaluado.Valor.toLowerCase()
                    return NuevoSimbolo(baj,"String")
                }else{
                    console.log("La funcion lower solo funciona en Strings y el tipo de dato fue: "+evaluado.Tipo)
                    errores+="La funcion lower solo funciona en Strings y el tipo de dato fue: "+evaluado.Tipo+"\n"

                    return NuevoSimbolo("@error@","error")
                }
            case "typeof":
                if(evaluado.Tipo!="int" &&evaluado.Tipo!="double" &&evaluado.Tipo!="char"&&evaluado.Tipo!="String"&&evaluado.Tipo!="bool" ){
                    var temporal=ent
                    var encontrado=false
                    while(temporal!=null){
                        if(temporal.Simbolos.has(mayus.Valor.Valor+"")){
                            var val=temporal.Simbolos.get(mayus.Valor.Valor)
                            if(val[0]!="list"){
                                return NuevoSimbolo("array","String")
                            }else{
                                return NuevoSimbolo("lista","String")
                            }
                        }
                        temporal=temporal.anterior
                    }
                    console.log("no se encontro la variable deseada");
                    errores+="no se encontro la variable deseada\n"
                    return NuevoSimbolo("@error@","error")
                }else{
                    switch(evaluado.Tipo){
                        case "char":
                            return NuevoSimbolo("char","String")
                        case "int":
                            return NuevoSimbolo("int","String")
                        case "double":
                            return NuevoSimbolo("double","String")
                        case "bool":
                            return NuevoSimbolo("bool","String")
                        case "String":
                            return NuevoSimbolo("String","String")
                    }
                }
            case "length":
                if(evaluado.Tipo!="String" ){
                    var temporal=ent
                    var encontrado=false
                    while(temporal!=null){
                        if(temporal.Simbolos.has(mayus.Valor.Valor+"")){
                            var val=temporal.Simbolos.get(mayus.Valor.Valor)
                            if(val[0]!="list"){
                                var largo=val.length
                                return NuevoSimbolo(largo,"int")
                            }else{
                                var largo=val.length
                                return NuevoSimbolo(largo,"int")
                            }
                        }
                        temporal=temporal.anterior
                    }
                    console.log("no se encontro la variable deseada");
                    errores+="no se encontro la variable deseada\n"
                    return NuevoSimbolo("@error@","error")
                }else{
                    switch(evaluado.Tipo){
                        case "String":
                            var largo=length(evaluado.Valor)
                            return NuevoSimbolo(largo,"int")
                    }
                }

        }
    }
    //Objeto para poder diferencias redondeos
    const REDONDEOS=function(val,Tipo){
        return{
            Valor:val,
            Tipo:Tipo,
            TipoIns:"redondeos"
        }
    }
    //Funcion a ejecutar para lso redondeos y truncamientos
    function ExecRedondeos(red,ent){
        var evaluado=evaluar(red.Valor,ent)
        switch(red.Tipo){
            case "round":
                if(evaluado.Tipo=="double"){
                    var resultado=Math.round(evaluado.Valor)
                    return NuevoSimbolo(resultado,"int")
                }

            case "length":
                switch(evaluado.Tipo){
                    case "String":
                        var largo=evaluado.Valor.length
                        return NuevoSimbolo(largo,"int")
                        break;
                }
            case "truncate":
                if(evaluado.Tipo=="double"){
                    var resultado=Math.trunc(evaluado.Valor)
                    return NuevoSimbolo(resultado,"int")
                }
                
        }
    }

    const Continue=function(){
        TipoIns:"continue"
    }
    

    
%}

%lex


%options case-insensitive

%%
"//".* {}
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/] {}
[ \t\r]+ {}

//tipos de datos

"int"   return "int";
"double" return "Double";
"boolean" return "Boolean";
"char"  return "Char";
"String"    return "String";

"break" return "RBREAK";

"if" return "Rif";
"else" return "Relse";

"switch" return "RSWITCH"
"case" return "RCASE"
"Default" return "RDEFAULT"

"while" return "RWHILE"

"for" return "RFOR"
"funcion" return "RFUNCION"
"void" return "RVOID"
"return" return "RRETURN"
"toLower" return "RTOLOWER"
"toUpper" return "RTOUPPER"
"toString" return "RTOSTRING"
"truncate" return "RTRUNCATE"
"round" return "RROUND"
"new" return "NUEVO"
"typeof" return "RTYPE"
"length" return "RLENGTH"
"do" return "RDO"



\n {};
"print" return "IMPRIMIR";
";" return "PTCOMA";
"," return "COMITA"
"(" return "PARABRE";
")" return "PARCIERRA";
"true" return "TRUE";
"false" return "FALSE";
">=" return "MAYORIG";
"<=" return "MENORIG";
"==" return "IGUALACION";
"!=" return "DIFERENTE";
"=" return "IGUAL";
"+" return "MAS";
"-" return "MENOS";
"*" return "POR";
"/" return "DIV";
"%" return "MODULO";
">" return "MAYOR";
"<" return "MENOR";
"&&" return "AND";
"||" return "OR";
"!" return "NOT";
"{" return "LABRE";
"}" return "LCIERRA";
":" return "DPUNTOS"
"[" return "CORABRE"
"]" return "CORCIERRA"
"." return "RPUNTO"
"list" return "RLISTITA"
"add" return "RADD"
"exec" return "REXEC"
"^" return "RELEVAR"

[0-9]+("."[0-9]+)+\b return "DECIMAL"
[0-9]+\b return "NUMERO"
[a-zA-Z][a-zA-Z0-9_]* return "ID"
\"((\\\")|[^\n\"])*\" {yytext=yytext.substr(1,yyleng-2); return "Cadena"}
\'((\\\')|[^\n\'])*\' {yytext=yytext.substr(1,yyleng-2); return "RCHAR"}
<<EOF>> return 'EOF';

. {console.log("El simbolo "+yytext+" no se reconoce")}

/lex
%left "OR"
%left "AND"
%right "NOT"
%left "IGUALACION" "DIFERENTE"
%left "MENOR" "MAYOR" "MENORIG" "MAYORIG"
%left "MAS" "MENOS"
%left "POR" "DIV" "MODULO"
%left "RELEVAR"
%left UMENOS
%right CASTEO



%start ini


%%


ini:LINS EOF {console.log(JSON.stringify($1,null,2)); console.log(consolita); EjectBloque($1,Global); return{consola:consolita,arbol:JSON.stringify($1,null,2),error:errores};}
| error EOF {console.log("Sintactico","Error en : '"+yytext+"'",this._$.first_line,this._$.first_column);}
;

LINS:LINS INS {$$=$1; $$.push($2);}
|INS {$$=[]; $$.push($1);}
;

INS: IMPRIMIR PARABRE EXP PARCIERRA PTCOMA{$$=Imprimir($3,"imprimir");}
|CREAR PTCOMA{$$=$1;}
|ASIGNAR PTCOMA{$$=$1}
|IF {$$=$1}
|SWITCH {$$=$1}
|RBREAK PTCOMA {$$=ROMPER()}
|RCONTINUAR PTCOMA{$$=Continue()}
|MIENTRAS{$$=$1}
|MIENTRAS2 PTCOMA{$$=$1}
|DESDE{$$=$1}
|FUNCION {$$=$1;}
|LLAMAR PTCOMA {$$=$1;}
|RETORNAR

;

RETORNAR:RRETURN EXP PTCOMA {$$=RETORNAR($2)}
|RRETURN PTCOMA {$$=RETORNAR(NuevoSimbolo("@vacio@","vacio"))}
;

CREAR: TIPO ID {$$=Creacion($2,$1,null,null,null);}
|TIPO ID IGUAL EXP {$$=Creacion($2,$1,$4,null,null);}
|TIPO CORABRE CORCIERRA ID IGUAL NUEVO TIPO CORABRE EXP CORCIERRA {$$=Creacion($4,$1,null,$7,$9)}
|TIPO CORABRE CORCIERRA ID IGUAL LABRE LISTAEXP LCIERRA {$$=Creacion($4,$1,$7,$1,null)}
|RLISTITA MENOR TIPO MAYOR ID IGUAL NUEVO RLISTITA MENOR TIPO MAYOR {$$=Creacion($5,$3,null,$10,null)}
;

FUNCION:TIPO ID PARABRE PARCIERRA AREA{$$=FUNCIONAR($2,[],$1,$5)}
|TIPO ID PARABRE PARAMS PARCIERRA AREA {$$=FUNCIONAR($2,$4,$1,$6)}
|RVOID ID PARABRE PARAMS PARCIERRA AREA{$$=FUNCIONAR($2,$4,"void",$6)}
|RVOID ID PARABRE PARCIERRA AREA{$$=FUNCIONAR($2,[],"void",$5)}
;

LLAMAR:ID PARABRE PARCIERRA{$$=LLAMADA($1,[])}
|ID PARABRE LISTAEXP PARCIERRA{$$=LLAMADA($1,$3)}
|REXEC ID PARABRE LISTAEXP PARCIERRA{$$=LLAMADA($2,$4)}
|REXEC ID PARABRE PARCIERRA{$$=LLAMADA($2,[])}

;

PARAMS:PARAMS COMITA TIPO ID {$$=$1;$$.push(Creacion($4,$3,null))}
|TIPO ID {$$=[];$$.push(Creacion($2,$1,null))}
;

ASIGNAR: ID IGUAL EXP{$$=Asign($1,$3,null)}
|ID CAMBIAR {$$=Asign($1,NuevaOp(NuevoSimbolo($1,"ID"),NuevoSimbolo(parseFloat(1),"int"),$2))}
|ID CORABRE EXP CORCIERRA IGUAL EXP{$$=Asign($1,$6,$3)}
|ID RPUNTO RADD PARABRE EXP PARCIERRA {$$=Asign($1,$5,NuevoSimbolo("nada","list"))}
|ID CORABRE CORABRE EXP CORCIERRA CORCIERRA IGUAL EXP{$$=Asign($1,$8,NuevaOp($4,NuevoSimbolo(1,"int"),"+"))}
;

CAMBIAR:MENOS MENOS {$$=$1}
|MAS MAS {$$=$1}
;

IF: Rif PARABRE EXP PARCIERRA AREA {$$=SI($3,$5,null);}
| Rif PARABRE EXP PARCIERRA AREA Relse AREA{$$=SI($3,$5,$7);}
| Rif PARABRE EXP PARCIERRA AREA Relse IF
;

SWITCH:RSWITCH PARABRE EXP PARCIERRA LABRE LCASES LCIERRA {$$=SWITCHI($3,$6,null);}
|RSWITCH PARABRE EXP PARCIERRA LABRE LCASES RDEFAULT AREA LCIERRA {$$=SWITCHI($3,$6,$8);}
;

LCASES:LCASES RCASE EXP AREA{$$=$1; $$.push(Cases($3,$4));}
|RCASE EXP AREA {$$=[]; $$.push(Cases($2,$3));}
;
AREA: LABRE LINS LCIERRA {$$=$2;}
|LABRE LCIERRA {$$=[];}
;

MIENTRAS: RWHILE PARABRE EXP PARCIERRA AREA{$$=WHILES($3,$5)}
;
MIENTRAS2:RDO AREA RWHILE PARABRE EXP PARCIERRA {$$=WHILES2($5,$2)}
;
DESDE: RFOR PARABRE CREAR PTCOMA EXP PTCOMA INCREMENTO PARCIERRA AREA {$$=FORES($3,$5,$7,$9)}
|RFOR PARABRE ASIGNAR PTCOMA EXP PTCOMA INCREMENTO PARCIERRA AREA {$$=FORES($3,$5,$7,$9)}
;

INCREMENTO:ID CAMBIAR {$$=Incrementos($1,NuevaOp(NuevoSimbolo($1,"ID"),NuevoSimbolo(parseFloat(1),"int"),$2))}
|ID IGUAL EXP {$$=Incrementos($1,$3)}
;




TIPO: int{$$=$1}
|Double {$$=$1}
|Boolean {$$=$1}
|String {$$=$1}
|Char {$$=$1}

;



    EXP: EXP MAS EXP {$$=NuevaOp($1,$3,"+");}
    | EXP MENOS EXP {$$=NuevaOp($1,$3,"-");}
    | EXP POR EXP {$$=NuevaOp($1,$3,"*");}
    |EXP DIV EXP {$$=NuevaOp($1,$3,"/");}
    |EXP MODULO EXP {$$=NuevaOp($1,$3,"%");}
    |EXP RELEVAR EXP{$$=NuevaOp($1,$3,"^")}
    |EXP IGUALACION EXP {$$=NuevaOp($1,$3,"==");}
    |EXP DIFERENTE EXP {$$=NuevaOp($1,$3,"!=");}
    |EXP MENOR EXP {$$=NuevaOp($1,$3,"<");}
    |EXP MAYOR EXP {$$=NuevaOp($1,$3,">");}
    |EXP MENORIG EXP {$$=NuevaOp($1,$3,"<=");}
    |EXP MAYORIG EXP {$$=NuevaOp($1,$3,">=");}
    |EXP AND EXP {$$=NuevaOp($1,$3,"and");}
    |EXP OR EXP {$$=NuevaOp($1,$3,"or");}
    |EXP MENOS MENOS {$$=NuevaOp($1,NuevoSimbolo(parseFloat(1),"int"),"-")}
    |EXP MAS MAS {$$=NuevaOp($1,NuevoSimbolo(parseFloat(1),"int"),"+")}
    |NOT EXP {$$=OperaUna($2,"not");}
    |MENOS EXP %prec UMENOS {$$=OperaUna($2,"umenos");}
    |PARABRE EXP PARCIERRA {$$=$2}
    |TRUE {$$=NuevoSimbolo(true,"bool");}
    |FALSE {$$=NuevoSimbolo(false,"bool");}
    |Cadena {$$=NuevoSimbolo($1,"String");}
    |DECIMAL {$$=NuevoSimbolo($1,"double");}
    |NUMERO {$$=NuevoSimbolo($1,"int");}
    |ID {$$=NuevoSimbolo($1,"ID");}
    |RCHAR {$$=NuevoSimbolo($1,"char");}
    |ID PARABRE PARCIERRA {$$=NuevoSimbolo({Exp:$1,Param:[]},"funcion")}
    |ID PARABRE LISTAEXP PARCIERRA {$$=NuevoSimbolo({Exp:$1,Param:$3 },"funcion")}
    |PARABRE TIPO PARCIERRA EXP %prec CASTEO {$$=NuevoSimbolo({Exp:$4,Tipo:$2},"cambio")}
    |RTOUPPER PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"mayus",$3,"upper")}
    |RTOLOWER PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"mayus",$3,"lower")}
    |RTOSTRING PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"mayus",$3,"String")}
    |RROUND PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"redondeos",$3,"round")}
    |RTRUNCATE PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"redondeos",$3,"truncate")}
    |RTYPE PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"mayus",$3,"typeof")}
    |RLENGTH PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo(null,"mayus",$3,"length")}
    |ID CORABRE EXP CORCIERRA{$$=NuevoSimbolo(null,"array",$1,$3)}
    |ID CORABRE CORABRE EXP CORCIERRA CORCIERRA {$$=NuevoSimbolo(null,"list",$1,$4)}
;

LISTAEXP:LISTAEXP COMITA EXP{$$=$1;$$.push($3)}
|EXP {$$=[];$$.push($1)}
;
