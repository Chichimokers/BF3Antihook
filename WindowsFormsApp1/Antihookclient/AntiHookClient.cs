using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Net;
using BF3AntiHook.BF3AntiHook;
using Newtonsoft;
using System.Diagnostics;
using System.Threading;
using System.Windows.Forms;
namespace WindowsFormsApp1.Antihookclient
{
    public class AntiHookClient { 
    
        private Socket connector;

        private int port = 4040;

        private List<Servers> servidores;

        private SocketAsyncEventArgs _connectArgs;

        private string server;

        private string username;

        private Process bf3process;

        private string password;

        private string token;

        private string authtoken;

        public delegate void GetServidores(List<BF3AntiHook.BF3AntiHook.Servers> a );

        public event GetServidores OnserversGet;
        
        public delegate void OnConnect(bool conectado);

        public event OnConnect OnConnects;
        public Task supervisor;
        public void OnServersGet(List<Servers> ser) {

            OnserversGet?.Invoke(ser);

        }
        public void OnConnected(bool conectado)
        {
            OnConnects?.Invoke(conectado);

        }
        public async Task Bf3ProcessSupervisor()

        {if (supervisor != null)
            {
                try
                {
                    while (true)
                    {
                        Thread.Sleep(1000);
                        Process[] processes = Process.GetProcessesByName("LanBf3");
                        ProcessModuleCollection modules = processes[0].Modules;
                        if (modules.Count > 114)
                        {
                            processes[0].Kill();
                            MessageBox.Show("Estas inventando no te pongas parche ni abras grabadores de pantalla");
                        }

                    }
                }
                catch (Exception e ){ }
            }
        }
        public async Task RunBf3(Servers e) {

            if(Process.GetProcessesByName("LanBf3").Length == 0)
            {

                string comandosbf3 = "-webMode MP -Origin_NoAppFocus -onlineEnvironment prod -loginToken \""+authtoken + "\" -AuthToken \"" + authtoken+ "\" -requestState State_ClaimReservation -requestStateParams \"<data putinsquad=\\\"true\\\" gameid=\\\"" + e.Gameid+ "\\\" personaref=\\\"1\\\" levelmode=\\\"" + e.tipe+ "\\\"></data>\"" + "|" + server + "|";
                List<char> car  = comandosbf3.ToList();
                supervisor = Task.Run(async ()=> { Thread.Sleep(5000); Bf3ProcessSupervisor(); });
                bf3process = new Process();
                bf3process.Disposed += Bf3process_Disposed;
                bf3process.Exited += Bf3process_Exited;

                // Especificar el nombre del archivo ejecutable
                bf3process.StartInfo.FileName = "Redirector.exe";

                // Especificar los argumentos que se pasarán al programa
                bf3process.StartInfo.Arguments = "bf3lan://"+Helper.ConvertToBase64(comandosbf3);

                // Iniciar el proceso
                bf3process.Start();

               
            }


        }

        private void Bf3process_Exited(object sender, EventArgs e)
        {
            bf3process = null;
        }

        private void Bf3process_Disposed(object sender, EventArgs e)
        {
            bf3process = null;
        }
        public AntiHookClient()
        {
            //Incializar Socket
            servidores = new List<Servers>();
            connector = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

            _connectArgs = new SocketAsyncEventArgs();
            _connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(OnConnectCompleted);

        }
        public AntiHookClient(string server,string username,string password)
        {
            //Incializar Socket
            this.server = server;
            this.username = username;
            this.password = password;
            servidores = new List<Servers>();
            connector = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

            _connectArgs = new SocketAsyncEventArgs();
            _connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(OnConnectCompleted);
         
        }
        public async Task<bool> ObtainServers()
        {
            var tcs = new TaskCompletionSource<bool>();

            GetServers petci = new GetServers();

            petci.Tipo = "GetServers";
            petci.token = token;

            string message = Newtonsoft.Json.JsonConvert.SerializeObject(petci);

            byte[] buffer = Encoding.UTF8.GetBytes(message);

            SocketAsyncEventArgs sendArgs = new SocketAsyncEventArgs();

            sendArgs.SetBuffer(buffer, 0, buffer.Length);

            connector.SendAsync(sendArgs);


            byte[] bufferToReceive = new byte[1024]; // Ajusta el tamaño del buffer según sea necesario

            // Crear un nuevo SocketAsyncEventArgs para la operación de recepción
            SocketAsyncEventArgs receiveArgs = new SocketAsyncEventArgs();
            receiveArgs.SetBuffer(bufferToReceive, 0, bufferToReceive.Length); // Establecer el buffer para recibir datos
            receiveArgs.Completed += (sender, e) =>
            {
                if (e.SocketError == SocketError.Success)
                {
                    string receivedData = Encoding.UTF8.GetString(e.Buffer, e.Offset, e.BytesTransferred);
                    GetServers servers = Newtonsoft.Json.JsonConvert.DeserializeObject<GetServers>(receivedData);

                    OnServersGet(servers.servidres);
                    if (servers.servidres != null)
                    {

                        tcs.SetResult(true);
                    }
                    else
                    {
                        tcs.SetResult(false);
                    }
                }
                else
                {

                    // Hubo un error al recibir los datos
                    Console.WriteLine($"Error al recibir datos: {e.SocketError}");

                    tcs.SetResult(false);

                }
                e.Dispose();
            }; // Manejar el evento de finalización de la operación de recepción

            // Iniciar la operación de recepción de manera asíncrona
            connector.ReceiveAsync(receiveArgs);


            return tcs.Task.Result;

        }

        public void CloseAll()
        {
     
            connector.Shutdown(SocketShutdown.Both);
        }
            
        public async Task<bool> Loguer()
        {
            // Crear una TaskCompletionSource para controlar el final de la operación
            var tcs = new TaskCompletionSource<bool>();

            Login logueador = new Login();
            logueador.User = username;
            logueador.password = password;
            logueador.Tipo = "Login";
            string message = Newtonsoft.Json.JsonConvert.SerializeObject(logueador);
            byte[] buffer = Encoding.UTF8.GetBytes(message);

            SocketAsyncEventArgs sendArgs = new SocketAsyncEventArgs();
            sendArgs.SetBuffer(buffer, 0, buffer.Length);

            // Enviar de manera asíncrona
            bool s = connector.SendAsync(sendArgs);

         

            byte[] bufferToReceive = new byte[1024];
            SocketAsyncEventArgs receiveArgs = new SocketAsyncEventArgs();
            receiveArgs.SetBuffer(bufferToReceive, 0, bufferToReceive.Length);
            receiveArgs.Completed += (sender, e) =>
            {
                if (e.SocketError == SocketError.Success)
                {
                    string receivedData = Encoding.UTF8.GetString(e.Buffer, e.Offset, e.BytesTransferred);
                    Login respuestacomplta = Newtonsoft.Json.JsonConvert.DeserializeObject<Login>(receivedData);
                    token = respuestacomplta.token;
                    authtoken = respuestacomplta.AuthToken;
                    if(token == "null")
                    {
                        tcs.SetResult(false);
                        MessageBox.Show("Error en usuario o contraseña");
                    }
                    else
                    {
                        tcs.SetResult(true);
                    }
                    // Completar la TaskCompletionSource
                  
                }
                else
                {
                    Console.WriteLine($"Error al recibir datos: {e.SocketError}");
                    // Completar la TaskCompletionSource con un error
                    tcs.SetException(new Exception($"Error al recibir datos: {e.SocketError}"));
                }
                e.Dispose();
            };

         
            // Iniciar la operación de recepción de manera asíncrona
            connector.ReceiveAsync(receiveArgs);

            // Devolver la Task de la TaskCompletionSourc
            return tcs.Task.Result;
        }

        public async Task Connect(string server,string username,string password)
        {
            this.server = server;
            this.username = username;
            this.password = password;
            if (!connector.Connected)
            {
                _connectArgs.RemoteEndPoint = new IPEndPoint(IPAddress.Parse(server), port);

                bool willRaiseEvent = connector.ConnectAsync(_connectArgs);
            }

            var a = await Loguer();
            if (a)
            {
                await ObtainServers();
            }




        }

        public async Task Connect()
        {
            if (!connector.Connected)
            {

                _connectArgs.RemoteEndPoint = new IPEndPoint(IPAddress.Parse(server), port);

                bool willRaiseEvent = connector.ConnectAsync(_connectArgs);
            }

            var a =  await Loguer();
            if (a)
            {
                await ObtainServers();
            }

           
            

        }

        private void OnConnectCompleted(object sender, SocketAsyncEventArgs e)
        {
            if (e.SocketError == SocketError.Success)
            {
                OnConnected(true);
                // Aquí puedes comenzar a enviar o recibir datos.
                // El socket conectado está disponible en e.ConnectSocket.
           
            }
            else
            {
                 OnConnected(false);
            }
            
        }
    }

}
