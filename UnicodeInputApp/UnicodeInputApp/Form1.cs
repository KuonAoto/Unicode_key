using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using System.Windows.Forms;
using static UnicodeInputApp.InputKey;

namespace UnicodeInputApp
{
    public partial class Form1 : Form
    {
        GetFromSerial GetFromSerial = new GetFromSerial();
        InputKey InputKey = new InputKey();
        System.Timers.Timer CheckTimer = new System.Timers.Timer();

        string unicode_num = "";
        Int32 input_symbol = 0;
        public Form1()
        {
            InitializeComponent();
        }

        private async void button1_Click(object sender, EventArgs e)
        {
            GetFromSerial.StartSerial();        //シリアル開始
            SetTimer();
            //while (true)
            {
                //await Loop();
            }
            //this.SetTimer();

        }
        private void button2_Click(object sender, EventArgs e)
        {
            this.StopTimer();
            GetFromSerial.CloseSerialPort();
        }






        
        private void SetTimer()
        {
            CheckTimer = new System.Timers.Timer();
            CheckTimer.Interval = 100; // （0.1秒）
            CheckTimer.Elapsed += new ElapsedEventHandler(this.OnTimer);
            CheckTimer.Start();
        }
        private void StopTimer()
        {
            CheckTimer.Stop();
        }
        protected void OnTimer(object sender, EventArgs e)
        //protected  Task Loop()
        {
            // 定周期処理
            GetFromSerial.GetUnicode();
            
            if (GetFromSerial.nowtext != "")
            {
                //SendKeys.Send("🀃");
                //Uで始まったら
                if (GetFromSerial.nowtext.StartsWith("U"))
                {
                    unicode_num = GetFromSerial.nowtext;
                    unicode_num=unicode_num.Substring(1);
                    SendKeys.SendWait("U");
                    SendKeys.SendWait(unicode_num.ToString());
                    
                }
                else
                {
                    unicode_num += GetFromSerial.nowtext;
                    SendKeys.SendWait(GetFromSerial.nowtext);
                }


                //受信したUnicodeが6文字以上になったら
                if (unicode_num.Length >= 5)
                {
                    for (int i = 0; i < unicode_num.Length + 1; i++)
                    {
                        BSInput();
                    }
                    //unicode_num = unicode_num.Substring(1);   //Uを外す
                    //16進をintに直して、charにしてからstrにする
                    input_symbol = Convert.ToInt32(unicode_num, 16);
                    Debug.Write(Char.ConvertFromUtf32(input_symbol));
                    SendKeys.SendWait(Char.ConvertFromUtf32(input_symbol).ToString());
                    unicode_num = "";
                }
            }
        }

        
    }
}
