namespace NET6.Tests.Controllers;
public class DepartmentControllerTests
{
    [Fact]
    [Trait("UI", "Back")]
    public async Task GetList_WhenCalled_ShouldReturn200()
    {
        /// Arrange
        var departmentService = new Mock<IDepartmentServices>();
        departmentService.Setup(_ => _.GetDepartments()).ReturnsAsync(DepartmentMockData.GetDepartments());
        var controller = new DepartmentController(departmentService.Object);

        /// Act
        var result = await controller.GetList();

        /// Assert
        result.GetType().Should().Be(typeof(OkObjectResult));
        _ = ((OkObjectResult)result).StatusCode.Should().Be(200);
    }
    [Fact]
    public async Task GetList_WhenCalled_ShouldReturn204()
    {
        /// Arrange
        var departmentService = new Mock<IDepartmentServices>();
        departmentService.Setup(_ => _.GetDepartments()).ReturnsAsync(DepartmentMockData.GetDepartmentsEmptyCollection());
        var controller = new DepartmentController(departmentService.Object);

        /// Act
        var result = await controller.GetList();

        /// Assert
        result.GetType().Should().Be(typeof(NoContentResult));
        _ = ((NoContentResult)result).StatusCode.Should().Be(204);
        Assert.Equal(204, ((NoContentResult)result).StatusCode);
    }
    [Fact]
    [Trait("UI", "Front")]
    public async Task SaveAsync_WhenCalled_ShouldCallServiseSaveMethod()
    {
        /// Arrange
        var departmentService = new Mock<IDepartmentServices>();
        var newDepartment = DepartmentMockData.AddDepartment();
        var controller = new DepartmentController(departmentService.Object);

        // Act
        var result = await controller.SaveAsync(newDepartment);

        // Asset
        departmentService.Verify(_ => _.SaveDepartment(newDepartment), Times.Exactly(1));
    }
}
