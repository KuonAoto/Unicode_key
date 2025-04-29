using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Timers;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;


namespace UnicodeInputApp
{
    public partial class Form1 : Form
    {
        GetFromSerial GetFromSerial = new GetFromSerial();
        System.Timers.Timer CheckTimer = new System.Timers.Timer();

        string unicode_num = "";
        Int32 input_symbol = 0;
        public Form1()
        {
            InitializeComponent();
        }

        private  void button1_Click(object sender, EventArgs e)
        {
            try
            {
                GetFromSerial.StartSerial(comboBox1.Text);        //シリアル開始
                comboBox1.Enabled = false;
                SetTimer();
                button1.Enabled = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("接続に失敗しました。\n\n" + ex, "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
            
            

        }
        private void button2_Click(object sender, EventArgs e)
        {
            button1.Enabled = true;
            this.StopTimer();
            comboBox1.Enabled = true;
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
        
        {
            // 定周期処理
            try
            {
                GetFromSerial.GetUnicode();

            }
            catch (InvalidOperationException　ex)
            {
                this.StopTimer();
                GetFromSerial.CloseSerialPort();
                MessageBox.Show("ポートを認識できません\n\n"+ex, "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
                
            }
            catch (Exception ex)
            {
                this.StopTimer();
                GetFromSerial.CloseSerialPort();
                MessageBox.Show("ポートを閉じました\n\n"+ex, "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
                
            }
            
            if (GetFromSerial.nowtext != "")
            {
                //Uで始まったら
                if (GetFromSerial.nowtext.StartsWith("U"))
                {
                    unicode_num = GetFromSerial.nowtext;
                    unicode_num=unicode_num.Substring(1);   //最初のUを除く
                    
                }
                else
                {
                    unicode_num += GetFromSerial.nowtext;
                }

                //第14面で A, D, E, F をそれぞれ {UP}, {LEFT}, {DOWN}, {RIGHT} に変換
                // EA で始まるなら {UP}、などとする
                if (unicode_num.StartsWith("EA"))
                {
                    SendKeys.SendWait("{UP}"); unicode_num = "";
                    unicode_num = "";
                }
                else if (unicode_num.StartsWith("ED"))
                {
                    SendKeys.SendWait("{LEFT}"); unicode_num = "";
                    unicode_num = "";
                }
                else if (unicode_num.StartsWith("EE"))
                {
                    SendKeys.SendWait("{DOWN}"); unicode_num = "";
                    unicode_num = "";
                }
                else if (unicode_num.StartsWith("EF"))
                {
                    SendKeys.SendWait("{RIGHT}"); unicode_num = "";
                    unicode_num = "";
                }

                //受信したUnicodeが6文字以上になったら
                if (unicode_num.Length >= 5)
                {
                    //16進をintに直して、charにしてからstrにする

                    try
                    {
                        
                        input_symbol = Convert.ToInt32(unicode_num, 16);
                        var input_str = Char.ConvertFromUtf32(input_symbol).ToString();
                        Debug.Write(input_str);

                        // https://stackoverflow.com/questions/18299216/send-special-character-with-sendkeys
                        SendKeys.SendWait(Regex.Replace(input_str, "[+^%~()\\{\\}]", "{$0}"));
                        unicode_num = "";
                    }
                    
                    catch (Exception)
                    {
                        MessageBox.Show("存在しない領域です\n", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        
                    }

                }
            }
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}
