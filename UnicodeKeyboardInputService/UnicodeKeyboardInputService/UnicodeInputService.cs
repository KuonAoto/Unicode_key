using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using System.Runtime.InteropServices;
using UnicodeKeyboardInputService;

namespace UnicodeKeyboardInputService
{
    public partial class UnicodeInputService : ServiceBase
    {
        GetFromSerial GetFromSerial = new GetFromSerial();
        InputKey InputKey = new InputKey();
        Timer CheckTimer = new Timer();

        string unicode_num="";
        int input_symbol = 0;



        public UnicodeInputService()
        {

            //GetFromSerial GetFromSerial = new GetFromSerial();
            //InputKey InputKey = new InputKey();
            InitializeComponent();

            //イベントログ表示
            ServiceEventLog = new System.Diagnostics.EventLog();
            if (!System.Diagnostics.EventLog.SourceExists("UnicodeInputService"))
            {
                System.Diagnostics.EventLog.CreateEventSource(
                    "UnicodeInputService", "Application");
            }
            ServiceEventLog.Source = "UnicodeInputService";
            ServiceEventLog.Log = "Application";

        }

        protected override void OnContinue()
        {

            ServiceEventLog.WriteEntry("OnContinue Called.");
            GetFromSerial.StartSerial();        //シリアル開始
            this.SetTimer();
            base.OnContinue();
        }
        protected override void OnPause()
        {

            ServiceEventLog.WriteEntry("OnPause Called.");


            //GetFromSerial.GetUnicode();
            //ServiceEventLog.WriteEntry(GetFromSerial.nowtext);
            this.StopTimer();

            GetFromSerial.CloseSerialPort();
            base.OnPause();
        }
        protected override void OnShutdown()
        {
            this.StopTimer();
            GetFromSerial.CloseSerialPort();
            base.OnShutdown();
        }
        protected override bool OnPowerEvent(PowerBroadcastStatus powerStatus)
        {
            return base.OnPowerEvent(powerStatus);
        }
        protected override void OnStart(string[] args)
        {
            
            GetFromSerial.StartSerial();        //シリアル開始
            this.SetTimer();
            
        }

        protected override void OnStop()
        {
            this.StopTimer();
            GetFromSerial.CloseSerialPort();
        }

        private void SetTimer()
        {
            CheckTimer = new Timer();
            CheckTimer.Interval = 100; // （0.1秒）
            CheckTimer.Elapsed += new ElapsedEventHandler(this.OnTimer);
            CheckTimer.Start();
        }
        private void StopTimer()
        {
            CheckTimer.Stop();
        }
        protected void OnTimer(object sender, EventArgs e)
        {
            // 定周期処理
            GetFromSerial.GetUnicode();
            ServiceEventLog.WriteEntry(GetFromSerial.nowtext);
            
            //Uで始まったら
            if (GetFromSerial.nowtext.StartsWith("U"))
            {
                unicode_num = GetFromSerial.nowtext;

            }
            else
            {
                unicode_num += GetFromSerial.nowtext;
            }

            //受信したUnicodeが6文字以上になったら
            if (unicode_num.Length >= 6)
            {
                ServiceEventLog.WriteEntry(unicode_num);
                unicode_num=unicode_num.Substring(1);   //Uを外す
                //16進をintに直して、charにしてからstrにする
                input_symbol = Convert.ToInt16(unicode_num, 16);
                ServiceEventLog.WriteEntry("入力された文字："+Convert.ToChar(input_symbol).ToString());
                InputKey.SetInput((short)'a');
                unicode_num = "";
            }

        }
    }
}
