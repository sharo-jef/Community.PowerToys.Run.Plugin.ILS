using ManagedCommon;
using System.Text.RegularExpressions;
using System.Windows;
using Wox.Plugin;

namespace ILS
{
    public class Main : IPlugin
    {
        private string? IconPath { get; set; }
        private PluginInitContext? Context { get; set; }
        public string Name => "ILS";
        public string Description => "ILS frequency lookup";
        public static string PluginID => "D99078D6998E495F80BCCC2294E8DB32";
        public List<Result> Query(Query query)
        {
            var keywords = new Regex(" +").Split(query.Search);
            var icao = keywords.Length > 0 ? keywords.First().ToUpper() : null;
            var runway = keywords.Length > 1 ? keywords[1] : null;
            if (icao == null || icao.Length != 4 || !icao.All(char.IsLetter))
            {
                return new List<Result>();
            }
            return Search(icao)
                .Where(result => runway == null || (result.Runway?.ToUpper().Contains(runway.ToUpper()) ?? true))
                .Select(result => new Result
                {
                    Title = $"{icao} {result.Runway} {result.Type} {result.Frequency / 1000000f}",
                    IcoPath = IconPath,
                    Action = _ =>
                    {
                        Clipboard.SetText((result.Frequency / 1000000f).ToString());
                        return true;
                    },
                }).ToList();
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
        private class SearchResult
        {
            public string? Runway;
            public string? Type;
            public int Frequency;
        }
        private static IEnumerable<SearchResult> Search(string icao)
        {
            var result = new List<SearchResult>();
            var response = API.GetNavaidData(icao);
            if (response == null)
            {
                return result;
            }
            if (response.runways != null)
            {
                foreach (var runway in response.runways)
                {
                    if (runway.navaids != null)
                    {
                        foreach (var navaid in runway.navaids)
                        {
                            result.Add(new SearchResult
                            {
                                Runway = runway.ident,
                                Type = navaid.type,
                                Frequency = navaid.frequency ?? 0,
                            });
                        }
                    }
                }
            }
            return result.Where(navaid => navaid.Frequency != 0);
        }
    }
}
