using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UnicodeInputApp
{
    internal class GetFromSerial
    {
        private SerialPort serialPort1 = new SerialPort();
        char com_num;
        public string nowtext;

        public GetFromSerial()
        {

        }

        public void StartSerial()
        {
            serialPort1.BaudRate = 9600;
            serialPort1.Parity = Parity.None;
            serialPort1.DataBits = 8;
            serialPort1.StopBits = StopBits.One;
            serialPort1.Handshake = Handshake.None;
            serialPort1.PortName = "COM5";
            serialPort1.ReadTimeout = 0;
            serialPort1.Open();
        }
        
        public async void GetUnicode()
        {
            try
            {
                nowtext = serialPort1.ReadLine();
            }
            catch (Exception) {
                nowtext = "";
            }
            
        }
        public void CloseSerialPort()
        {

            serialPort1.Close();
        }
        public string GetNowtext()
        {
            return nowtext;
        }

    }
}
