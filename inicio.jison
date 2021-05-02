%{
    var Simbolos=new Map();
    var pilaCicl=[];
    var pilaFun=[];
    var consolita=""
    var consolita2=""

    const Entorno=function(anterior){
        return{
            Simbolos:new Map(),
            anterior:anterior
        }
    }

    var Global=Entorno(null)

    function NuevoSimbolo(valor,tipo){
        return{
            Valor:valor,
            Tipo:tipo
        }
    }

    function NuevaOp(Operandoizq,Operandoder,tipo){
        return{
            Opizq:Operandoizq,
            Opder:Operandoder,
            Tipo:tipo
        }
    }
    const Imprimir=function(Exp,tipo){

        return{
            Exp:Exp,
            TipoIns:tipo
        }

    }

    function OperaUna(Operandoizq,tipo){
        return{
            Opizq:Operandoizq,
            Opder:null,
            Tipo:tipo
        }
    }

    function EjectBloque(LINS,ent){
        var retu=null;
        for(var elemento of LINS){
       
            switch(elemento.TipoIns){
                case "imprimir":
                    var e=evaluar(elemento.Exp,ent);
                    console.log(e.Valor);
                    consolita+=String(e.Valor)+"\n"
                    console.log(consolita)
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
                case "for":
                    retu=ExecFores(elemento,ent)
                    break
                case "funcion":
                    retu=ExecFuncionar(elemento,Global)
                    break
                case "llamada":
                    retu=ExecLlamar(elemento,ent)
                    break
                case "return":
                    if(pilaFun.length>0){
                        retu=elemento.Exp
                    }else{
                        console.log("Instruccion return fuera de una funcion o metodo")
                    }
                    break
                case "break":
                    if(pilaCicl.length>0){
                    return elemento
                    }else{
                        console.log("Break fuera de un switch o ciclo detectado")
                    }
                    break;
            }
            if(retu){
                
                return retu
            }
        }
        
        return null
    }

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
                return NuevoSimbolo("@error@","error");
            case "cambio":
                var result=ExecCambios(Cambios(operacion.Valor.Id,operacion.Valor.Tipo),ent)
                return result
            case "mayus":
                var result=ExecLetras(Letras(operacion.Valor.Id,operacion.Valor.Tipo),ent)
                return result
            case "funcion":
                var result=ExecLlamar(LLAMADA(operacion.Valor.Id,operacion.Valor.Param),ent)
                return result
            case "array":
                var temporal=ent
                while(temporal!=null){
                    if(temporal.Simbolos.has(operacion.Valor.Id)){
                        var val=temporal.Simbolos.get(operacion.Valor.Id)
                        if(operacion.Valor.Param.Tipo=="int" && operacion.Valor.Param.Valor>=0 &&operacion.Valor.Param.Valor<=(val.length-1)){
                            val=val[operacion.Valor.Param.Valor]
                            return NuevoSimbolo(val.Valor,val.Tipo)
                        }else{
                            console.log("La posicion: "+operacion.Valor.Param.Valor+" Se encuentra fuera del tamaño indicado anteriormente")
                            return NuevoSimbolo("@error@","error")
                        }
                    }
                    temporal=temporal.anterior
                }
                console.log("No existe el array"+operacion.Valor)
                return NuevoSimbolo("@error@","error")
                break
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
                                retorno="int"
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

    function ExecCrear(Crear,ent){
        if(ent.Simbolos.has(Crear.Id)){
            console.log("La variable: "+Crear.Id+" ya existe en este ambito")
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
                            if(val.Tipo==Crear.Tipo){
                                valor.push(val)
                            }else{
                                console.log("Los datos ingresados no coinciden con el tipo del array")
                                return
                            }
                        }
                    }else{
                        console.log("Los tipos de datos no coindicen con el del array")
                        return
                    }
                    
                }else{
                valor=evaluar(Crear.Exp,ent);
                if(valor.Tipo!=Crear.Tipo){
                    console.log("El tipo no coincide con la variable a crear")
                }
                }
                
            }else{
                if(Crear.Tipo2){
                    if (Crear.Tipo==Crear.Tipo2){
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
                        console.log("Los tipos de datos ingresados en el array no coinciden")
                        return
                    }
                }else{
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

    const Asign=function(id,Exp,Exp2){
        return{
            Id:id,
            Exp:Exp,
            TipoIns:"asignar",
            Exp2:Exp2
        }
    }

    const ExecAsign=function(asignar,ent){
        var val=evaluar(asignar.Exp,ent)
        var temporal=ent
        while(temporal!=null){
            if(temporal.Simbolos.has(asignar.Id)){
                var simbol=temporal.Simbolos.get(asignar.Id);
                if (simbol.Tipo=="double" && val.Tipo=="int"){
                    val.Tipo="double"
                }
                if (simbol.Tipo=="int"&& val.Tipo!="int"){
                    console.log("No son del mismo tipo: ",simbol.Tipo," double")
                    return
                }
                if(val.Tipo=="char"){
                    if(val.Valor.length!=0){
                        console.log("No se puede ingresar: "+val.Valor+" tipo de dato no compatible con char")
                        return
                    }
                }
                if(simbol.Tipo===val.Tipo){
                    temporal.Simbolos.set(asignar.Id,val);
                    return
                }else{
                    console.log("Tipos incompatibles: ",simbol.Tipo,",",val.Tipo)
                    return
                }
                
            }
            temporal=temporal.anterior
            
        }
        console.log("No se encontro la variable: ",asignar.Id)


    }

    const SI=function(Exp,AreaSi,AreaSiNo){
        return{
            Exp:Exp,
            AreaSi:AreaSi,
            AreaSiNo:AreaSiNo,
            TipoIns:"SI"
        }
    }

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
        }
    }

    const SWITCHI=function(Exp, Lcases,Default){
        return{
            Exp:Exp,
            Lcases:Lcases,
            Default:Default,
            TipoIns:"switch"
        }
    }

    const Cases=function(Exp,Area){
        return{
            Exp:Exp,
            Area:Area,
        }
    }

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

    const ROMPER=function(){
        return{
            TipoIns:"break"
        }
    }

    const WHILES=function(Exp,Area){
        return{
            Exp:Exp,
            Area:Area,
            TipoIns:"while"
        }
    }

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
                    }
                }else{
                    break
                }
            }else{
                console.log("Se esperaba una condicion dentro del ciclo while")
                pilaCicl.pop();
                return
            }
        }
    }

    const FORES=function(Expinicio,Expfin,Expavance,Area){
        return{
            Expinicio:Expinicio,
            Expfin:Expfin,
            Expavance:Expavance,
            Area:Area,
            TipoIns:"for"
        }
    }

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
            ExecAsign(Asign(desde.Expavance.Id,NuevaOp(desde.Expavance.Exp.Opizq,desde.Expavance.Exp.Opder,desde.Expavance.Exp.Tipo)),nuevito)
            }
        }
        pilaCicl.pop();
        return
    }
    const RETORNAR=function(Exp){
        return{
            Exp:Exp,
            TipoIns:"return"
        }
    }

    const FUNCIONAR=function(id,param,tipo,area){
        return{
            id:id,
            Param:param,
            Tipo:tipo,
            Area:area,
            TipoIns:"funcion"
        }
    }

    function ExecFuncionar(elem,ent){
        var name=elem.id+"$"
        if(ent.Simbolos.has(name)){
            console.log("La funcion: ",elem.id," ya ha sido declarada anteriormente")
            return;
        }
        ent.Simbolos.set(name,elem)
    }

    const LLAMADA=function(id,param){
        return{
            Id:id,
            Param:param,
            TipoIns:"llamada"
        }
    }

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
                
                }else{
                retorno=NuevoSimbolo("@vacio@","vacio")

                }
            }else{
                var expresion=evaluar(result,nuevito)
                if(expresion.Tipo!=simbol.Tipo){
                    console.log("El tipo a retornar no coindice con el indicado")
                    retorno=NuevoSimbolo("@error@","error")
                }else{
                    retorno=expresion
                }
            }
        }else{
            if(simbol.Tipo!="void"){
                console.log("Se espera algo a retornar")
                retorno=NuevoSimbolo("@error@","error")

            }else{
                retorno=NuevoSimbolo("@vacio@","vacio")
            }
        }
        pilaFun.pop()
        return retorno
    }

    const Incrementos=function(id,Exp){
        return{
            
            Id:id,
            Exp:Exp

        }

    }

    const Cambios=function(val,Tipo){
        return{
            Valor:val,
            Tipo:Tipo,
            TipoIns:"cambio"
        }
    }

    function ExecCambios(cambio,ent){
        switch(cambio.Valor.Tipo){
            case "int":
                switch(cambio.Tipo){
                    case "double":
                        return NuevoSimbolo(cambio.Valor.Valor,"double")
                        break
                    case "char":
                        var nuevo=String.fromCharCode(cambio.Valor.Valor)+"";
                        return NuevoSimbolo(nuevo,"char")
                        break
                    case "String":
                        return NuevoSimbolo(cambio.Valor.Valor+"","String")
                        break
                    default:
                        console.log("Tipo de dato incorrecto")
                        return NuevoSimbolo("@error@","error")
                    
                }
            case "double":
                switch(cambio.Tipo){
                    case "int":
                        var nuevo=Math.trunc(cambio.Valor.Valor)
                        return NuevoSimbolo(nuevo,"int")
                        break
                    case "String":
                        return NuevoSimbolo(cambio.Valor.Valor+"","String")
                        break
                    default:
                        console.log("Tipo de dato incorrecto")
                        return NuevoSimbolo("@error@","error")
                    
                }
            case "char":
                switch(cambio.Tipo){
                    case "int":
                        var nuevo=cambio.Valor.Valor.charCodeAt(0)
                        return NuevoSimbolo(nuevo,"int")
                        break
                    case "double":
                        var nuevo=cambio.Valor.Valor.charCodeAt(0)
                        return NuevoSimbolo(nuevo,"double")
                        break
                    default:
                        console.log("Tipo de dato incorrecto")
                        return NuevoSimbolo("@error@","error")
                    
                }
            case "ID":
                var esta=false
                var temporal=ent
                while(temporal!=null){
                    if(temporal.Simbolos.has(cambio.Valor.Valor+"")){
                        var val=temporal.Simbolos.get(cambio.Valor.Valor)
                        var cambiesito=Cambios(val,cambio.Tipo)
                        return ExecCambios(cambiesito,ent)
                    }
                    temp=temp.anterior
                }
                if(!esta){
                    console.log("No se detecto la variable")
                    return NuevoSimbolo("@error@","error")
                }
            
                    
                
        }
    }

    const Letras=function(val,Tipo){
        return{
            Valor:val,
            Tipo:Tipo,
            TipoIns:"mayus"
        }
    }

    function ExecLetras(mayus,ent){
        switch(mayus.Tipo){
            case "String":
                switch(mayus.Valor.Tipo){
                    case "double":
                        return NuevoSimbolo(mayus.Valor.Valor+"","String")
                    case "ID":
                        var temporal=ent
                        var esta=false
                        while(temporal!=null){
                            if(temporal.Simbolos.has(mayus.Valor.Valor+"")){
                                var val=temporal.Simbolos.get(mayus.Valor.Valor)
                                var camb=Letras(val,"String")
                                return ExecLetras(camb,ent)
                            }
                            temporal=temporal.anterior
                        }
                        if(!esta){
                            console.log("No se encontro la variable deseada")
                            return NuevoSimbolo("@error@","error")
                        }
                    case "bool":
                        return NuevoSimbolo(mayus.Valor.Valor+"","String")
                    case "int":
                        return NuevoSimbolo(mayus.Valor.Valor+"","String")
                    default:
                        console.log("Tipo no definido")
                        return NuevoSimbolo("@error@","error")
                }
            case "upper":
            if(mayus.Valor.Tipo=="ID"){
                    var temporal=ent
                    var esta=false
                    while(temporal!=null){
                        if(temporal.Simbolos.has(mayus.Valor.Valor+"")){
                            var val=temporal.Simbolos.get(mayus.Valor.Valor)
                            var camb=Letras(val,"upper")
                            return ExecLetras(camb,ent)
                        }
                        temporal=temporal.anterior
                    }
                    if(!esta){
                        console.log("No se encontro la variable")
                        return NuevoSimbolo("@error@","error")
                    }
                }
                if(mayus.Valor.Tipo=="String"){
                    var val=mayus.Valor.Valor.toUpperCase()
                    return NuevoSimbolo(val,"String")
                }else{
                    console.log("Error en la accion Upper")
                    return NuevoSimbolo("@error@","error")
                }
            case "lower":
                if(mayus.Valor.Tipo=="ID"){
                    var temporal=ent
                    var esta=false
                    while(temporal!=null){
                        if(temporal.Simbolos.has(mayus.Valor.Valor+"")){
                            var val=temporal.Simbolos.get(mayus.Valor.Valor)
                            var camb=Letras(val,"lower")
                            return ExecLetras(camb,ent)
                        }
                        temporal=temporal.anterior
                    }
                    if(!esta){
                        console.log("No se encontro la variable")
                        return NuevoSimbolo("@error@","error")
                    }
                }
                if(mayus.Valor.Tipo=="String"){
                    var baj=mayus.Valor.Valor.toLowerCase()
                    return NuevoSimbolo(baj,"String")
                }else{
                    console.log("Error en la accion Lower")
                    return NuevoSimbolo("@error@","error")
                }

        }
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
"Boolean" return "Boolean";
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
"new" return "NUEVO"




\n {};
"imprimir" return "IMPRIMIR";
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

[0-9]+("."[0-9]+)+\b return "DECIMAL"
[0-9]+\b return "NUMERO"
[a-zA-Z][a-zA-Z0-9_]* return "ID"
\"((\\\")|[^\n\"])*\" {yytext=yytext.substr(1,yyleng-2); return "Cadena"}
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
%left UMENOS
%right CASTEO



%start ini


%%


ini:LINS EOF {console.log(JSON.stringify($1,null,2)); console.log(consolita); EjectBloque($1,Global); return{consola:consolita};}
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
|MIENTRAS{$$=$1}
|DESDE{$$=$1}
|FUNCION {$$=$1;}
|LLAMAR PTCOMA {$$=$1;}
|RETORNAR

;

RETORNAR:RRETURN EXP PTCOMA {$$=RETORNAR($2)}
|RRETURN PTCOMA {$$=RETORNAR(NuevoSimbolo("@vacio@","vacio"))}
;

CREAR: TIPO ID {$$=Creacion($2,$1,null);}
|TIPO ID IGUAL EXP {$$=Creacion($2,$1,$4);}
|TIPO CORABRE CORCIERRA ID IGUAL NUEVO TIPO CORABRE EXP CORCIERRA {$$=Creacion($4,$1,null,$7,$9)}
|TIPO CORABRE CORCIERRA ID IGUAL LABRE LISTAEXP LCIERRA {$$=Creacion($4,$1,$7,$1,null)}
;

FUNCION:TIPO ID PARABRE PARCIERRA AREA{$$=FUNCIONAR($2,[],$1,$5)}
|TIPO ID PARABRE PARAMS PARCIERRA AREA {$$=FUNCIONAR($2,$4,$1,$6)}
|RVOID ID PARABRE PARAMS PARCIERRA AREA{$$=FUNCIONAR($2,$4,"void",$6)}
|RVOID ID PARABRE PARCIERRA AREA{$$=FUNCIONAR($2,[],"void",$5)}
;

LLAMAR:ID PARABRE PARCIERRA{$$=LLAMADA($1,[])}
|ID PARABRE LISTAEXP PARCIERRA{$$=LLAMADA($1,$3)}
;

PARAMS:PARAMS COMITA TIPO ID {$$=$1;$$.push(Creacion($4,$3,null))}
|TIPO ID {$$=[];$$.push(Creacion($2,$1,null))}
;

ASIGNAR: ID IGUAL EXP{$$=Asign($1,$3)}
|ID CAMBIAR {$$=Asign($1,NuevaOp(NuevoSimbolo($1,"ID"),NuevoSimbolo(parseFloat(1),"int"),$2))}
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
DESDE: RFOR PARABRE CREAR PTCOMA EXP PTCOMA INCREMENTO PARCIERRA AREA {$$=FORES($3,$5,$7,$9)}
|RFOR PARABRE ASIGNAR PTCOMA EXP PTCOMA INCREMENTO PARCIERRA AREA {$$=FORES($3,$5,$7,$9)}
;

INCREMENTO:ID CAMBIAR {$$=Incrementos($1,NuevaOp(NuevoSimbolo($1,"ID"),NuevoSimbolo(parseFloat(1),"int"),$2))}
|ID IGUAL EXP {$$=Incrementos($1,$3)}
;




TIPO: int{$$=$1}
|Double {$$=$1}
|Boolean {$$=$1}
|Char {$$=$1}
|String {$$=$1}
;



EXP: EXP MAS EXP {$$=NuevaOp($1,$3,"+");}
| EXP MENOS EXP {$$=NuevaOp($1,$3,"-");}
| EXP POR EXP {$$=NuevaOp($1,$3,"*");}
|EXP DIV EXP {$$=NuevaOp($1,$3,"/");}
|EXP MODULO EXP {$$=NuevaOp($1,$3,"%");}
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
|ID PARABRE PARCIERRA {$$=NuevoSimbolo({Id:$1,Param:[]},"funcion")}
|ID PARABRE LISTAEXP PARCIERRA {$$=NuevoSimbolo({Id:$1,Param:$3 },"funcion")}
|PARABRE TIPO PARCIERRA EXP %prec CASTEO {$$=NuevoSimbolo({Id:$4,Tipo:$2},"cambio")}
|RTOUPPER PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo({Id:$3,Tipo:"upper"},"mayus")}
|RTOLOWER PARABRE EXP PARCIERRA %prec CASTEO {$$=NuevoSimbolo({Id:$3,Tipo:"lower"},"mayus")}
|ID CORABRE EXP CORCIERRA{$$=NuevoSimbolo({Id:$1,Param:$3},"array")}
;

LISTAEXP:LISTAEXP COMITA EXP{$$=$1;$$.push($3)}
|EXP {$$=[];$$.push($1)}
;
