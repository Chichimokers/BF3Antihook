using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BF3AntiHook.BF3AntiHook
{
    class Login : Mensaje
    {

        public string User { get; set; }
        public string password { get; set; }

        public string AuthToken { get; set; }
    }
}
