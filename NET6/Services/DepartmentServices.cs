namespace NET6.Api.Services;

public interface IDepartmentServices
{
    List<Department> GetDepartments();
    bool SaveDepartment(Department department);
}
public class DepartmentServices : IDepartmentServices
{
    private readonly DataDbContext context;

    public DepartmentServices(DataDbContext context)
    {
        this.context = context;
    }
    public List<Department> GetDepartments()
    {
        return this.context.Departments.ToList();
    }
    public bool SaveDepartment(Department department)
    {
        this.context.Departments.Add(department);
        return context.SaveChanges() > 0;
    }
}
