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
    [HttpGet]
    public async Task<IActionResult> GetList()
    {
        var result = await _departmentServices.GetDepartments();
        if (result.Count == 0)
            return NoContent();
        return Ok(result);
    }
    [HttpPost]
    public async Task<IActionResult> SaveAsync(Department department)
    {
        await _departmentServices.SaveDepartment(department);
        return Ok();
    }
}
