namespace NET6.Api.Services;

public interface IDepartmentServices
{
    Task<List<Department>> GetDepartments();
    Task<bool> SaveDepartment(Department department);
}
public class DepartmentServices : IDepartmentServices
{
    private readonly DataDbContext context;

    public DepartmentServices(DataDbContext context)
    {
        this.context = context;
    }
    public async Task<List<Department>> GetDepartments()
    {
        return await this.context.Departments.ToListAsync();
    }
    public async Task<bool> SaveDepartment(Department department)
    {
        this.context.Departments.Add(department);
        return await context.SaveChangesAsync() > 0;
    }
}
