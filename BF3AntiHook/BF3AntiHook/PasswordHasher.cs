using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System;
using System.Security.Cryptography;
using System.Text;

namespace BF3AntiHook.BF3AntiHook
{
   
    public class PasswordHasher
    {
        public static string HashPassword(string password)
        {
            using (MD5 md5 = MD5.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hashBytes = md5.ComputeHash(bytes);

                StringBuilder builder = new StringBuilder();
                foreach (byte b in hashBytes)
                {
                    builder.Append(b.ToString("x2")); // Convierte a formato hexadecimal
                }
                return builder.ToString();
            }
        }
    }

}
