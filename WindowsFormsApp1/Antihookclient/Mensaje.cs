using System;
using System.Management;

namespace BF3AntiHook.BF3AntiHook
{
    public class Mensaje
    {
        public string Tipo { get; set; }


        public string version { get; set; }

        public string UUID { get; set; }

        public string token { get; set; }
        public static string GetDiskId()
        {
            string diskId = string.Empty;
            try
            {
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskDrive");
                foreach (ManagementObject wmi_HD in searcher.Get())
                {
                    diskId = wmi_HD["SerialNumber"].ToString();
                    break; // Si solo necesitas el primer disco duro
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Error al obtener el ID del disco duro: " + e.Message);
            }
            return diskId;
        }
        public Mensaje()
        {
            this.version = "2.17.0";
            this.UUID = GetDiskId().Trim();
        }
    }
}
