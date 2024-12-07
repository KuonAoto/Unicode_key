; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#include "p16f887.inc"
; CONFIG1
; __config 0x27C4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
  ;レジスタ定義
    CBLOCK	0x20
	w_tmp	    ;割り込みハンドラ用
	status_tmp  ;割り込みハンドラ用
	
	tmp_xor	    ;XOR退避用
	
	inp_num	    ;入力した数字
	
	inp_func    ;入力したファンクションキー
	
	num_count   ;入力判定用カウンタ
	
	old_a	    ;一周前の入力情報
	old_b
	old_c
	old_d
	old_e
	
	now_a	    ;今の入力情報
	now_b
	now_c
	now_d
	now_e
    
    ENDC
 
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START

   
    
    
setup:
    
    
    banksel ANSEL
    CLRF    ANSEL	    ;すべてデジタル
    CLRF    ANSELH	    ;8～13も同様に
    
    CLRF    INTCON	    ;割り込み禁止
    
    banksel OSCCON
    MOVLW   B'01110100'
    MOVWF   OSCCON	    ;内部クロックで8Mhzに設計
    
    banksel TRISA
    MOVLW   b'00111111'	    ;RA0～RA5まで入力
    MOVWF   TRISA
    MOVLW   0xFF	    ;すべて入力
    MOVWF   TRISB
    MOVLW   b'10000000'	    ;RX（RC7）のみ入力設定
    MOVWF   TRISC
    MOVLW   0xFF	    ;すべて入力
    MOVWF   TRISD
    MOVLW   b'00000011'	    ;RE0とRE1のみ入力
    MOVWF   TRISE
    
    banksel PORTA
    CLRF    PORTA	    ;ポートの初期化
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE	
    
    banksel TXSTA
    MOVLW   b'00100100'
    MOVWF   TXSTA	    ;非同期モード　8ビット　パリティなし
    banksel RCSTA
    MOVLW   b'10010000'    
    MOVWF   RCSTA   ;受信情報設定
    
    banksel SPBRG
    MOVLW   D'51'	    ;9600ボー
    MOVWF   SPBRG	    
    
    BCF	    STATUS,RP0
    BCF	    STATUS,RP1
    
    MOVF    PORTB,w	    ;0～7までのスイッチの入力を取ってくる
    MOVWF   now_b
    MOVWF   old_b

    MOVFW   PORTD	    ;8～Fまでのスイッチの入力を取ってくる
    MOVWF   now_d
    MOVWF   old_d
    
main_loop:
    
    CALL    check_b
    CALL    check_d
    
    
    CALL    mov_old
    
    GOTO    main_loop
    
    
    
    
check_b: 
    
    MOVFW   PORTB	    ;0～7までのスイッチの入力を取ってくる
    MOVWF   now_b
    XORWF   old_b,w	    ;一個昔の値とXORすることで変わったかを判定
    BTFSC   STATUS,Z	    ;変わってなかったらdのチェックに移る
    RETURN
    MOVWF   tmp_xor
    ANDWF   now_b,w	    ;押したときか離したときか判定
    BTFSS   STATUS,Z	    ;離した時だった場合dのチェックに移る
    RETURN	
    
    ;押したとき
    CALL    check_inpnum    ;0001 0000ー＞4
    MOVLW   0x30
    IORWF   num_count,w
    ;MOVFW   num_count	    ;inp_numに移動
    MOVWF   inp_num
    CALL    send_ASCII
    RETURN
    
    
check_d:
    RETURN
    
;tmp_xorに入れてここにとばす
;返り値　num_count
check_inpnum:
    
    CLRF   num_count	;カウントリセット
    
check_inpnum_loop:
    BTFSC   tmp_xor,0	    ;0ビット目が0だったら次スキップ
    RETURN
    RRF	    tmp_xor	    ;右シフト
    INCF    num_count,f	    ;カウントをインクリメントしてループ
    GOTO    check_inpnum_loop
    
    
mov_old:
    MOVFW   now_a
    MOVWF   old_a
    MOVFW   now_b
    MOVWF   old_b
    MOVFW   now_c
    MOVWF   old_c
    MOVFW   now_d
    MOVWF   old_d
    RETURN

;wレジスタに値をいれてここに飛ばす
send_ASCII:
    banksel TXREG
    
send_wait:
    BTFSS   PIR1,TXIF
    GOTO    send_wait
    MOVWF   TXREG
    RETURN
    
END