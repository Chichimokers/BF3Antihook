﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;
namespace WindowsFormsApp1
{
    public partial class Form1 : Form
    {
        private Antihookclient.AntiHookClient anthook;
        private Task conectar;
        public Form1()
        {
            InitializeComponent();
        }

        private void Label3_Click(object sender, EventArgs e)
        {

        }

        private void Button1_Click(object sender, EventArgs e)
        {

            panel1.Controls.Clear();
            if (anthook == null)
            {
                anthook = new Antihookclient.AntiHookClient();
                anthook.OnConnects += Anthook_OnConnects;
                anthook.OnserversGet += Anthook_OnserversGet;
            }

            Task ad = Task.Run(async () =>
            {             
                await anthook.Connect(textBox1.Text, textBox2.Text, textBox3.Text);
            });
        }

        
        private void Anthook_OnserversGet(List<BF3AntiHook.BF3AntiHook.Servers> a)
        {
            int yPosition = 0;
            foreach (var e in a) {

                if (panel1.InvokeRequired)
                {

                    panel1.Invoke(new Action(() =>
                    {
                        Controles.UserControl1 item = new Controles.UserControl1();                      
                        item.servidor = e; // Almacenar tu objeto personalizado aquí
                        item.settext(e.gname + " " + e.levelocation + " " + e.playersonline + "/" + e.maxplaers);
                        item.AutoSize = true;
                        item.cliekado += Item_cliekado;       
                        item.Location = new Point(0, yPosition); // Ajusta la posición vertical basada en el número de elementos
                        panel1.Controls.Add(item); // Agrega el elemento al panel
                        yPosition += item.Height + 2;
                    }));
                }
                else
                {
                    Controles.UserControl1 item = new Controles.UserControl1();

                    item.servidor = e; // Almacenar tu objeto personalizado aquí
                    item.settext(e.gname + " " + e.levelocation + " " + e.playersonline + "/" + e.maxplaers);
                    item.AutoSize = true;
                    item.cliekado += Item_cliekado;
                    item.Location = new Point(0, yPosition); // Ajusta la posición vertical basada en el número de elementos
                    panel1.Controls.Add(item); // Agrega el elemento al panel
                    yPosition += item.Height + 2;

                }
            }

        }

        private void Item_cliekado(BF3AntiHook.BF3AntiHook.Servers a)
        {
            Task  asd = Task.Run(async () => await anthook.RunBf3(a));

          
        }


        private void Anthook_OnConnects(bool conectado)
            {
            if (conectado)
            {
                if (label4.InvokeRequired)
                {
                    label4.Invoke(new Action(() =>
                    {
                        label4.Text = "Connected";
                        label4.ForeColor = Color.Green;
                    }));
                }
                else
                {

                    label4.Text = "Connected";
                    label4.ForeColor = Color.Green;
                }
             
            }
            else
            {
                if (label4.InvokeRequired)
                {
                    label4.Invoke(new Action(() =>
                    {
                        label4.Text = "Disconnect";
                        label4.ForeColor = Color.Red;
                    }));
                }
                else
                {

                    label4.Text = "Disconnect";
                    label4.ForeColor = Color.Red;
                }
         
            }

        }

        private void Form1_Load(object sender, EventArgs e)
        {
           
        }

        private void TextBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void Form1_FormClosed(object sender, FormClosedEventArgs e)
        {
            
            Process[] localProcess = Process.GetProcesses();

            foreach (Process process in localProcess)
            {
                if (process.ProcessName == "LanBf3")
                {     
                    process.Kill();
                }
            }
            anthook.CloseAll();
        }

        private void Button2_Click(object sender, EventArgs e)
        {
            panel1.Controls.Clear();
            Task ad = Task.Run(async () =>
            {
                await anthook.Connect(textBox1.Text, textBox2.Text, textBox3.Text);
            });
        }
    }
}