﻿namespace NET6.Api.Services;
using Microsoft.EntityFrameworkCore;

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
public class Fake : IDepartmentServices
{
    public Task<List<Department>> GetDepartments()
    {
        throw new NotImplementedException();
    }

    public Task<bool> SaveDepartment(Department department)
    {
        throw new NotImplementedException();
    }
}
