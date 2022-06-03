namespace NET6.Tests.Fundamentals;
public class ErrorLoggerTests
{
    [Fact]
    public void Log_WhenCalled_ShouldSetLastErrorProperty()
    {
        var logger = new ErrorLogger();
        logger.LogError("a");

        Assert.Equal("a", logger.LastError);
    }
    [Fact]
    public void Log_WhenCalled_ShouldRaiseException()
    {
        var logger = new ErrorLogger();

        Assert.Throws<ArgumentNullException>(() => logger.LogError(""));
    }
}
