using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace UnicodeKeyboardInputService
{
    public partial class UnicodeInputService : ServiceBase
    {
        public UnicodeInputService()
        {
            InitializeComponent();

            //イベントログ表示
            ServiceEventLog = new System.Diagnostics.EventLog();
            if (!System.Diagnostics.EventLog.SourceExists("ServiceTest"))
            {
                System.Diagnostics.EventLog.CreateEventSource(
                    "ServiceTest", "Application");
            }
            ServiceEventLog.Source = "ServiceTest";
            ServiceEventLog.Log = "Application";

        }

        protected override void OnContinue()
        {

            ServiceEventLog.WriteEntry("OnContinue Called.");
            base.OnContinue();
        }
        protected override void OnPause()
        {
            ServiceEventLog.WriteEntry("OnPause Called.");
            base.OnPause();
        }
        protected override void OnShutdown()
        {
            base.OnShutdown();
        }
        protected override bool OnPowerEvent(PowerBroadcastStatus powerStatus)
        {
            return base.OnPowerEvent(powerStatus);
        }
        protected override void OnStart(string[] args)
        {
        }

        protected override void OnStop()
        {
        }
    }
}
