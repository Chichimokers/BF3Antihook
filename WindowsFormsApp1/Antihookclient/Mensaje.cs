using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BF3AntiHook.BF3AntiHook
{
    public class Mensaje
    {
        public string Tipo { get; set; }


        public string version { get; set; }

        public string token { get; set; }

        public Mensaje()
        {
            version = "1.0.0";
        }
    }
}
