using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Diagnostics;
using System.IO;

namespace BF3AntiHOOK
{
    public class ConfigFile
    {

         public static Configuration LoadConfig()
         {
            Configuration configuration = new Configuration();
            if (File.Exists("C:\\Users\\antihook.json"))
            {
              

              
               configuration = JsonConvert.DeserializeObject<Configuration>(File.ReadAllText("C:\\Users\\antihook.json"));
            }
            return configuration;
        }
        public static void SaveConfig(string username,string server,string password)
        {
            if (File.Exists("C:\\Users\\antihook.json"))
            {
                Configuration confugrac = new Configuration();
                confugrac.server = server;
                confugrac.password = password;
                confugrac.username = username;
                File.Delete("C:\\Users\\antihook.json");
                File.WriteAllText("C:\\Users\\antihook.json", JsonConvert.SerializeObject(confugrac));
            }
            else
            {
                Configuration confugrac = new Configuration();
                confugrac.server = server;
                confugrac.password = password;
                confugrac.username = username;
                File.WriteAllText("C:\\Users\\antihook.json", JsonConvert.SerializeObject(confugrac));
            }

        }
    }
}
