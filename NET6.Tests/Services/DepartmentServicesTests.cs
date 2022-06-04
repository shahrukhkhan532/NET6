using FluentAssertions;
using NET6.Tests.MockData;
using Microsoft.EntityFrameworkCore;

namespace NET6.Tests.Services;
public class DepartmentServicesTests : IDisposable
{
    private readonly DataDbContext _context;
    public DepartmentServicesTests()
    {
        var options = new DbContextOptionsBuilder<DataDbContext>()
        .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
        .Options;
        _context = new DataDbContext(options);
        _context.Database.EnsureCreated();
    }
    [Fact]
    public async Task GetDepartments_WhenCalled_ShouldReturnDepartmentCollection()
    {
        /// Arrange
        _context.Departments.AddRange(DepartmentMockData.GetDepartments());
        _context.SaveChanges();

        var departmentService = new DepartmentServices(_context);
        
        /// Act
        var result = await departmentService.GetDepartments();
        /// Assert
        result.Should().HaveCount(DepartmentMockData.GetDepartments().Count);
        Assert.Equal(result.Count, DepartmentMockData.GetDepartments().Count);
    }
    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }
}
