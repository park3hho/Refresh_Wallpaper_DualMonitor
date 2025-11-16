using Microsoft.Win32;
using System;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;

class MultiMonitorWallpaper
{
    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SystemParametersInfo(
        uint uiAction, uint uiParam, string pvParam, uint fWinIni);

    static readonly uint SPI_SETDESKWALLPAPER = 0x0014;
    static readonly uint SPIF_UPDATEINIFILE = 0x01;
    static readonly uint SPIF_SENDWININICHANGE = 0x02;

    static void SetWallpaperForMonitor(int monitorIndex, string imagePath)
    {
        string appdata = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        string wallpaperDir = Path.Combine(appdata, @"Microsoft\Windows\Themes");

        Directory.CreateDirectory(wallpaperDir);

        string cacheFile = Path.Combine(wallpaperDir, $"TranscodedImageCache_{monitorIndex}");

        // BMP? ?? (Windows? BMP ???? ??)
        Image img = Image.FromFile(imagePath);
        using (MemoryStream ms = new MemoryStream())
        {
            img.Save(ms, System.Drawing.Imaging.ImageFormat.Bmp);
            File.WriteAllBytes(cacheFile, ms.ToArray());
        }

        Console.WriteLine($"[OK] ??? {monitorIndex} ? {cacheFile}");
    }

    static void EnableSlideshowMode()
    {
        RegistryKey key = Registry.CurrentUser.OpenSubKey(
            @"Control Panel\Personalization\Desktop Slideshow", true);

        if (key == null)
            key = Registry.CurrentUser.CreateSubKey(
                @"Control Panel\Personalization\Desktop Slideshow");

        key.SetValue("Enabled", 1, RegistryValueKind.DWord);
        key.SetValue("Shuffle", 1, RegistryValueKind.DWord);
        key.Close();
    }

    static void RefreshDesktop()
    {
        // dummy wallpaper ??(Explorer refresh ??)
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, "", SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
    }

    static void Main(string[] args)
    {
        // args: monitorIndex,imagePath
        // ex: MultiMonitorWallpaper.exe 0 C:\img\wall1.jpg 1 C:\img\wall2.jpg ...

        if (args.Length % 2 != 0)
        {
            Console.WriteLine("???: MultiMonitorWallpaper.exe monitor image monitor image ...");
            return;
        }

        Console.WriteLine("? ???? ?? ?? ??");

        EnableSlideshowMode();

        for (int i = 0; i < args.Length; i += 2)
        {
            int monitorIndex = int.Parse(args[i]);
            string imagePath = args[i + 1];

            SetWallpaperForMonitor(monitorIndex, imagePath);
        }

        RefreshDesktop();

        Console.WriteLine("? ?? ??? ?? ?? ??!");
    }
}
