using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySqlConnector;
namespace BF3AntiHook.BF3AntiHook
{
    class MysqlConnector
    {
        MySqlConnectionStringBuilder builder;
        MySqlConnection conection;
        public MysqlConnector(string ip,string user, string password, int port,string databasename) {

            builder = new MySqlConnectionStringBuilder
            {
                Server = ip,
                Database = databasename,
                UserID =user,
                Password = password,
          
            };

         

        }
        public async Task<bool> Connect() {
       
            
                conection = new MySqlConnection(builder.ConnectionString);
                 conection.Open();
                if (conection.State == System.Data.ConnectionState.Open)
                {
                    return true;
                }
                else { return false; }
         
        }

          public List<User> GetUsers() {
            List<User> useuarios = new List<User>();


            using (var command = conection.CreateCommand())
            {
              
                command.CommandText = "SELECT * FROM a_emu_playerinfo;";

                using (var reader = command.ExecuteReader())
                {
                    
                    while ( reader.Read())
                    {
                        User usuair = new User();
                        usuair.AutToken = reader.GetString("AuthCode");
                        usuair.Password=  reader.GetString("password");
                        usuair.Username = reader.GetString("username");
                        usuair.userid = reader.GetInt32("user_id").ToString();
                        useuarios.Add(usuair);
                     
                    }
                
              

                }


            }

  
            return useuarios;

        }
        public List<Servers>  GetServers()
        {

            List<Servers> serverlist = new List<Servers>();

            using (var command = conection.CreateCommand())
            {

                command.CommandText = "SELECT * FROM a_bf_gameservers;";

                using (var reader = command.ExecuteReader())
                {
                   
                    while (reader.Read())
                    {
                        Servers servidor = new Servers();
                        servidor.gname = reader.GetString("gnam");
                        servidor.levelocation = reader.GetString("levellocation");
                        servidor.maxplaers = reader.GetInt64("pcap").ToString();
                        servidor.Gameid = reader.GetInt64("gid").ToString();
                        servidor.tipe = reader.GetString("type");
                   
                        servidor.playersonline = reader.GetInt64("online").ToString();
                        servidor.Level = reader.GetString("mode");
                        serverlist.Add(servidor);


                    }
                    
                   



                }


            }
            return serverlist;
        }
    }
}
