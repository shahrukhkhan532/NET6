using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace NET6.Api.Controllers
{
    [Route("[controller]/[action]")]
    [ApiController]
    public class GithubController : ControllerBase
    {
        [HttpPost]
        public IActionResult Received(Object dynamic)
        {
            System.Diagnostics.Debug.WriteLine(dynamic);
            return Ok();
        }
    }
}
