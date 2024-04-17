// Decompiled with JetBrains decompiler
// Type: BF3AntiHook.BF3AntiHook.MysqlConnector
// Assembly: BF3AntiHook, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: EEB90F25-279F-4551-9815-4FB977A6FF28
// Assembly location: C:\Users\Ernestico\Desktop\BF3AntiHook.exe

using MySqlConnector;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Threading.Tasks;

namespace BF3AntiHook.BF3AntiHook
{
  internal class MysqlConnector
  {
    private MySqlConnectionStringBuilder builder;
    private MySqlConnection conection;

    public MysqlConnector(string ip, string user, string password, int port, string databasename) => this.builder = new MySqlConnectionStringBuilder()
    {
      Server = ip,
      Database = databasename,
      UserID = user,
      Password = password
    };

    public async Task<bool> Connect()
    {
      this.conection = new MySqlConnection(((DbConnectionStringBuilder) this.builder).ConnectionString);
      ((DbConnection) this.conection).Open();
      return ((DbConnection) this.conection).State == ConnectionState.Open;
    }

    public List<User> GetUsers()
    {
      List<User> userList = new List<User>();
      using (MySqlCommand command = this.conection.CreateCommand())
      {
        ((DbCommand) command).CommandText = "SELECT * FROM a_emu_playerinfo;";
        using (MySqlDataReader mySqlDataReader = command.ExecuteReader())
        {
          while (((DbDataReader) mySqlDataReader).Read())
            userList.Add(new User()
            {
              AutToken = mySqlDataReader.GetString("AuthCode"),
              Password = mySqlDataReader.GetString("password"),
              Username = mySqlDataReader.GetString("username"),
              userid = mySqlDataReader.GetInt32("user_id").ToString()
            });
        }
      }
      return userList;
    }

    public List<Servers> GetServers()
    {
      List<Servers> serversList = new List<Servers>();
      using (MySqlCommand command = this.conection.CreateCommand())
      {
        ((DbCommand) command).CommandText = "SELECT * FROM a_bf_gameservers;";
        using (MySqlDataReader mySqlDataReader = command.ExecuteReader())
        {
          while (((DbDataReader) mySqlDataReader).Read())
            serversList.Add(new Servers()
            {
              gname = mySqlDataReader.GetString("gnam"),
              levelocation = mySqlDataReader.GetString("levellocation"),
              maxplaers = mySqlDataReader.GetInt64("pcap").ToString(),
              Gameid = mySqlDataReader.GetInt64("gid").ToString(),
              tipe = mySqlDataReader.GetString("type"),
              playersonline = mySqlDataReader.GetInt64("online").ToString(),
              Level = mySqlDataReader.GetString("mode")
            });
        }
      }
      return serversList;
    }
  }
}
