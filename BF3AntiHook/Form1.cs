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
using BF3AntiHook.BF3AntiHook;
namespace BF3AntiHook
{
    public partial class Form1 : Form
    {
        private BF3AntiHook.AntiHookServer server;
        private int conected;
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
            //server = new BF3AntiHook.AntiHookServer(Convert.ToInt32(textBox1.Text), Server_evento, "root", "bf", "127.0.0.1", 3306, "");
            server.PlayerConnecte += Server_PlayerConnecte;
            server.Start();
        }

        private void Server_PlayerConnecte(User real,bool connect)
        {
            if (connect)
            {
                conected++;
                if (listView1.InvokeRequired)
                {
                    listView1.Invoke(new Action(() =>
                    {
                        listView1.Items.Add(new Label().Text = "Fue:" + real.Username);
                    }));
                }
            }
            else
            {
                conected--;
                listView1.Invoke(new Action(() =>
                {
                    listView1.Items.Add(new Label().Text = "Fue:" + real.Username);
                }));
            }
            if (label3.InvokeRequired)
            {
                label3.Invoke(new Action(() =>
                {
                    label3.Text = "Online : " + conected.ToString();
                }));
            }
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
