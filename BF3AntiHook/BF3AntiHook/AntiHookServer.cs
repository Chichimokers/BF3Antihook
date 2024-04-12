using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Net;
using Newtonsoft.Json;

namespace BF3AntiHook.BF3AntiHook
{
    public class AntiHookServer
    {
        private MysqlConnector database ;

        private int port = 4040;

        private Socket listener;

        private List<Task> ListProcesos;

        private List<Task<Socket>> Clientes;

        public delegate void InfoC(string message);

        public event InfoC evento;

        public List<string> tokens;

        IPEndPoint ipEndPoint; 
        public AntiHookServer(int port,InfoC e,string bdusername,string bd,string bdip,int bdport,string bdpassword)
        {

            evento = e;
            tokens = new List<string>();
            //Instanciando el puerto y socket y lo demas 
            this.port = port;
            this.ipEndPoint = new IPEndPoint(IPAddress.Any, port); 
            listener = new Socket(ipEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
            //Inicializando las listas para almacenar clientes conectados y Sockets de escucha
            this.ListProcesos = new List<Task>();
            this.Clientes = new List<Task<Socket>>();

            database = new MysqlConnector(bdip, bdusername, bdpassword, bdport, bd);
            Task < bool> connectdb = database.Connect();
            if (!connectdb.Result)
            {
                Info("Revise la conexion con la bd si la configuracion introducida es correcta");
            }
            else
            {
                Info("Se conecto exitosamente a la bd");
            }
        

        }
      public  void Start() {
            //Iniciando la tarea
            Info("Se esta inciando el servidor ");
            Task listneer = new Task(async () => { await IniciarServer(); });
            listneer.Start();
            //Agregando la tarea del servidor a lista de Tareas de sockets
            ListProcesos.Add(listneer);
            listener.Bind(ipEndPoint);
            listener.Listen(100);
            InfoC s = Info;
        }

        async Task<Socket> ProcesarClient(Socket clientenuevo)
        {
            //metodo en el que se proces el cliente y se hace el inicio asyncronica
           
            SocketAsyncEventArgs e = new SocketAsyncEventArgs();
            e.AcceptSocket = clientenuevo;
            e.RemoteEndPoint = clientenuevo.RemoteEndPoint;
            e.SetBuffer(new byte[1024], 0, 1024);
            e.Completed += new EventHandler<SocketAsyncEventArgs>(ReceiveCompleted);
            clientenuevo.ReceiveAsync(e);
            
            return clientenuevo;

            
        }
        public string GenerarToken() {

            string token = new Random().Next(1000*150).ToString();
            tokens.Add(token);
            return token;
        }
        void  ReceiveCompleted(object sender, SocketAsyncEventArgs e)
        {
            if (e.BytesTransferred > 0 && e.SocketError == SocketError.Success)
            {
                // Procesar los datos recibidos
                var receivedData = Encoding.UTF8.GetString(e.Buffer, e.Offset, e.BytesTransferred).Split('\n');

                foreach (var aasd in receivedData)
                {
                    Mensaje person = JsonConvert.DeserializeObject<Mensaje>(aasd);

                    if (person.Tipo == "GetServers")
                    {

                        Info("Se recibio una peticion GetServers desde el ip :" + e.RemoteEndPoint.ToString());

                        GetServers peticion = JsonConvert.DeserializeObject<GetServers>(aasd);
                        foreach (var fa in tokens)
                        {
                            if (peticion.token == fa)
                            {

                                Info("Se le envio la lista de servidores a esta ip correctamente:" + e.RemoteEndPoint.ToString());

                                List<Servers> servidores = database.GetServers();

                                GetServers respesta = new GetServers();
                                respesta.servidres = servidores;
                                respesta.token = peticion.token;

                                string serialize = JsonConvert.SerializeObject(respesta);
                                byte[] buffer = Encoding.UTF8.GetBytes(serialize);
                                var a = e.AcceptSocket.SendAsync(new ArraySegment<byte>(buffer), SocketFlags.None);
                                a.ContinueWith(t =>
                                {
                                    if (t.IsFaulted || t.IsCanceled)
                                    {
                                    // Manejar la desconexión aquí
                                    Info("Error al enviar datos al cliente: " + t.Exception.Message);
                                        e.AcceptSocket.Close();
                                    }
                                });
                            }

                        }

                    }


                    if (person.Tipo == "Login")
                    {

                        List<User> usuarios = database.GetUsers();


                        Login userlog = JsonConvert.DeserializeObject<Login>(aasd);

                        Info("Se recibio una peticion Login desde el ip :" + e.RemoteEndPoint.ToString());

                        Login respuesta = new Login();

                        respuesta.Tipo = "Login";


                        respuesta.token = "null";
                        foreach (var recorrido in usuarios)
                        {


                            if (recorrido.Username == userlog.User)
                            {


                                string has = PasswordHasher.HashPassword(userlog.password).ToLower();
                                string x = recorrido.Password.Trim();
                                string y = has.Trim();
                                if (x == y)
                                {


                                    respuesta.token = GenerarToken();
                                    respuesta.AuthToken = recorrido.AutToken;
                                    break;

                                }

                            }
                        }

                        if (respuesta.token != "null")
                        {
                            Info("Se logueo correctamente :" + e.RemoteEndPoint.ToString());
                        }
                        else
                        {
                            Info("Error al loguerse desde  :" + e.RemoteEndPoint.ToString());
                        }
                        string serialize = JsonConvert.SerializeObject(respuesta);
                        byte[] buffer = Encoding.UTF8.GetBytes(serialize);
                        var a = e.AcceptSocket.SendAsync(new ArraySegment<byte>(buffer), SocketFlags.None);
                        a.ContinueWith(t =>
                        {
                            if (t.IsFaulted || t.IsCanceled)
                            {
                            // Manejar la desconexión aquí
                            Info("Error al enviar datos al cliente: " + t.Exception.Message);
                                e.AcceptSocket.Close();
                            }
                        });

                    }

                }
                e.AcceptSocket.ReceiveAsync(e);
            }
            else
            {
     
                foreach (var a in Clientes.ToList()) {

                    if (a.Result.RemoteEndPoint == e.AcceptSocket.RemoteEndPoint) {
                        Clientes.Remove(a);
                        Info("Se desconecto el cliente desde :"+ e.RemoteEndPoint.ToString());
                        e.AcceptSocket.Close();
                    }
                }
            }
         


        }
        public void Info(string message) {
            evento?.Invoke(message);
        }
        async Task IniciarServer(){


            Info("esta esperando conexiones entrantes desde el puerto " + listener.LocalEndPoint.ToString());
            while (true)
            {

                // Procesa la conexión del cliente en un nuevo hilo para no bloquear el servidor
                
                Socket client = await listener.AcceptAsync();
                
                var _ = Task.Run(async () => await ProcesarClient(client));

                Clientes.Add(_);

            }

        }

    }
}
