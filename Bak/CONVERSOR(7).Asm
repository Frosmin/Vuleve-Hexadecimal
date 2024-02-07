format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana_1	equ		1
salir_btn	equ		1000

section '.data' data readable writeable

Ist  dd 0
pWnd dd 0

monto dd 0

;boliviano, euro, dolar

boliviano dd 1, 14, 13 

euro dd 747, 1, 108 

dolar dd 691, 92, 1


miMoneda dd 0

cambioA dd 0




item1 db 'First Item', 0
item2 db 'Second Item', 0
 
section '.code' code readable executable
 
macro origen{
	local .bol, .eur, .dol, .fin

	invoke IsDlgButtonChecked,[pWnd],3001
	cmp eax, 1
	je .bol
	
	invoke IsDlgButtonChecked,[pWnd],3002
	cmp eax, 1
	je .eur
	
	invoke IsDlgButtonChecked,[pWnd],3003
	cmp eax, 1
	je .dol
	
	.bol:	
	mov eax, boliviano
	mov [miMoneda], eax
	jmp .fin
	
	.eur:
	mov eax, euro
	mov [miMoneda], eax
	jmp .fin
	
	.dol:
	mov eax, dolar
	mov [miMoneda], eax
	jmp .fin
	
	.fin:
}

macro calcularCambio{
	
	mov edi, 0
	mov ecx, 0
	mov esi, 0
	
	mov edi,[cambioA]

	mov esi,[miMoneda]
	mov ecx,[esi+edi]
	
	mov eax,[monto]
	
	imul ecx
	
	mov [monto], eax
}


macro convertir{
	
	invoke GetDlgItemInt,[pWnd],5001,0,FALSE
	mov [monto], eax
	
	origen
	
	calcularCambio
	
	invoke SetDlgItemInt,[pWnd],5002,[monto],FALSE
	
 }

 	
inicio:

	invoke SendMessage, 6001, CB_ADDSTRING, 0,item1
	invoke SendMessage, 6001, CB_ADDSTRING, 0,[item2]
	invoke GetModuleHandle,0
	mov [Ist],eax
	invoke DialogBoxParam,eax,ventana_1,0,DlgProc,0 
fin:
	invoke ExitProcess,0

proc DlgProc,hWnd,uMsg,wParam,lParam
	push edi esi ebx
	
	mov eax,[uMsg]
	cmp	eax,WM_COMMAND
	je	jCOMMAND
	cmp	eax,WM_INITDIALOG
	je	jINITDIALOG
	cmp	eax,WM_CLOSE
	je	jCLOSE
	xor eax,eax
	jmp finish

jINITDIALOG:
	mov eax,[hWnd]
	mov [pWnd],eax
	
	mov eax,1
	jmp finish
	
jCOMMAND:
	mov eax,[wParam]
	
;	cmp eax, 1004
;	je convertir
	
	cmp eax, 1001
	je A_boliviano
	cmp eax, 1002
	je A_euro
	cmp eax, 1003
	je A_dolar
	
	cmp	eax,salir_btn
	je	salir
	xor eax,eax
	jmp finish

A_boliviano:
	mov [cambioA],0
	convertir
	mov eax,1
	jmp finish
A_euro:
	mov [cambioA],4
	convertir
	mov eax,1
	jmp finish
A_dolar:
	mov [cambioA],8
	convertir
	mov eax,1
	jmp finish
	
salir:
	invoke SendMessage,[hWnd],WM_CLOSE,0,0
	mov eax,1
	jmp finish
	
;convertir:
;	invoke GetDlgItemInt,[pWnd],5001,0,FALSE
;	mov [monto], eax
;	
;	origen
;	
;	calcularCambio
;	
;	
;	invoke SetDlgItemInt,[pWnd],5002,[monto],FALSE
;	
;	mov eax,1
;	jmp finish									
	
jCLOSE:	
	invoke EndDialog,[hWnd],0
	mov eax,1
	
finish:
	pop ebx esi edi
	ret
endp

section '.idata' import data readable writeable
  ;importamos solo los procedimientos basicos para abrir una ventana

  ;otra forma para importar los procedimientos importando archivos INC
  library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\gdi32.inc'

section '.rsrc' resource from 'CONVERSOR.res' data readable
