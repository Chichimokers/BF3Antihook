// Decompiled with JetBrains decompiler
// Type: BF3AntiHook.BF3AntiHook.Mensaje
// Assembly: BF3AntiHook, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: EEB90F25-279F-4551-9815-4FB977A6FF28
// Assembly location: C:\Users\Ernestico\Desktop\BF3AntiHook.exe

namespace BF3AntiHook.BF3AntiHook
{
  public class Mensaje
  {
    public string Tipo { get; set; }

    public string version { get; set; }

    public string UUID { get; set; }

    public string token { get; set; }

    public Mensaje() => this.version = "2.17.0";
  }
}
