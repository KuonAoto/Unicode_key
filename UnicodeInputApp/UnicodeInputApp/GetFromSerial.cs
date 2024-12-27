using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

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

        public void StartSerial(string portname)
        {
            try
            {
                serialPort1.BaudRate = 9600;
                serialPort1.Parity = Parity.None;
                serialPort1.DataBits = 8;
                serialPort1.StopBits = StopBits.One;
                serialPort1.Handshake = Handshake.None;
                serialPort1.PortName = portname;
                serialPort1.ReadTimeout = 0;
                serialPort1.Open();
            }
            catch (Exception)
            {
                throw ;
            }
            
        }
        
        public void GetUnicode()
        {
            try
            {
                nowtext = serialPort1.ReadLine();
            }
            catch (TimeoutException)
            {
                nowtext = "";
            }
            catch (InvalidOperationException e)
            {
                
                throw ;
            }
            catch (Exception e) {
                throw ;
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
