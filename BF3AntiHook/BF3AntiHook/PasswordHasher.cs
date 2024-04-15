// Decompiled with JetBrains decompiler
// Type: BF3AntiHook.BF3AntiHook.PasswordHasher
// Assembly: BF3AntiHook, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: EEB90F25-279F-4551-9815-4FB977A6FF28
// Assembly location: C:\Users\Ernestico\Desktop\BF3AntiHook.exe

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
        byte[] hash = md5.ComputeHash(bytes);
        StringBuilder stringBuilder = new StringBuilder();
        foreach (byte num in hash)
          stringBuilder.Append(num.ToString("x2"));
        return stringBuilder.ToString();
      }
    }
  }
}
