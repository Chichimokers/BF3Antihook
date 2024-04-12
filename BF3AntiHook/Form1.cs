using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BF3AntiHook;
namespace BF3AntiHook
{
    public partial class Form1 : Form
    {
        private BF3AntiHook.AntiHookServer server;
        public Form1()
        {
            InitializeComponent();
        }

        private void TextBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            
            server = new BF3AntiHook.AntiHookServer(Convert.ToInt32(textBox1.Text), Server_evento,"bf4","bf","127.0.0.1",3306,"bf4");
            server.Start();
        }

        private void Server_evento(string message)
        {
            if (listView1.InvokeRequired)
            {
                listView1.Invoke(new Action(() =>
                {
                    listView1.Items.Add(new Label().Text = message);
                }));
            }
            else
            {
                listView1.Items.Add(new Label().Text = message);
            }
            
        }
    }
}
