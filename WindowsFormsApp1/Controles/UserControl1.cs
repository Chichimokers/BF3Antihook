using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BF3AntiHook.BF3AntiHook;
namespace WindowsFormsApp1.Controles
{
    public partial class UserControl1 : UserControl
    {

        public Servers servidor;

        public delegate void Clickedt(Servers a);

        public event Clickedt cliekado;
        private void Clickeado(Servers a)
        {

            cliekado?.Invoke(a);
        }

        public UserControl1()
        {
            InitializeComponent();
        }
        public void settext(string mess)
        {

            label1.Text = mess;
        }

        private void UserControl1_MouseHover(object sender, EventArgs e)
        {
            BackColor = Color.Gray;
        }

        private void UserControl1_MouseLeave(object sender, EventArgs e)
        {
            BackColor = Color.White;
        }

        private void UserControl1_Click(object sender, EventArgs e)
        {
            Clickeado(servidor);
        }

        private void Label1_Click(object sender, EventArgs e)
        {
            Clickeado(servidor);
        }
    }
}
