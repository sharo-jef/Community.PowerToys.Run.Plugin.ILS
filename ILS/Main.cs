using System.Windows;
using ManagedCommon;
using Wox.Plugin;
namespace PowerToysRunPluginSample
{
    public class Main : IPlugin
    {
        private string? IconPath { get; set; }
        private PluginInitContext? Context { get; set; }
        public string Name => "hoge";
        public string Description => "";
        public static string PluginID => "D99078D6998E495F80BCCC2294E8DB32";
        public List<Result> Query(Query query)
        {
            return new List<Result>
            {
                new() {
                    Title = "Item1",
                    SubTitle = "Item1 Subtitle",
                    IcoPath = IconPath,
                    Action = e =>
                    {
                        Clipboard.SetText("Item1");
                        return true;
                    },
                },
            };
        }
        public void Init(PluginInitContext context)
        {
            Context = context;
            Context.API.ThemeChanged += OnThemeChanged;
            UpdateIconPath(Context.API.GetCurrentTheme());
        }
        private void UpdateIconPath(Theme theme)
        {
            IconPath = "images/icon.png";
        }
        private void OnThemeChanged(Theme currentTheme, Theme newTheme)
        {
            UpdateIconPath(newTheme);
        }
    }
}
