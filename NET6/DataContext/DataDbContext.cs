namespace NET6.Api.DataContext;
public class DataDbContext : Microsoft.EntityFrameworkCore.DbContext
{
    public DataDbContext(DbContextOptions<DataDbContext> contextOptions): base(contextOptions)
    {

    }
    public Microsoft.EntityFrameworkCore.DbSet<Department> Departments { get; set; }
}
