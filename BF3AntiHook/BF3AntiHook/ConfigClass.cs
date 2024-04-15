// Decompiled with JetBrains decompiler
// Type: BF3AntiHook.BF3AntiHook.ConfigClass
// Assembly: BF3AntiHook, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: EEB90F25-279F-4551-9815-4FB977A6FF28
// Assembly location: C:\Users\Ernestico\Desktop\BF3AntiHook.exe

using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace BF3AntiHook.BF3AntiHook
{
  public static class ConfigClass
  {
    public static void SaveBans(List<string> bans)
    {
      string path = Path.Combine(Directory.GetCurrentDirectory(), "bans.json");
      if (File.Exists(path))
      {
        File.Delete(path);
        File.WriteAllLines(path, (IEnumerable<string>) bans);
      }
      else
        File.WriteAllLines(path, (IEnumerable<string>) bans);
    }

    public static List<string> LoadBans()
    {
      string path = Path.Combine(Directory.GetCurrentDirectory(), "bans.json");
      List<string> stringList = new List<string>();
      if (File.Exists(path))
        stringList = ((IEnumerable<string>) File.ReadAllLines(path)).ToList<string>();
      return stringList;
    }
  }
}
