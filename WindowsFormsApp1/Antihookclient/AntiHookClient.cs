// Decompiled with JetBrains decompiler
// Type: WindowsFormsApp1.Antihookclient.AntiHookClient
// Assembly: BF3AntiHOOK, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 46C4C537-BA68-46CC-BA7C-D20611A805C9
// Assembly location: D:\Juegos\Steam Internet\steamapps\common\Battlefield 3\BF3AntiHOOK.exe

using BF3AntiHook.BF3AntiHook;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsFormsApp1.Antihookclient
{
    public class AntiHookClient
    {
        private Socket connector;
        private int port = 4040;
        private List<Servers> servidores;
        private SocketAsyncEventArgs _connectArgs;
        public string server;
        private string username;
        public Process bf3process;
        private string password;
        private string token;
        private string authtoken;
        public static List<string> ProcesosNoPermitidos = new List<string>()
    {
      "Trainer Battlefield 3 [Update 10]",
      "xmplayer",
      "Battlefield 3 V2.13.2016 Trainer+5 MrAntiFun",
      "WeMod",
      "WeModAuxiliaryService",
      "Injector",
      "Cheat Engine"
    };
        public static List<string> NombredeventanasnoPermitidos = new List<string>()
    {
      "Trainer Battlefield 3 [Update 10]",
      "Battlefield 3 V2.13.2016 Trainer+5 MrAntiFun",
      "WeMod",
      "WeModAuxiliaryService",
      "Injector",
      "Cheat Engine"
    };
        public static List<string> contains = new List<string>()
    {
      "Cheat",
      "Engine",
      "Trainer"
    };
        public Task supervisor;

        public event AntiHookClient.GetServidores OnserversGet;

        public event AntiHookClient.Banear baneado;

        public event AntiHookClient.OnConnect OnConnects;

        public void OnBaned()
        {
            AntiHookClient.Banear baneado = this.baneado;
            if (baneado == null)
                return;
            baneado();
        }

        public void OnServersGet(List<Servers> ser)
        {
            AntiHookClient.GetServidores onserversGet = this.OnserversGet;
            if (onserversGet == null)
                return;
            onserversGet(ser);
        }

        public void OnConnected(bool conectado)
        {
            AntiHookClient.OnConnect onConnects = this.OnConnects;
            if (onConnects == null)
                return;
            onConnects(conectado);
        }

        public AntiHookClient()
        {
            this.supervisor = Task.Run((Func<Task>)(async () =>
            {
                Thread.Sleep(5000);
                this.Bf3ProcessSupervisor();
            }));
            this.servidores = new List<Servers>();
            this.connector = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            this._connectArgs = new SocketAsyncEventArgs();
            this._connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(this.OnConnectCompleted);
        }

        public static bool PreOpen()
        {
            bool flag = false;
            foreach (string procesosNoPermitido in AntiHookClient.ProcesosNoPermitidos)
            {
                foreach (Process process in Process.GetProcesses())
                {
                    if (procesosNoPermitido.Trim().ToLower() == process.ProcessName.Trim().ToLower())
                    {
                        int num = (int)MessageBox.Show("Cierra programas como wemod,Trainers u otro parches, 0 grabadores de pantalla evite serbaneado");
                        flag = true;
                        return flag;
                    }
                }
                foreach (string nombredeventanasnoPermitido in AntiHookClient.NombredeventanasnoPermitidos)
                {
                    foreach (Process process in Process.GetProcesses())
                    {
                        if (nombredeventanasnoPermitido.Trim().ToLower() == process.ProcessName.Trim().ToLower())
                        {
                            int num = (int)MessageBox.Show("Cierra programas como wemod,Trainers u otro parches, 0 grabadores de pantalla evite serbaneado");
                            flag = true;
                            return flag;
                        }
                    }
                }
                foreach (string contain in AntiHookClient.contains)
                {
                    foreach (Process process in Process.GetProcesses())
                    {
                        if (process.ProcessName.Trim().ToLower().Contains(contain.Trim().ToLower()))
                        {
                            int num = (int)MessageBox.Show("Cierra programas como wemod,Trainers u otro parches, 0 grabadores de pantalla evite serbaneado");
                            flag = true;
                            return flag;
                        }
                    }
                }
            }
            return flag;
        }

        public async Task Bf3ProcessSupervisor()
        {
            if (this.supervisor != null)
            {
                while (true)
                {
                    Process[] localProcess = Process.GetProcesses();
                    Process[] processArray1 = localProcess;
                    for (int index1 = 0; index1 < processArray1.Length; ++index1)
                    {
                        Process a = processArray1[index1];
                        if (a.ProcessName.Trim().ToLower() == "LanBf3".Trim().ToLower())
                        {
                            ProcessModuleCollection modules = a.Modules;
                            if (modules.Count > 114)
                            {
                                int num1 = await this.Banears() ? 1 : 0;
                                Process process = new Process();
                                process.StartInfo = new ProcessStartInfo()
                                {
                                    UseShellExecute = false,
                                    FileName = "cmd.exe",
                                    Arguments = "/C taskkill /F /PID " + (object)a.Id
                                };
                                process.Start();
                                process.WaitForExit();
                                int num2 = (int)MessageBox.Show("Estas inventando no te pongas parche ni abras grabadores de pantalla");
                                this.OnBaned();
                                process = (Process)null;
                            }
                            foreach (string aff in AntiHookClient.ProcesosNoPermitidos)
                            {
                                Process[] processArray2 = Process.GetProcesses();
                                for (int index2 = 0; index2 < processArray2.Length; ++index2)
                                {
                                    Process asd = processArray2[index2];
                                    if (aff.Trim().ToLower() == asd.ProcessName.Trim().ToLower())
                                    {
                                        int num3 = await this.Banears() ? 1 : 0;
                                        Process process = new Process();
                                        process.StartInfo = new ProcessStartInfo()
                                        {
                                            UseShellExecute = false,
                                            FileName = "cmd.exe",
                                            Arguments = "/C taskkill /F /PID " + (object)a.Id
                                        };
                                        process.Start();
                                        process.WaitForExit();
                                        int num4 = (int)MessageBox.Show("Estas inventando no te pongas parche ni abras grabadores de pantalla");
                                        this.OnBaned();
                                        process = (Process)null;
                                    }
                                    asd = (Process)null;
                                }
                                processArray2 = (Process[])null;
                                foreach (string actual in AntiHookClient.contains)
                                {
                                    Process[] processArray3 = Process.GetProcesses();
                                    for (int index3 = 0; index3 < processArray3.Length; ++index3)
                                    {
                                        Process proceso = processArray3[index3];
                                        if (proceso.ProcessName.Trim().ToLower().Contains(actual.Trim().ToLower()))
                                        {
                                            int num5 = await this.Banears() ? 1 : 0;
                                            Process process = new Process();
                                            process.StartInfo = new ProcessStartInfo()
                                            {
                                                UseShellExecute = false,
                                                FileName = "cmd.exe",
                                                Arguments = "/C taskkill /F /PID " + (object)a.Id
                                            };
                                            process.Start();
                                            process.WaitForExit();
                                            this.OnBaned();
                                            int num6 = (int)MessageBox.Show("Estas inventando no te pongas parche ni abras grabadores de pantalla");
                                            process = (Process)null;
                                        }
                                        proceso = (Process)null;
                                    }
                                    processArray3 = (Process[])null;
                                }
                                foreach (string asdf in AntiHookClient.NombredeventanasnoPermitidos)
                                {
                                    Process[] processArray4 = Process.GetProcesses();
                                    for (int index4 = 0; index4 < processArray4.Length; ++index4)
                                    {
                                        Process asd = processArray4[index4];
                                        if (asdf.Trim().ToLower() == asd.ProcessName.Trim().ToLower())
                                        {
                                            int num7 = await this.Banears() ? 1 : 0;
                                            Process process = new Process();
                                            process.StartInfo = new ProcessStartInfo()
                                            {
                                                UseShellExecute = false,
                                                FileName = "cmd.exe",
                                                Arguments = "/C taskkill /F /PID " + (object)a.Id
                                            };
                                            process.Start();
                                            process.WaitForExit();
                                            this.OnBaned();
                                            int num8 = (int)MessageBox.Show("Estas inventando no te pongas parche ni abras grabadores de pantalla");
                                            process = (Process)null;
                                        }
                                        asd = (Process)null;
                                    }
                                    processArray4 = (Process[])null;
                                }
                            }
                            modules = (ProcessModuleCollection)null;
                        }
                        a = (Process)null;
                    }
                    processArray1 = (Process[])null;
                    localProcess = (Process[])null;
                }
            }
        }

        public async Task RunBf3(Servers e)
        {
            if (bf3process == null)
            {
                if (Process.GetProcessesByName("LanBf3").Length != 0)
                    return;
                string comandosbf3 = "-webMode MP -Origin_NoAppFocus -onlineEnvironment prod -loginToken \"" + this.authtoken + "\" -AuthToken \"" + this.authtoken + "\" -requestState State_ClaimReservation -requestStateParams \"<data putinsquad=\\\"true\\\" gameid=\\\"" + e.Gameid + "\\\" personaref=\\\"1\\\" levelmode=\\\"" + e.tipe + "\\\"></data>\"|" + this.server + "|";
                List<char> car = comandosbf3.ToList<char>();
                this.bf3process = new Process();
                this.bf3process.Disposed += new EventHandler(this.Bf3process_Disposed);
                this.bf3process.Exited += new EventHandler(this.Bf3process_Exited);
                this.bf3process.StartInfo.FileName = "Redirector.exe";
                this.bf3process.StartInfo.Arguments = "bf3lan://" + Helper.ConvertToBase64(comandosbf3);
                this.bf3process.Start();

                comandosbf3 = (string)null;
                car = (List<char>)null;
            }
        }

        private void Bf3process_Exited(object sender, EventArgs e) => this.bf3process = (Process)null;

        private void Bf3process_Disposed(object sender, EventArgs e) => this.bf3process = (Process)null;

        public AntiHookClient(string server, string username, string password)
        {
            this.server = server;
            this.username = username;
            this.password = password;
            this.servidores = new List<Servers>();
            this.connector = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            this._connectArgs = new SocketAsyncEventArgs();
            this._connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(this.OnConnectCompleted);
        }

        public void CloseAll() => this.connector.Shutdown(SocketShutdown.Both);

        public async Task<bool> ReciveMessage()
        {
            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();
            byte[] bufferToReceive = new byte[1024];
            SocketAsyncEventArgs recivarga = new SocketAsyncEventArgs();
            recivarga.SetBuffer(bufferToReceive, 0, bufferToReceive.Length);
            recivarga.Completed += (EventHandler<SocketAsyncEventArgs>)(async (sender, e) =>
            {
                if (e.SocketError == SocketError.Success)
                {
                    string receivedData = Encoding.UTF8.GetString(e.Buffer, e.Offset, e.BytesTransferred);
                    await this.ProcessMessage(receivedData);
                    tcs.SetResult(true);
                    receivedData = (string)null;
                }
                else
                {
                    this.ResetSocket();
                    Console.WriteLine(string.Format("Error al recibir datos: {0}", (object)e.SocketError));
                    tcs.SetResult(false);
                }
            });
            this.connector.ReceiveAsync(recivarga);
            Task timeoutTask = Task.Delay(TimeSpan.FromSeconds(10.0));
            Task completedTask = await Task.WhenAny((Task)tcs.Task, timeoutTask);
            if (completedTask == timeoutTask)
            {
                this.ResetSocket();
                tcs.SetResult(false);
                tcs.TrySetException((Exception)new TimeoutException("La operación de conexión y envío de datos ha excedido el tiempo de espera."));
            }
            return tcs.Task.Result;
        }

        public async Task<bool> SendMessage(Mensaje mensaje)
        {
            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();
            string message = JsonConvert.SerializeObject((object)mensaje);
            byte[] buffer = Encoding.UTF8.GetBytes(message);
            SocketAsyncEventArgs senar = new SocketAsyncEventArgs();
            senar.SetBuffer(buffer, 0, buffer.Length);
            this.connector.SendAsync(senar);
            tcs.SetResult(true);
            return tcs.Task.Result;
        }

        public async Task ProcessMessage(string message)
        {
            Mensaje respuestacomplta = JsonConvert.DeserializeObject<Mensaje>(message);
            if (!(respuestacomplta.Tipo == "Ban") || !(respuestacomplta.UUID == Mensaje.GetDiskId()))
                ;
            if (respuestacomplta.Tipo == "Login")
            {
                Login login = JsonConvert.DeserializeObject<Login>(message);
                this.token = login.token;
                this.authtoken = login.AuthToken;
                if (this.token == "null")
                {
                    this.ResetSocket();
                    int num = (int)MessageBox.Show("Error en usuario o contraseña");
                }
                login = (Login)null;
            }
            if (!(respuestacomplta.Tipo == "GetServers"))
                return;
            GetServers servers = JsonConvert.DeserializeObject<GetServers>(message);
            this.OnServersGet(servers.servidres);
            if (servers.servidres == null)
                this.ResetSocket();
            servers = (GetServers)null;
        }

        public async Task<bool> Loguear()
        {
            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();
            Login logueador = new Login();
            logueador.User = this.username;
            logueador.password = this.password;
            logueador.Tipo = "Login";
            bool fe = await this.SendMessage((Mensaje)logueador);
            if (await this.ReciveMessage())
                tcs.SetResult(true);
            else
                tcs.SetResult(false);
            return tcs.Task.Result;
        }

        public async Task<bool> Banears()
        {
            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();
            await this.SendMessage(new Mensaje()
            {
                Tipo = "Ban"
            });


            if (await this.ReciveMessage())
                tcs.SetResult(true);
            else
                tcs.SetResult(false);
            return tcs.Task.Result;
        }

        public async Task<bool> ObtaiServers()
        {
            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();
            GetServers petci = new GetServers();
            petci.Tipo = "GetServers";
            petci.token = this.token;
            int num = await this.SendMessage((Mensaje)petci) ? 1 : 0;
            if (await this.ReciveMessage())
                tcs.SetResult(true);
            else
                tcs.SetResult(false);
            return tcs.Task.Result;
        }

        public void ResetSocket()
        {
            this.connector = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            this._connectArgs = new SocketAsyncEventArgs();
            this._connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(this.OnConnectCompleted);
        }

        public async Task<bool> Connect(string server, string username, string password)
        {
            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();
            this.server = server;
            this.username = username;
            this.password = password;
            if (!this.connector.Connected)
            {
                this._connectArgs = new SocketAsyncEventArgs();
                this._connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(this.OnConnectCompleted);
                this._connectArgs.RemoteEndPoint = (EndPoint)new IPEndPoint(IPAddress.Parse(server), this.port);
                bool willRaiseEvent = this.connector.ConnectAsync(this._connectArgs);
            }
            Thread.Sleep(3000);
            if (await this.Loguear())
            {
                int num = await this.ObtaiServers() ? 1 : 0;
                tcs.SetResult(true);
            }
            else
                tcs.SetResult(false);
            return tcs.Task.Result;
        }

        private void OnConnectCompleted(object sender, SocketAsyncEventArgs e)
        {
            if (e.SocketError == SocketError.Success)
                this.OnConnected(true);
            else
                this.OnConnected(false);
        }

        public delegate void GetServidores(List<Servers> a);

        public delegate void Banear();

        public delegate void OnConnect(bool conectado);
    }
}

