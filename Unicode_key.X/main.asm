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
	
	state_digit	;ステートフラグ
			;0は入力前、1は1桁目、2は2桁目、3は3桁目、4が4桁目
	
			
	digit0
	digit1		;それぞれの桁の数字
	digit2
	digit3
	digit4
	
	tmp_ASCII
	
	CNT1
	CNT2
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
    
    MOVFW   PORTE	    ;8～Fまでのスイッチの入力を取ってくる
    ANDLW   b'00000011'	    ;とりまマスク
    MOVWF   now_e
    MOVWF   old_e
    
    CLRF    state_digit
    
main_loop:
    
    CALL    check_b
    CALL    check_d
    CALL    check_e
    
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
    
    CALL    DLY		    ;チャタリング対策で待つ
    MOVFW   PORTB	    ;再びとって、
    SUBWF   now_b,w	    ;変わってなかったら押した判定
    BTFSS   STATUS,Z
    RETURN
    
    ;押した判定
    CALL    check_inpnum    ;0001 0000ー＞4
    MOVFW   num_count	    ;inp_numに移動
    MOVWF   inp_num
    CALL    state_check
    RETURN
    
    
check_d:
    
    MOVFW   PORTD	    ;8～Fまでのスイッチの入力を取ってくる
    MOVWF   now_d
    XORWF   old_d,w	    ;一個昔の値とXORすることで変わったかを判定
    BTFSC   STATUS,Z	    ;変わってなかったら次のチェックに移る
    RETURN
    MOVWF   tmp_xor
    ANDWF   now_d,w	    ;押したときか離したときか判定
    BTFSS   STATUS,Z	    ;離した時だった場合dのチェックに移る
    RETURN	
    
    ;押したとき
    
    CALL    DLY		    ;チャタリング対策で待つ
    MOVFW   PORTD   	    ;再びとって、
    SUBWF   now_d,w	    ;変わってなかったら押した判定
    BTFSS   STATUS,Z
    RETURN
    
    ;押した判定
    CALL    check_inpnum    ;0001 0000ー＞4
    MOVLW   0x08
    ADDWF   num_count,w
    MOVWF   inp_num
    CALL    state_check
    RETURN
    
    
check_e: 
    
    MOVFW   PORTE	    ;0～7までのスイッチの入力を取ってくる
    ANDLW   b'00000011'	    ;とりまマスク
    MOVWF   now_e
    XORWF   old_e,w	    ;一個昔の値とXORすることで変わったかを判定
    BTFSC   STATUS,Z	    ;変わってなかったらdのチェックに移る
    RETURN
    MOVWF   tmp_xor
    ANDWF   now_e,w	    ;押したときか離したときか判定
    BTFSS   STATUS,Z	    ;離した時だった場合dのチェックに移る
    RETURN	
    
    ;押したとき
    
    CALL    DLY		    ;チャタリング対策で待つ
    MOVFW   PORTE	    ;再びとって、
    ANDLW   b'00000011'	    ;とりまマスク
    SUBWF   now_e,w	    ;変わってなかったら押した判定
    BTFSS   STATUS,Z
    RETURN
    
    ;押した判定
    CALL    check_inpnum    ;0001 0000ー＞4
    MOVFW   num_count	    ;inp_numに移動
    MOVWF   inp_num
    CALL    cr_bs
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
    MOVFW   now_e
    MOVWF   old_e 
    RETURN

;ステートごとの処理
;入力したい数字はinp_numに入れて持ってくる
state_check:
    MOVLW   0x00
    SUBWF   state_digit,w
    BTFSC   STATUS,Z	    ;0だったら0の処理に飛ぶ
    GOTO    state0
    
    ;0じゃなった場合
    MOVFW   inp_num
    CALL    change_ASCII
    CALL    send_ASCII	    ;とりまinp_numを送る
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    
    INCF    state_digit,f
    MOVLW   0x04
    SUBWF   state_digit,w
    BTFSS   STATUS,Z	    
    RETURN		    ;4以外の時は何もせずに戻る
    CLRF    state_digit	    ;4になったら0に戻す
    
    RETURN
    
state0:
    ;初めのUを送信
    MOVLW   'U'
    CALL    send_ASCII
    
    MOVFW   PORTA
    ANDLW   b'00111111'	    ;とりまマスク
    MOVWF   now_a
    
    BTFSS   now_a,0	    ;RA0が1（押されてない）ならスキップ
    GOTO    alphabet
    BTFSS   now_a,1	    ;RA1が…
    GOTO    area0
    BTFSS   now_a,2
    GOTO    area1
    BTFSS   now_a,3
    GOTO    area2
    BTFSS   now_a,4
    GOTO    area3
    BTFSS   now_a,5
    GOTO    area4
        
kana:
    ;ひらがな入力
    ;030に続いて入力されたものを送信
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '3'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVFW   inp_num
    CALL    change_ASCII
    CALL    send_ASCII
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    
    MOVLW   0x03	    ;3桁目まで出力完了
    MOVWF   state_digit
    RETURN
    
alphabet:
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVFW   inp_num
    CALL    change_ASCII
    CALL    send_ASCII
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    
    MOVLW   0x03	    ;3桁目まで出力完了
    MOVWF   state_digit
    RETURN
    
area0:
    MOVLW   '0'
    CALL    send_ASCII
    GOTO    send_digit1
    
area1:
    MOVLW   '1'
    CALL    send_ASCII
    GOTO    send_digit1

area2:
    MOVLW   '2'
    CALL    send_ASCII
    GOTO    send_digit1

area3:
    MOVLW   '3'
    CALL    send_ASCII
    GOTO    send_digit1
    
;4は14面
area4:
    MOVLW   'E'
    CALL    send_ASCII
    MOVFW   inp_num
    CALL    change_ASCII
    CALL    send_ASCII
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    
    ;14面8以降のキーはファンクションにするための分岐
    MOVFW   inp_num
    SUBLW   0x07
    BTFSS   STATUS,C
    GOTO    send_func
    
    MOVLW   0x01	    ;1桁目まで出力完了
    MOVWF   state_digit
    RETURN
    
send_func:
    CLRF   state_digit	    ;ステータスを0に戻す
    RETURN
    
send_digit1:
    MOVFW   inp_num
    CALL    change_ASCII
    CALL    send_ASCII
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    
    MOVLW   0x01	    ;1桁目まで出力完了
    MOVWF   state_digit
    RETURN

cr_bs:
    MOVF   inp_num,f	;Zフラグだけ更新
    BTFSS   STATUS,Z
    GOTO    send_cr
    ;RE0の時、BS（U00008）をおくる
    MOVLW   'U'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '8'
    CALL    send_ASCII
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    CLRF    state_digit
    RETURN
    ;改行コード（U0000A）をおくる
send_cr:
    
    MOVLW   'U'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   '0'
    CALL    send_ASCII
    MOVLW   'A'
    CALL    send_ASCII
    MOVLW   0x0a	    ;LF
    CALL    send_ASCII
    CLRF    state_digit
    RETURN
    
    
;wレジスタから取る
change_ASCII:
    ANDLW   0x0F	;とりまマスク
    MOVWF   tmp_ASCII
    SUBLW   0x09
    BTFSS   STATUS,C	;9より大きかったらスキップ
    GOTO    atof
    MOVLW   0x30
    IORWF   tmp_ASCII,w
    RETURN
atof:
    MOVLW   0x09   
    SUBWF   tmp_ASCII,f
    MOVLW   0x40
    IORWF   tmp_ASCII,w
    RETURN
    
    
;wレジスタに値をいれてここに飛ばす
send_ASCII:
    banksel TXREG
    
send_wait:
    BTFSS   PIR1,TXIF
    GOTO    send_wait
    MOVWF   TXREG
    RETURN
    
    
;チャタリング対策wait
DLY:
    
    MOVLW   d'100'   ;0.5ms
    MOVWF   CNT1
    
DLP1:
    MOVLW   d'200'  ;0.5ms
    MOVWF   CNT2
    
DLP2:
    NOP
    NOP
    DECFSZ  CNT2,f
    GOTO    DLP2
    DECFSZ  CNT1,f
    GOTO    DLP1
    RETURN
    
END