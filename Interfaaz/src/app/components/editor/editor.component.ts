import { Component, OnInit, ViewChild } from '@angular/core';
import { FormControl } from '@angular/forms';
import { Observable } from 'rxjs';
//importamos para el editor
import { filter, take } from 'rxjs/operators';
import {
  MonacoEditorComponent,
  MonacoEditorConstructionOptions,
  MonacoEditorLoaderService,
  MonacoStandaloneCodeEditor
} from '@materia-ui/ngx-monaco-editor';
import { AnalizarService } from 'src/app/services/analizar/analizar.service';
import{HtmlInputEvent} from '../pruebas';
import { saveAs } from 'file-saver';

@Component({
  selector: 'app-editor',
  templateUrl: './editor.component.html',
  styleUrls: ['./editor.component.css']
})
export class EditorComponent implements OnInit {
  
  @ViewChild(MonacoEditorComponent, { static: false })
  monacoComponent: MonacoEditorComponent = new MonacoEditorComponent(this.monacoLoaderService);
  editorOptions: MonacoEditorConstructionOptions = {
    theme: 'myCustomTheme',
    language: 'javascript',
    roundedSelection: true,
    autoIndent:"full"
  };
  consoleOptions: MonacoEditorConstructionOptions = {
    theme: 'myCustomTheme',
    language: '',
    roundedSelection: true,
    autoIndent:"full",
    readOnly:true
  };

  code = "";
  editorTexto = new FormControl('');
  console = "";
  consola = new FormControl('');
  pruebas:string|ArrayBuffer|undefined
  file:File|undefined
  
  constructor(private monacoLoaderService: MonacoEditorLoaderService, private analizarService: AnalizarService) {
    this.monacoLoaderService.isMonacoLoaded$
      .pipe(
        filter(isLoaded => isLoaded),
        take(1)
      )
      .subscribe(() => {
        monaco.editor.defineTheme('myCustomTheme', {
          base: 'vs-dark', // can also be vs or hc-black
          inherit: true, // can also be false to completely replace the builtin rules
          rules: [
            {
              token: 'comment',
              foreground: 'ffa500',
              fontStyle: 'italic underline'
            },
            { token: 'comment.js', foreground: '008800', fontStyle: 'bold' },
            { token: 'comment.css', foreground: '0000ff' } // will inherit fontStyle from `comment` above
          ],
          colors: {}
        });
      });
  }
  editorInit(editor: MonacoStandaloneCodeEditor) {
    // monaco.editor.setTheme('vs');
    editor.setSelection({
      startLineNumber: 1,
      startColumn: 1,
      endColumn: 50,
      endLineNumber: 3
    });
  }

  ngOnInit(): void {
  }

  imprimir(){
    console.log(this.consola.value)
    console.log(this.editorTexto.value)
  }

  analizar(){
    var texto = {
      prueba: this.editorTexto.value
    }
    this.analizarService.ejecutar(texto).subscribe((res:any)=>{
      console.log(res)
      this.consola.setValue(res.consola);
    }, err=>{
      console.log(err)
    });
  }

  Archivo(eve:any){
    let arch=eve.target.files[0]
    let prueba=""
    if(arch){
      let reader=new FileReader()
      reader.onload=ev=>{
        const resultado=ev.target?.result
        prueba=String(resultado)
        console.log(resultado)
        console.log(prueba)
        this.code=prueba.toString();
        
      }
      
      reader.readAsText(arch)
    }
     
  }
  guardadito() {
    const blob = 
        new Blob([
                 this.code], 
                 {type: "text/plain;charset=utf-8"});
    saveAs(blob, "nombreArchivo.ty");
}

}
