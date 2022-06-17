namespace NET6.Tests.Controllers;
public class CustomerControllerTests
{
    [Fact]
    public void GetCustomer_IdIsZero_ShouldReturnNotFound()
    {
        var controller = new CustomerController();
        var result = controller.GetCustomerById(0);
        Assert.IsType(result.GetType(), controller?.NotFound());
    }
    [Fact]
    public void GetCustomer_IdIsNotZero_ShouldReturnOk()
    {
        var controller = new CustomerController();
        var result = controller.GetCustomerById(12);

        Assert.IsType(result.GetType(), controller?.Ok());
    }
}
