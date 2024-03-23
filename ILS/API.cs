using System.IO;
using System.Net.Http;
using System.Text.Json;
using System.Web;

namespace ILS
{
  public class API
  {
#pragma warning disable IDE1006 // 命名スタイル
    public class ApiResponse
    {
      public Runway[]? runways { get; set; }
    }

    public class Runway
    {
      public string? ident { get; set; }
      public Navaid[]? navaids { get; set; }
    }

    public class Navaid
    {
      public string? type { get; set; }
      public int? frequency { get; set; }
    }
#pragma warning restore IDE1006 // 命名スタイル

    public static ApiResponse? GetNavaidData(string icao)
    {
      if (icao.Length != 4 || !icao.All(char.IsLetter))
      {
        return null;
      }
      icao = icao.ToUpper();
      var tmp = Path.GetTempPath();
      if (File.Exists($"{tmp}/{icao}.json"))
      {
        return JsonSerializer
          .Deserialize<ApiResponse>(
            File.ReadAllText($"{tmp}/{icao}.json", System.Text.Encoding.UTF8)
          );
      }
      var encodedKeyword = HttpUtility.UrlEncode(icao);
      var searchUrl = new Uri($"https://api.flightplandatabase.com/nav/airport/{encodedKeyword}");
      var httpClient = new HttpClient();
      var response = httpClient.GetAsync(searchUrl).GetAwaiter().GetResult();
      var content = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
      File.WriteAllText($"{tmp}/{icao}.json", content, System.Text.Encoding.UTF8);
      var result = JsonSerializer.Deserialize<ApiResponse>(content);
      return result;
    }
  }
}
