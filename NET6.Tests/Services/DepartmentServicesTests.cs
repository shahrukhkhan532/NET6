﻿using FluentAssertions;
using NET6.Tests.MockData;

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
    [Trait("UI", "Front")]
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
    [Fact]
    [Trait("UI", "Back")]
    public async Task SaveDepartment_WhenCalled_ShouldGiveAppropriateCount()
    {
        /// Arrange
        _context.Departments.AddRange(DepartmentMockData.GetDepartments());
        _context.SaveChanges();

        var newDepartment = DepartmentMockData.AddDepartment();
        var departmentService = new DepartmentServices(_context);

        /// Act
        var result = await departmentService.SaveDepartment(newDepartment);
        /// Asset
        
        int expectedCountRecord = DepartmentMockData.GetDepartments().Count + 1;
        _context.Departments.Count().Should().Be(expectedCountRecord);
        Assert.True(result);
        Assert.Equal(expectedCountRecord, _context.Departments.Count());
    }
    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }
}
