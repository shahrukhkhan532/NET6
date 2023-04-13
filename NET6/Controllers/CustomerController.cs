namespace NET6.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CustomerController : ControllerBase
    {
        public IActionResult GetCustomerById(int Id)
        {
            
            if (Id == 0)
                return NotFound();
            return Ok();
        }
    }
}
