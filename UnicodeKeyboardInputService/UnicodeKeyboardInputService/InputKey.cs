using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using static UnicodeKeyboardInputService.InputKey;


namespace UnicodeKeyboardInputService
{
    public class InputKey
    {
        public InputKey() {

            
        }

        public　static  void SetInput(short input_str)
        {
           // await Task.Delay(3000);


            var val_sc = input_str;

            Input[] now_input = new Input[2];
            now_input[0]=new Input();
            now_input[0].Type = 1;         //キーボードイベント
            now_input[0].ui.Keyboard.VirtualKey = 0;
            now_input[0].ui.Keyboard.ScanCode = val_sc;
            now_input[0].ui.Keyboard.Flags = 0x0004 | 0x0000;
            now_input[0].ui.Keyboard.Time = 0;
            now_input[0].ui.Keyboard.ExtraInfo = IntPtr.Zero;

            now_input[1] = new Input();
            now_input[1].Type = 1;         //キーボードイベント
            now_input[1].ui.Keyboard.VirtualKey = 0;
            now_input[1].ui.Keyboard.ScanCode = val_sc;
            now_input[1].ui.Keyboard.Flags = 0x0004 | 0x0002;
            now_input[1].ui.Keyboard.Time = 0;
            now_input[1].ui.Keyboard.ExtraInfo = IntPtr.Zero;

            

            InputKey.SendInput(now_input.Length, now_input, Marshal.SizeOf<Input>());
        }

        [DllImport("user32.dll", SetLastError = true)]
        public extern static void SendInput(int nInputs, Input[] pInputs, int cbsize);




        [StructLayout(LayoutKind.Sequential)]
        public struct MouseInput
        {
            public int X;
            public int Y;
            public int Data;
            public int Flags;
            public int Time;
            public IntPtr ExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct KeyboardInput
        {
            public short VirtualKey;
            public short ScanCode;
            public int Flags;
            public int Time;
            public IntPtr ExtraInfo;
        }
        // VirtualKey・ScanCodeは、winuser.hのKEYBDINPUT構造体では、WORD(16ビット符号なし整数、unsigned short型/2バイト)の定義＝ushort
        // https://learn.microsoft.com/ja-jp/windows/win32/api/winuser/ns-winuser-keybdinput
        // https://learn.microsoft.com/ja-jp/windows/win32/winprog/windows-data-types#word

        [StructLayout(LayoutKind.Sequential)]
        public struct HardwareInput
        {
            public int uMsg;
            public short wParamL;
            public short wParamH;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct Input
        {
            public int Type;
            public InputUnion ui;
        }

        [StructLayout(LayoutKind.Explicit)]
        public struct InputUnion
        {
            [FieldOffset(0)]
            public MouseInput Mouse;
            [FieldOffset(0)]
            public KeyboardInput Keyboard;
            [FieldOffset(0)]
            public HardwareInput Hardware;
        }

    }
}
