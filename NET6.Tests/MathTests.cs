namespace NET6.Tests;
public class MathTests
{
    [Fact]
    public void GetOddNumbers_LimitIsGreaterThanZero_ShouldReturnOddNumbersUptoLimit()
    {
        var math = new MathLibrary();

        var result = math.GetOddNumbers(5);

        // More Generic
        Assert.NotEmpty(result);

        Assert.Equal(3, result.Count());
        
        // More Specific
        Assert.Contains(1, result);
        Assert.Contains(3, result);
        Assert.Contains(5, result);

        // Prefered way to test IEnumerable
        Assert.Equal(new[] { 1, 3, 5 }, result);

    }
}
