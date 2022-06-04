namespace NET6.Api.Controllers;

[Route("[controller]/[action]")]
[ApiController]
public class DepartmentController : ControllerBase
{
    private readonly IDepartmentServices _departmentServices;

    public DepartmentController(IDepartmentServices departmentServices)
    {
        _departmentServices = departmentServices;
    }
    public IActionResult List()
    {
        return Ok(_departmentServices.GetDepartments());
    }
}
