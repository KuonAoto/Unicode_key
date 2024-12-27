# Unicode直接入力キーボード

Unicodeを直接入力できるキーボードのソースコードです。

## 仕様

ひらがなを入力するときは、何も押さずに下位2桁を入力する。  
アルファベットはファンクションキーを押した状態で下位2桁を入力する。  
そのほかの文字、記号はそれぞれの面のファンクションキーを押した状態で4桁を入力することにする。  

## 動かし方

PICには[hexファイル](./Unicode_key.X/dist/default/production/Unicode_key.X.production.hex)を書き込んでください。  
PCと接続して、TeraTermなどで「1」を押したときに「U3001」や「1」などと出てくればハードウェア側はOKです。  
PC側のアプリケーションをダウンロードしてください。[ここ](./UnicodeInputApp/UnicodeInputApp/bin/Debug/UnicodeInputApp.exe)にあります。  
起動してポート番号を選択、接続を押せば入力できるようになります。


## PIC用ソースコード

[./Unicode_key.X](./Unicode_key.X)  
キーボード本体の制御をしています。  
各ピンからの入力を受け取ってUTF8で送るだけです。
言語はアセンブラです。    
コードは[ここ](Unicode_key.X/main.asm)  


## PC側ソースコード

[./UnicodeInputApp](./UnicodeInputApp)  
シリアルポートから読み取ってSendKey関数でキーボード入力しています。  
言語はC#です。  
メインのコードは[ここ](./UnicodeInputApp/UnicodeInputApp/Form1.cs)  

