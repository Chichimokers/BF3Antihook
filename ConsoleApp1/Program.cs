using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Diagnostics;
namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            while (true)
            {
                Thread.Sleep(2000);
                Process[] processes = Process.GetProcessesByName("LanBf3");
                ProcessModuleCollection modules = processes[0].Modules;
               
                Console.WriteLine(modules.Count);

            }
        }
    }
}
