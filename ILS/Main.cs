using System.Windows;
using ManagedCommon;
using Wox.Plugin;

namespace PowerToysRunPluginSample
{
    public class Main : IPlugin
    {
        private PluginInitContext? context { get; set; }

        public string Name => "ILS";

        public string Description => "";

        public static string PluginID => "D99078D6-998E-495F-80BC-CC2294E8DB32";

        public List<Result> Query(Query query)
        {
            return new List<Result>
            {
                new Result
                {
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
            this.context = context;
        }
    }
}
