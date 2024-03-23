using System.Windows;
using Wox.Plugin;

namespace PowerToysRunPluginSample
{
    public class Main : IPlugin
    {
        private PluginInitContext? Context { get; set; }

        public string Name => "ILS";

        public string Description => "";

        public static string PluginID => "D99078D6998E495F80BCCC2294E8DB32";

        public List<Result> Query(Query query)
        {
            return new List<Result>
            {
                new() {
                    Title = "Item1",
                    SubTitle = "Item1 Subtitle",
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
        }
    }
}
