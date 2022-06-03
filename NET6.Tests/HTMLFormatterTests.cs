namespace NET6.Tests;
public class HTMLFormatterTests
{
    [Fact]
    public void FormatAsBold_WhenCalled_ShouldReturnStringAsBoldElement()
    {
        var htmlFormatter = new HTMLFormatter();
        var result = htmlFormatter.FormatAsBold("abc");
        
        //Specific
        Assert.Equal("<strong>abc</strong>", result);

        //More General
        Assert.StartsWith("<strong>", result);
        Assert.EndsWith("</strong>", result);
        Assert.Contains("abc", result);
    }
}
