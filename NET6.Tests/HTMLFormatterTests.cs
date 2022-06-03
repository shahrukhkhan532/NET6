namespace NET6.Tests;
public class HTMLFormatterTests
{
    [Fact]
    public void FormatAsBold_WhenCalled_ShouldReturnStringAsBoldElement()
    {
        var htmlFormatter = new HTMLFormatter();
        var result = htmlFormatter.FormatAsBold("abc");
        Assert.Equal("<strong>abc</strong>", result);
    }
}
