// Decompiled with JetBrains decompiler
// Type: BF3AntiHook.BF3AntiHook.AntiHookServer
// Assembly: BF3AntiHook, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: EEB90F25-279F-4551-9815-4FB977A6FF28
// Assembly location: C:\Users\Ernestico\Desktop\BF3AntiHook.exe

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace BF3AntiHook.BF3AntiHook
{
  public class AntiHookServer
  {
    private MysqlConnector database;
    private int port = 4040;
    private Socket listener;
    private List<Task> ListProcesos;
    private List<Task<Socket>> Clientes;
    public List<User> usuariosactivos;
    public List<string> tokens;
    public List<string> bans;
    private IPEndPoint ipEndPoint;

    public event AntiHookServer.InfoC evento;

    public event AntiHookServer.Playerconnected PlayerConnecte;

    public AntiHookServer(
      int port,
      AntiHookServer.InfoC e,
      string bdusername,
      string bd,
      string bdip,
      int bdport,
      string bdpassword)
    {
      this.bans = ConfigClass.LoadBans();
      this.evento = e;
      this.tokens = new List<string>();
      this.usuariosactivos = new List<User>();
      this.port = port;
      this.ipEndPoint = new IPEndPoint(IPAddress.Any, port);
      this.listener = new Socket(this.ipEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
      this.ListProcesos = new List<Task>();
      this.Clientes = new List<Task<Socket>>();
      this.database = new MysqlConnector(bdip, bdusername, bdpassword, bdport, bd);
      if (!this.database.Connect().Result)
        this.Info("Revise la conexion con la bd si la configuracion introducida es correcta");
      else
        this.Info("Se conecto exitosamente a la bd");
    }

    public void Start()
    {
      this.Info("Se esta inciando el servidor ");
      Task task = new Task((Action) (async () => await this.IniciarServer()));
      task.Start();
      this.ListProcesos.Add(task);
      this.listener.Bind((EndPoint) this.ipEndPoint);
      this.listener.Listen(100);
      AntiHookServer.InfoC infoC = new AntiHookServer.InfoC(this.Info);
    }

    private async Task<Socket> ProcesarClient(Socket clientenuevo)
    {
      SocketAsyncEventArgs e = new SocketAsyncEventArgs();
      e.AcceptSocket = clientenuevo;
      e.RemoteEndPoint = clientenuevo.RemoteEndPoint;
      e.SetBuffer(new byte[1024], 0, 1024);
      e.Completed += new EventHandler<SocketAsyncEventArgs>(this.ReceiveCompleted);
      clientenuevo.ReceiveAsync(e);
      return clientenuevo;
    }

    public string GenerarToken()
    {
      string str = new Random().Next(150000).ToString();
      this.tokens.Add(str);
      return str;
    }

    private void ReceiveCompleted(object sender, SocketAsyncEventArgs e)
    {
      try
      {
        if (e.BytesTransferred > 0 && e.SocketError == SocketError.Success)
        {
          this.bans = ConfigClass.LoadBans();
          string[] strArray = Encoding.UTF8.GetString(e.Buffer, e.Offset, e.BytesTransferred).Split('\n');
          foreach (string str in strArray)
          {
            foreach (string ban in this.bans)
            {
              Mensaje mensaje = JsonConvert.DeserializeObject<Mensaje>(str);
              if (ban == mensaje.UUID)
              {
                Login login = JsonConvert.DeserializeObject<Login>(str);
                if (login.User != null)
                  this.Info("Se ha intenado loguear :" + login.User + " pero esta baneado " + mensaje.UUID);
                e.AcceptSocket.ReceiveAsync(e);
                e.AcceptSocket.Close();
                return;
              }
            }
          }
          foreach (string str in strArray)
          {
            Mensaje mensaje = JsonConvert.DeserializeObject<Mensaje>(str);
            if (mensaje.Tipo == "Ban")
            {
              this.bans.Add(mensaje.UUID);
              ConfigClass.SaveBans(this.bans);
              this.Info("Se ha baneado a :" + mensaje.UUID);
              byte[] bytes = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject((object) new Mensaje()
              {
                Tipo = "Ban",
                UUID = mensaje.UUID
              }));
              e.AcceptSocket.SendAsync(new ArraySegment<byte>(bytes), SocketFlags.None).ContinueWith((Action<Task<int>>) (t =>
              {
                if (!t.IsFaulted && !t.IsCanceled)
                  return;
                this.Info("Error al enviar datos al cliente: " + t.Exception.Message);
                e.AcceptSocket.Close();
              }));
            }

            if (mensaje.version == "2.17.0")
            {
              if (mensaje.Tipo == "GetServers")
              {

                this.Info("Se recibio una peticion GetServers desde el ip :" + e.RemoteEndPoint.ToString());
                GetServers getServers1 = JsonConvert.DeserializeObject<GetServers>(str);
                foreach (string token in this.tokens)
                {
                  if (getServers1.token == token)
                  {
                    this.Info("Se le envio la lista de servidores a esta ip correctamente:" + e.RemoteEndPoint.ToString());
                    List<Servers> servers = this.database.GetServers();
                    GetServers getServers2 = new GetServers();
                    getServers2.Tipo = "GetServers";
                    getServers2.servidres = servers;
                    getServers2.token = getServers1.token;
                    byte[] bytes = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject((object) getServers2));
                    e.AcceptSocket.SendAsync(new ArraySegment<byte>(bytes), SocketFlags.None).ContinueWith((Action<Task<int>>) (t =>
                    {
                      if (!t.IsFaulted && !t.IsCanceled)
                        return;
                      this.Info("Error al enviar datos al cliente: " + t.Exception.Message);
                      e.AcceptSocket.Close();
                    }));
                  }
                }
              }

              if (mensaje.Tipo == "Login")
              {

                List<User> users = this.database.GetUsers();
                Login login1 = JsonConvert.DeserializeObject<Login>(str);
                this.Info("Se recibio una peticion Login desde el ip :" + e.RemoteEndPoint.ToString());
                Login login2 = new Login();
                login2.Tipo = "Login";
                login2.token = "null";
                foreach (User user in users)
                {
                  if (user.Username == login1.User)
                  {
                    string lower = PasswordHasher.HashPassword(login1.password).ToLower();
                    if (user.Password.Trim() == lower.Trim())
                    {
                      login2.token = this.GenerarToken();
                      login2.AuthToken = user.AutToken;
                      break;
                    }
                  }
                }

                if (login2.token != "null")
                {
                  this.Info("Se logueo correctamente :" + e.RemoteEndPoint.ToString());
                  User usario = new User();
                  usario.IP = e.RemoteEndPoint.ToString();
                  usario.Username = login1.User;
                  usario.Password = login1.password;
                  bool flag = true;
                  foreach (User usuariosactivo in this.usuariosactivos)
                  {
                    if (usuariosactivo.Username == login1.User)
                      flag = false;
                  }
                  if (flag)
                  {
                    this.usuariosactivos.Add(usario);
                    this.Connec(usario, true);
                  }
                }
                else
                  this.Info("Error al loguerse desde  :" + e.RemoteEndPoint.ToString());
                byte[] bytes = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject((object) login2));
                e.AcceptSocket.SendAsync(new ArraySegment<byte>(bytes), SocketFlags.None).ContinueWith((Action<Task<int>>) (t =>
                {
                  if (!t.IsFaulted && !t.IsCanceled)
                    return;
                  this.Info("Error al enviar datos al cliente: " + t.Exception.Message);
                  e.AcceptSocket.Close();
                }));
              }
            }
            else
            {
              Login login = new Login();
              login.Tipo = "Login";
              login.token = "null";
              byte[] bytes = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject((object) login));
              e.AcceptSocket.SendAsync(new ArraySegment<byte>(bytes), SocketFlags.None).ContinueWith((Action<Task<int>>) (t =>
              {
                if (!t.IsFaulted && !t.IsCanceled)
                  return;
                this.Info("Error al enviar datos al cliente: " + t.Exception.Message);
                e.AcceptSocket.Close();
              }));
            }
          }
          e.AcceptSocket.ReceiveAsync(e);
        }
        else
        {
          foreach (Task<Socket> task in this.Clientes.ToList<Task<Socket>>())
          {
            if (task.Result.RemoteEndPoint == e.AcceptSocket.RemoteEndPoint)
            {
              this.Clientes.Remove(task);
              this.Info("Se desconecto el cliente desde :" + e.RemoteEndPoint.ToString());
              e.AcceptSocket.Close();
            }
          }
          foreach (User usario in this.usuariosactivos.ToList<User>())
          {
            if (usario.IP == e.RemoteEndPoint.ToString())
            {
              this.Connec(usario, false);
              this.usuariosactivos.Remove(usario);
            }
          }
        }
      }
      catch (Exception ex)
      {
      }
    }

    public void Info(string message)
    {
      AntiHookServer.InfoC evento = this.evento;
      if (evento == null)
        return;
      evento(message);
    }

    public void Connec(User usario, bool real)
    {
      AntiHookServer.Playerconnected playerConnecte = this.PlayerConnecte;
      if (playerConnecte == null)
        return;
      playerConnecte(usario, real);
    }

    private async Task IniciarServer()
    {
      this.Info("esta esperando conexiones entrantes desde el puerto " + this.listener.LocalEndPoint.ToString());
      while (true)
      {
        Socket client = await this.listener.AcceptAsync();
        Task<Socket> _ = Task.Run<Socket>((Func<Task<Socket>>) (async () =>
        {
          Socket socket = await this.ProcesarClient(client);
          return socket;
        }));
        this.Clientes.Add(_);
        _ = (Task<Socket>) null;
      }
    }

    public delegate void InfoC(string message);

    public delegate void Playerconnected(User real, bool connect);
  }
}
